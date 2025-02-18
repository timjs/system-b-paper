#import "lib/styles.typ"
#import "lib/definitions.typ": *
#import "lib/judgements.typ": *
#import "lib/logos.typ"

// #import "acmart/template.typ": acmart
// #show: acmart.with(
//   title: [Boo! Borrowing isn't scarry, it's second class],
//   authors: (
//     (
//       name: "Tim Steenvoorden",
//       email: "tim.steenvoorden@ou.nl",
//       orcid: "0002-8436-2054",
//       affiliation: (
//         institution: "Open University",
//         streetaddress: "<address>",
//         city: "Heerlen",
//         country: "the Netherlands",
//       ),
//     ),
//   ),
//   acmJournal: "JACM",
// )

#show: styles.template
#show: logos.run


= Introduction

==== Context
Traditionally, functional programming is known as a good method for designing complex computer systems.
Use of higher-order functions and immutable datatypes aid in modularisation and reasoning.
Because of the same features, functional programming is not regarded suitable for systems programming.
Higher-order functions often involve the use of closures.
Manipulating immutable datatypes involves extensive copying.
Both usually happen on the heap, making use of garbage collectors to manage memory.
These are either not available or not desirable because of memory restrictions.

==== Challenges
Currently, there are two ways to allow functional languages for systems programming.
The first is to use reference counting instead of mark-and-sweep garbage collectors.
Although this has quite some overhead at runtime,
deallocation times become deterministic and
one can minimise the amount of refcount manipulations using static analysis @conf-pldi-ReinkingXML21.
As a further optimisation, at runtime, the refcount can be used to determine if data is uniquely owned,
allowing for in-place mutation.
However, there is still the need for a heap,
// and not all low-level systems allow heap usage.
which is not always available on low-level systems.

The second approach is to get rid of heap usage and garbage collectors entirely.
To do this, we need a tight type system preventing us from accidental heap allocation.
Examples are full linear type systems @conf-ifip2-Wadler90 @journals-pacmpl-BernardyBNJS18 @journals-jfp-OConnorCRJAKMSK21
which statically guarantee that every binding is used only once.
When using linear types only, we can be sure each binding points to uniquely owned data and modify it in-place.
Other languages, like Clean @plasmeijer2002clean, use uniqueness types additional to shared types
for ensured in-place updates or unique state threading.

==== Motivation
Full linear systems, however, make it hard to program in a higher-order fashion.
Take as an example the `filter` function on lists, in Haskell syntax:
```haskell
filter f xs = case xs of
  [] -> []
  x : xx -> if f x
    then x : filter f xx
    else filter f xx
```
When assigning a linear type to this function,
it would look something like this:
```haskell
filter :: (a -* Bool) -* List a -* List a   -- Wrong!
```
Here we use the lollipop arrow `-*` instead of to the normal `->` arrow
to state that all parameters, `f` and `xs` in this case, are linear:
they are restricted to be used exactly once.
The pattern match on `xs` consumes the value, and makes the head `x` and tail `xx` also linearly available.

Now we immediately see a problem:
`f` needs to be applied to each element of the list and also be threaded through all calls to `filter`.
We have to make `f` available more then once,
forcing us to incorporate unrestrictedness into our type system.
This sneaks in the need for garbage collection in our language implementation
and stratifies our language with functions for linear and unrestricted usage.
Linear Haskell @journals-pacmpl-BernardyBNJS18 is able to express this mixture:
```haskell
filter :: (a -* Bool) -> List a -* List a   -- Also wrong!
```

Now, `f` itself is unrestricted but still takes a linear argument.
This raises another problem.
On line~1, `xs` is matched linearly.
This means `x` and `xx` on line~3 are linear as well.
Therefore, the call `f x` on line~3 consumes `x`,
so we cannot use it any more in case we want to keep the element on line~4.
To solve this, we can make `f` unrestricted in its first parameter, yielding:
```haskell
filter :: (a -> Bool) -> List a -* List a   -- Still wrong!
```

Again, this fix will not help us as, in general,
we cannot pass a linear value as an unrestricted parameter.
In this case, we cannot guarantee that `f` does not duplicate its parameter.#footnote[
  In this particular case, it would be hard to design a pure function returning a boolean duplicating its parameter.
]
For this reason, Linear Haskell provides a `Dupable` class in its base library,
yielding the following type for `filter` in Linear Haskell:
```haskell
filter :: Dupable a => (a -* Bool) -> List a -* List a   -- Finally fixed!
```
The `Dupable` constraint on `a` means we restrict `filter` to lists of types that can freely be duplicated.
So, on a type-by-type base, we need to specify that type is dupable.
Note predicate function `f` is still passed unrestricted.

==== Solution

We propose a different solution,
where we do not need mixing owned and shared types.
Instead, we allow _borrowing_ of owned values.
In Boo, we can write `filter` like so, using a Koka-like syntax:
```koka
fun filter(1 xs: list<a>, ε f: (ε x: a) -> bool) -> list<a>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> if {x| f(x) }
      then Cons(x, xx.filter(f))
      else xx.filter(f)
```

In Boo, we annotate the binders with one of two _quantities_:
1 for owned (affine linear) usage, and
ε for borrowed (non-escaping) usage.
In our example, `xs` is _owned_, and thus restricted to be used exactly once or not at all.
This means `xs` can be modified in-place.
Predicate function `f` and its parameter `x` are _borrowed_.
Borrowed binders can be used multiple times, but cannot _escape_ their scope.
They are thus safe to pass on to other functions,
but cannot be returned as a result or saved in data structures.

The borrowing block `{x| f(x) }` on line~4,
turns binding `x` from owned into borrowed during the evaluation of the expression `f(x)`.
Now `f` can take `x` as a borrowed parameter.

By allowing higher-order functions in Boo,
we need to take special care of the available bindings when constructing closures.
Say, we write the following code filtering a list for multiples of 3:
```koka
val ε m = 3
val 1 xs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
val 1 ys = xs.filter(fn(x) x % m == 0)
// => ys == [3, 6, 9]
```
The lambda on line~3 closes of variable `m` from its outer scope.
As `filter` asks for a borrowed function,
we allow the construction of a borrowed lambda closing over borrowed variables.


==== Contributions

In the remaining of this paper, we dive into the Boo language and its properties.
We present:

- the language Boo,
  a small functional programming language with quantity annotations on the binders;
- a bidirectional type system for Boo keeping track of these quantities,
  combining affine linear types with borrowing, mechanised in Agda; //of its soundness [and completeness];
- a small-step operational semantics for Boo,
  showing all allocations can be done on the stack;
- an extension of Boo with the notion of _shared_ binders, called Boos.

==== Organisation

The remaining of this paper is structured as follows.
In the next section, @examples, we show motivating examples of Boo,
discussing the implications of our design.
Thereafter, we formalise the syntax and semantics of Boo in @theory.
Section @metatheory contains metatheoretical properties of Boo.
After discussing related work in @related-work,
we conclude and present future work in @conclusion.

= Examples <examples>

In this section we discuss some examples to showcase the features of Boo.

== Notation

$
   x_0.f(many(x, n))                      &~> f(x_0, many(x,n)) \
   "if" e_0 "then" e_1 "else" e_2         &~> "match" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "when" { e_0 |-> e_1; "else" |-> e_2 } &~> "match" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "with" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
  //  "when" { many(p |-> e, n) "else" |-> e_(n+1) } &~> "match" p_1 space { "True" |-> e_1; "False" |-> "match" p_2 space { "True" |-> e_2; "False" |-> ... }} \
$

== Simple owning and sharing functions

```koka
fun identity(1 x: a) -> a
  x

fun duplicate(ω x: a) -> (a, a)
  (x, x)

fun free(1 x: a) -> ()
  ()
```

== First-order functions on lists

```koka
fun length(ε xs: list<a>) -> nat
  match ε xs
    Nil -> 0
    Cons(_, xx) -> 1 + xx.length()

fun contains(ε xs: list<a>, ε y: a) -> bool
  match ε xs
    Nil -> False
    Cons(x, xx) -> when
      x == y -> True
      else -> xx.contains(y)

fun append(1 xs: list<a>, 1 ys: list<a>) -> list<a>
  match 1 xs
    Nil -> ys
    Cons(x, xx) -> Cons(x, xx.append(ys))

fun dedup(1 xs: list<a>, ε ys: list<a>) -> list<a>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> when
      ys.contains(x) -> xx.dedup(ys)
      else -> Cons(x, xx.dedup(ys))
```

== Second-order functions on lists

```koka
fun iterate(ε xs: list<a>, ε f: (ε x: a) -> η ()) -> η ()
  match ε xs
    Nil -> ()
    Cons(x, xx) ->
      f(x)
      xx.iterate(f)

fun map(1 xs: list<a>, ε f: (1 x: a) -> η b) -> η list<b>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> Cons(f(x), xx.map(f))

fun filter(1 xs: list<a>, ε f: (ε x: a) -> η bool) -> η list<a>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> if f(x)
      then Cons(x, xx.filter(f))
      else xx.filter(f)
```

We'd like to invert the argument Rust makes about borrowing:
If and only if a value is used borrowed, it cannot escape the function,
and therefore it can be allocated on the stack.

```koka
fun filter-map(1 xs: list<a>, ε f: (1 x: a) -> η option<b>) -> η list<b>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> match 1 f(x)
      None -> xx.filter-map(f)
      Some(y) -> Cons(y, xx.filter-map(f))
```

```rust
fn retain     : (&mut Vec<a>, f: FnMut(&a)     -> bool) -> () {...}
fn retain_mut : (&mut Vec<a>, f: FnMut(&mut a) -> bool) -> () {...}
```

#verdicts[
  + We can write a functional specification of this routine.
    Conceptually, we get an immutable list and build and return a new immutable list.
  + The list `xs` is used _owned_ [linearly, not affine, the size stays the same...].
    Therefore, the spine can be modified in-place if it happens to be _unique_ at runtime.
  + Every element `x` of the list is used _owned_ by `f`.
    Therefore, it can also be modified in-place if it is _unique_ at runtime.
]


= Language and semantics <theory>

#figure(caption: [Synthesizing type rules for Boo])[$
  framed(synthesize(
    below(Gamma, arrow.t),
    below(e, arrow.t),
    below(q, arrow.t),
    below(tau, arrow.b),
    below(Gamma', arrow.b)
  )) \
  judgements.var.one wide
  judgements.bind.one \
  judgements.var.epsilon wide
  judgements.borrow.one.one \
  judgements.abs.epsilon.one \
  judgements.abs.one.one \
  judgements.app.lambda.one \
  // judgements.app.lambda.uncurried \
  judgements.construct.one \
  // judgements.construct.uncurried \
  judgements.match.uncurried \
$]

// #figure(caption: [Checking type rules for Boo])[$
//   framed(check(
//     below(Gamma, arrow.t),
//     below(many(e, n), arrow.t),
//     below(many(q, n), arrow.t),
//     below(many(tau, n), arrow.t),
//     below(Gamma', arrow.b)
//   )) \
// $]

#figure(caption: [Spine typing rules for Boo])[$
  framed(synthesizes(
    below(Gamma, arrow.t),
    below(many(e, n), arrow.t),
    below(many(q, n), arrow.t),
    below(many(tau, n), arrow.t),
    below(Gamma', arrow.b)
  )) \
  judgements.spine.empty wide judgements.spine.rest \
$]


= Adding unrestrictedness

= Guarantees <metatheory>

= Related work <related-work>

= Conclusion <conclusion>

== Future work

// = Bibliography

#bibliography(("dblp.bib", "other.bib"),
  // style: "association-for-computing-machinery",
  style: "american-psychological-association",
)

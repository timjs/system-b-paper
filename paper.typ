#import "acmart/template.typ"
#import "basic/setups.typ"
#import "basic/logos.typ"
#import "typing/definitions.typ": *
#import "typing/judgements.typ": *

#show: template.acmart.with(
  format: "acmsmall",
  title: [Boo! Borrowing isn't scarry, it's second class],
  authors: (
    (
      name: "Tim Steenvoorden",
      email: "tim.steenvoorden@ou.nl",
      orcid: "0002-8436-2054",
      affiliation: (
        institution: "Open University",
        streetaddress: "<address>",
        city: "Heerlen",
        country: "the Netherlands",
      ),
    ),
  ),
  abstract: [...],

  acmJournal: "JACM",
)
#show: setups.init
#show: logos.init

#show heading.where(level: 4).or(heading.where(level: 5)): set heading(numbering: none)
#set math.lr(size: 1em) // Magic! :-D



= Introduction

// == Context
Traditionally, functional programming is known as a good paradigm to program robust complex computer systems.
Use of higher-order functions and immutable datatypes aid in modularisation and reasoning.
At the same time, because of these features, functional programming is not regarded suitable for systems programming.
Higher-order functions often involve the use of closures and
manipulating immutable datatypes involves extensive copying.
Both usually happen on the heap, making use of garbage collectors to manage memory.
In case of embedded systems, kernel modules, and hardware drivers,
these are either not available or not desirable because of memory restrictions.
It seems systems programming is out of scope for functional programming languages.

// == Challenges
Currently, there are two ways to [allow] functional languages for systems programming.
The first is to make automatic memory management deterministic by
using reference counting instead of mark-and-sweep garbage collectors.
Although this has quite some overhead at runtime,
one can minimise the amount of refcount manipulations using static analysis @conf-pldi-ReinkingXML21.
As a further optimisation, at runtime, the refcount can be used to determine if data is uniquely owned,
allowing for in-place mutation.
However, there is still the need for a heap,
// and not all low-level systems allow heap usage.
which is not always available on low-level systems.

The second approach is to get rid of heap usage and garbage collectors entirely.
This requires tight type systems preventing accidental heap allocation.
Linear types can statically guarantee that every binding is used only once @conf-ifip2-Wadler90 @journals-pacmpl-BernardyBNJS18 @journals-jfp-OConnorCRJAKMSK21.
When using linear types only, we can be sure each binding points to uniquely owned data and modify it in-place.
However, as we will see shortly, full linear systems make it hard to program in a higher-order fashion.
// Other languages, like Clean @plasmeijer2002clean and Rust @klabnik2023rust, combine uniqueness types or affine types with shared types
// for ensured in-place updates or unique state threading.

== Motivation
Take as an example below implementation to filter lists in Haskell:
```haskell
filter p xs = case xs of
  [] -> []
  x : xx -> if p x
    then x : filter p xx
    else filter p xx
```
When assigning a linear type to this function,
it would look something like this:
```haskell
filter :: (a -* Bool) -* List a -* List a   -- Wrong!
```
Here we use the lollipop arrow `-*` instead of to the normal `->` arrow
to state that all parameters, `p` and `xs` in this case, are linear:
they are restricted to be used exactly once.
The pattern match on `xs` consumes the value, and makes the head `x` and tail `xx` also linearly available.

Now we immediately see a problem:
`p` needs to be applied to each element of the list and also be threaded through all calls to `filter`.
We have to make `p` available more then once,
forcing us to incorporate unrestrictedness into our type system.
Linear Haskell @journals-pacmpl-BernardyBNJS18 is able to express this mixture:
```haskell
filter :: (a -* Bool) -> List a -* List a   -- Also wrong!
```

Now, `p` itself is unrestricted but still takes a linear argument.
This raises another problem.
On line~1, `xs` is matched linearly.
This means `x` and `xx` on line~3 are linear as well.
Therefore, the call `p x` on line~3 consumes `x`,
so we cannot use it any more in case we want to keep the element on line~4.
To solve this, we can make `p` unrestricted in its first parameter, yielding:
```haskell
filter :: (a -> Bool) -> List a -* List a   -- Still wrong!
```

Again, this fix will not help us as, in general,
we cannot pass linear values to unrestricted parameters:
we cannot guarantee that `p` does not duplicate its parameter.#footnote[
  In this particular case, it would be hard to design a pure function returning a boolean duplicating its parameter.
]
For this reason, Linear Haskell provides a `Dupable` class in its base library,
yielding the following final type for `filter` in Linear Haskell:
```haskell
filter :: Dupable a => (a -* Bool) -> List a -* List a   -- Finally fixed!
```
The `Dupable` constraint on `a` means we restrict `filter` to lists of types that can freely be duplicated.
So, on a type-by-type base, we need to specify that type is duplicatable.
Predicate function `p` is still passed unrestricted.

In the end, we cannot type `filter` with linear types only,
they are too restrictive.
We are forced to mix linear and shared types in our language.
On the language level, this is not a problem,
but on the implementation level this sneaks in the need for garbage collection.
Exactly this is what we hoped to prevent!

== Solution
We propose a solution where we do not need mixing of owned and shared types.
Instead, we allow _borrowing_ of owned _bindings_.
We introduce Boo, a small functional programming language with quantity annotations on binders.
In Boo, we can write `filter` like so:
```koka
fun filter(1 xs: list<a>, ε p: (ε x: a) -> bool) -> list<a>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> if {x| p(x) }
      then Cons(x, xx.filter(p))
      else xx.filter(p)
```

We see parameters in Boo are annotated with one of two _quantities_:
1 for owned (affine linear) usage, and
ε for borrowed (non-escaping) usage.
In our example, `xs` is _owned_, and thus restricted to be used exactly once or not at all.
This means `xs` can be modified in-place.
Predicate function `p` and its parameter `x` are _borrowed_.
Borrowed binders can be used multiple times, but cannot _escape_ their scope.
They are thus safe to pass on to other functions,
but cannot be returned as a result or saved in data structures.
//
The borrowing block `{x| p(x) }` on line~4,
turns binding `x` from owned into borrowed during the evaluation of the expression `p(x)`.
Now `p` can take `x` as a borrowed parameter.

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

== Contributions
The combination of linear types and borrowing is a promising approach
to incorporate functional programming techniques like higher-order functions and immutable data types
into systems programming.
By annotating binders instead of types,
there is no stratification of linear and non-linear types.
Every type can be owned, and therefore be mutated in-place, or borrowed.
Also, as borrowed values cannot escape their scope, they coincide with being second class.

In the remaining of this paper, we dive into the Boo language and its properties.
We present:

- the language Boo, a small functional programming language with quantity annotations on binders;
- a bidirectional type system for Boo keeping track of these quantities, combining affine linear types with borrowing, mechanised in Agda; //of its soundness [and completeness];
- a small-step operational semantics for Boo, showing all allocations can be done on the stack;
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

#set math.lr(size: 1em) // Magic! :-D
// #show math.upright: text

$
   x_0.f(many(x, n))                      &~> f(x_0, many(x,n)) \
   "if" e_0 "then" e_1 "else" e_2         &~> "match" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "when" { e_0 |-> e_1; "else" |-> e_2 } &~> "match" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "with" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
  //  "when" { many(p |-> e, n) "else" |-> e_(n+1) } &~> "match" p_1 space { "True" |-> e_1; "False" |-> "match" p_2 space { "True" |-> e_2; "False" |-> ... }} \
$

== Simple owning and sharing functions

When returning a value $v$ from a function, there can be several cases.
Value $v$ is:

1.  a primitive value $p$; <case-prim>
2.  a compound value, where $v$: <case-comp>
    1.  has a _statically known_ size; <case-comp-stc>
    2.  is _dynamically_ sized; <case-comp-dyn>
3.  a reference to another value, so actually a location $l$, where $v$: <case-ref>
    1.  is allocated on the _heap_; <case-ref-heap>
    2.  is allocated on the _stack_: <case-ref-stack>
        1.  in the _caller's_ stack frame or even before that; <case-ref-stack-caller>
        2.  in the _callee's_ stack frame. <case-ref-stack-callee>

@case-prim is the easiest case.
As primitives are word-sized, they can simply be returned in a register.
In @case-comp we need to know if the value has a size that can be _statically determined_.
If that's the case, we can _preallocate_ space on the _caller's_ stack frame,
and put the return value there (@case-comp-stc).
If it's _dynamically sized_, however, we cannot apply this trick.
We need to allocate $v$ on the heap and return a pointer to it.
A solution currently investigated by @conf-ecoop-XhebrajB0R22 is to _refrain from popping the stack_.
This way we can allocate dynamically sized values on the stack anyway.

Then we've @case-ref, where we're returning references.
If this value is allocated on the heap, we're fine and can return the location $l$ of $v$ in a register (@case-ref-heap).
The same holds for the case where the location is _not_ on the callee's stack frame (@case-ref-stack-caller).
The problem lies in the case where we've allocated some data on the callee's stack frame,
and want to return a reference to it.
This data will be implicitly freed after the callee returns.

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

== Stack allocated lists

Take as an example the `init` function to create lists.
It applies a function `n` times and collects the outcomes:
```koka
fun init(ε f: (ω n: nat) -> a, ω n: nat) -> list<a>
  val ε go = fn(1 xs: list<a>, ω n: nat) if n == 0
    then xs
    else go(Cons(f(n), xs), n - 1)
  go(n, Nil)
```
  // when
  //   n == 0 -> xs
  //   else -> go(Cons(f(n), xs), n - 1)

The imperative counterpart looks like this:
```koka
fun init(ε f: (ω n: nat) -> a, ω n: nat) -> list<a>
  var xs := Nil
  while {n > 0}
    xs := Cons(f(n), xs!)
    n += 1
  xs!
```


In Oxidized OCaml, we can write a definition that explicitly allocates the list on the stack:
```sml
val init_local : int -> (int -> 'a @ local) -> 'a list @ local
let init_local n f =
  let rec go n xs = if n = 0
    then xs
    else let n = n - 1 in exclave loop n (f n :: xs)
  in exclave loop n []
```

What we want to accomplish [?] is that our implementation of `init` in Koka,
results in two versions: one that allocates its result on the stack, and one that does so on the heap.
Which version is used, is determined _at the call site_:

```koka
val ε xs = init(f, 12) // allocated on the stack
val 1 xs = init(f, 12) // allocated on the stack
val ω ys = init(f, 12) // allocated on the heap
```

In case of stack allocation, the layout would look something like this.
#table(columns: 1, align: (center,),
  $n--$,
  $f$,
  $"Nil"$,
  $f(n)$,
  $arrow.hook.tl$,
  $f(n-1)$,
  $arrow.hook.tl$,
  $dots.v$,
  $f(0)$,
  $arrow.hook.tl$,
)

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

#bibliography(("tex/dblp.bib", "tex/other.bib"),
  // style: "association-for-computing-machinery",
  style: "american-psychological-association",
)

#import "/types/definitions.typ": *

= Examples <sec:examples>

In this section we discuss some examples to showcase the features of System B.

/*
== Definitions

There are three quantities available.
These are:
/ ε:
  borrowed
/ 1:
  owned
/ ω:
  shared

We use the following definitions:
/ Borrowed: binding with quantity ε
/ Owned: binding with quantity 1
/ Shared: binding with quantity ω

/ Consumed: when owned binding is "used up"
*/

== Owning and sharing
<exm:identity>

The main idea of owning and borrowing in System B is [implemented] by quantity annotations on bindings.
To showcase our approach to linearity and borrowing, let us first look at three basic examples.

#side-by-side[
  ```sysb
  fn identity(1 x: a) -> a
    x
  ```
][
  ```sysb
  fn constant(1 x: a, 1 y: b) -> a
    x
  ```
][
  ```sysb
  fn duplicate(ω x: a) -> (a, a)
    (x, x)
  ```
]

In each function definition, all parameters are accompanied with a _binder annotation_ in front of the parameter name,
which can be $1$ for _owned_ bindings or $omega$ for _shared_ bindings.
The `identity` function in System B is linear.
It takes one owned parameter of polymorphic type `a` and returns it.
/*
This is also exemplified by `constant`,
where `x` is used once,
but here we also need to dispose `y` by _dropping_ it.
*/
However, owned bindings in System B are _affine linear_:
they can be used exactly once or not at all.
This is exemplified by the function `constant`, which takes two owned parameters,
but only returns the first one.
In the function `duplicate`, we duplicate the give parameter `x`,
so `x` needs to be shared.
Here we see we only distinguish single usage over multiple usage,
and nothing in between.

The intuition behind these two binding quantities is as follows.
Each quantity represents an amount of _resource tokens_ available for that binding.
//
For bindings of quantity 1, only one such token is available.
Therefore, it can only be used once or not at all,
corresponding to affine linear usage.
When a function parameter is annotated with this quantity,
we say it _consumes_ its argument.
So functions that consume an argument, conceptually consume one resource token.
If there is only one token available, the binding will not be accessible after this consumption.
// These bindings can  be passed to other functions which consume a resource token,
// but cannot be passed to functions which need infinitely many resource tokens (of quantity ω).

The shared quantity ω represents an _infinite amount_ of resource tokens.
So bindings with this quantity can be used an unrestricted number of times.
The can be passed to other functions needing an infinite amount of resource tokens,
which conceptually still leaves an infinite amount of tokens available.
Also, they can be passed as owned parameters.
// using one resource token out of an infinite amount should be possible.
As there are infinitely many resource tokens available
and only one of those is consumed,
infinitely many tokens remain.
Even though the data that the binding refers to is shared,
from the perspective of this function, the binding is owned and can only be consumed once.
#todo[Add example of this.]

This design decision has two important consequences for functions taking owned parameters:
/ They are efficient in memory reuse:
  // can mutate their data in-place if and only if it is unique at runtime:
  System B guarantees owned parameters, and thus the data pointed to, is used only once.
  Therefore, this data could be mutated in-place.
  However, they are not guaranteed to have unique ownership to the referred data:
  as explained before, data passed into the function could still be shared.
  However, if and only if the data is unique at runtime it can be mutated in-place.
  This runtime check can be inserted by the compiler,
  essentially generating two versions of the same function:
    one that mutates in-place when data is unique
    and one that copies when it is shared.
/ They are polymorphic over memory reuse:
  // Shared data can be passed to owned parameters, forestalling the need to write separate functions for unique and shared data:
  // They induce multiple concrete implementations of the same algorithm for , possibly reusing   :
  As the actual parameter can be either owned or shared,
  there is no need in writing multiple implementations of the same algorithm by hand,
  taking different memory management strategies into account.
  These versions can be generated from one and the same specification.

== Quantities on bindings

Annotations of quantities are put _on the binder_ and are not part of the type.
As a consequence, we annotate `let`-bindings and pattern matches with quantities as well.

#todo[Add `case`-example.]

Duplicating a binding with quantity $1$, will result in a compile-time error:
Duplicating is fine however, if the binding is declared _shared_:
#side-by-side[
```sysb
let 1 x = 42
duplicate(x) // ERROR!
```][
```sysb
let ω y = 37
duplicate(y) // Fine :-)
```]

#todo[Add `rebind` example?]

#todo[Add consuming example]

// ```sysb
// fn rebind(q_x x : a) -> ()
//   let q_y y = x
//   ()
// ```

== Borrowing

// === Length

// As we have seen previously, owned parameters consume their
// One of the major pain points with (affine) linear types,
// is that linear functions of functions

#todo[Introduce borrowing and explain example]

#todo[Use other example?]
#side-by-side[
  ```sysb
  fn length(1 s: String) -> (Nat, String)
  fn main()
    let s = "Hello world"
    let (l, s') = s.length()
    // ...use new s'...
  ```
][
  ```sysb
  fn length(ε s: String) -> Nat
  fn main()
    let s = "Hello world"
    let l = s.length()
    // ...still use s...
  ```
]

Conceptually,
bindings of quantity ε only need an infinitely small amount of a resource token.
So, a function needing ε resource tokens,
leaves the original amount of resource tokens available.
We say these functions _borrow_ their arguments.
The borrow ends when the function call returns.
As we will see shortly,
all shared bindings can be borrowed freely,
but owned bindings need to be explicitly borrowed in a region.

Borrowed parameters can be passed as arguments to other functions that expect to borrow.
As we do not have a full resource token (only an infinitely small amount of it),
we cannot return a borrowed parameter from a function.
This makes borrowed bindings second class.

Data is not regarded to be second class based on its type.
The focus is on binders and their quantity.
This way, being second class is not a property of the type,
but a property of the binding:
Every type can be used in a first or second class manner depending on the bind site.

// === Contains

#todo[Add `contains` example?]
```sysb
fn contains_1(1 ts: Tree(k, v), ω x: k) -> Bool
fn contains_2(ω ts: Tree(k, v), ω x: k) -> Bool
fn contains_3(1 ts: Tree(k, v), ω x: k) -> (Bool, Tree(k,v))
fn contains_4(ε ts: Tree(k, v), ε x: k) -> Bool
```

Options:
1. No tree to use any more, as it is consumed (like `String` example).
2. Needs original tree to be shared, no reuse possible.
3. Awkward to implement, as we need to keep track of the tree root in our algorithm, and
   \ awkward to use, as we need multiple bindings to store the root in.
4. Our solution.

/*
```sysb
fn lookup_1(1 ts: Tree(k, v), ω x: k) -> Option(v)
fn lookup_2(ω ts: Tree(k, v), ω x: k) -> Option(v)
fn lookup_3(1 ts: Tree(k, v), ω x: k) -> (Tree(k,v), Option(v))
fn lookup_4(ε ts: Tree(k, v), ε x: k) -> Option(v)
```

#side-by-side[
  ```sysb
  lookup :
  (1 ts: Tree(k, v), ω x: k)
  -> Option(v)
  ```
][
  ```sysb
  lookup :
  (1 ts: Tree(k, v), ω x: k)
  -> (Tree(k,v), Option(v))
  ```
][
  ```sysb
  lookup :
  (ε ts: Tree(k, v), ε x: k)
  -> Option(v)
  ```
]

#side-by-side[
  ```sysb
  fn lookup(1 ps: List(#(k,v)), ω k: k) -> Option(v)
    case_1 ps
      Nil -> None
      Cons(#(x, y), xs) -> when
        x == k -> Some(y)
        otherwise -> xs.lookup(k)
  ```
]

#side-by-side[
  ```sysb
  fn lookup(1 ts: Tree(k, v), ω x: k) -> Option(v)
    case_1 ts
      Leaf |-> None
      Node(ls, k, v, rs) |-> case x.compare(k)
        LT |-> ls.lookup(x)
        EQ |-> Some(v)
        GT |-> rs.lookup(x)
  ```
][
  ```sysb
  fn lookup(ε t: Tree(k, v), ε y: k) -> Option(v)
    case_ε ts
      Leaf |-> None
      Node(ls, k, v, rs) |-> case x.compare(k)
        LT |-> ls.lookup(x)
        EQ |-> Some(v)
        GT |-> rs.lookup(x)
  ```
]
*/

== Borrowing, again

// === Filter

<exm:filter>
System B allows borrowing of owned bindings.
// We propose a solution where we do not need mixing of linear and shared types.
We can write a `filter` function on `List`s like so:
```sysb
fn filter(1 xs: List(a), ε p: (ε x: a) -> Bool) -> List(a)
  case_1 xs
    Nil |-> Nil
    Cons(x, xx) |-> if { x | p(x) }
      then Cons(x, xx.filter(p))
      else xx.filter(p)
```

In this example, predicate function `p` and its parameter `x` are declared to be borrowed.
Borrowed binders can be used multiple times, but cannot escape their scope.
They are thus safe to pass on to other functions,
but cannot be returned as a result or saved in data structures.

Parameter `xs` is owned, and thus restricted to be used exactly once or not at all.
// This means `xs` can be modified in-place
This means `xs` should be used affine linear in every branch of this function.
This is actually not the case,
as in the `Cons`-case, predicate function `p` needs `x` to decide to keep or discard it.
Luckily, `p` takes its argument borrowed.
The borrowing block `{ x | p(x) }` on line~4,
// Now `p` can take `x` as a borrowed parameter.
turns binding `x` from owned into borrowed during the evaluation of the expression `p(x)`.
After the borrowing block ends, `x` has quantity `1` again
and can be stored or discarded.

// === Deduplication

Borrowing of owned bindings needs special care.
Take as an example deduplication of a list of integers.
In System B this would have the following type:
```sysb
fn deduplicate(1 xs: List(Int), ε ys: List(Int)) -> List(Int)
```
// fn deduplicate(1 xs: List(a), ε ys: List(a), ε eq: (a, a) -> Bool) -> List(a)
// fn deduplicate(1 xs: List(Int), ε ys: List(Int)) -> List(Int)
//   case_1 xs
//     Nil |-> Nil
//     Cons(x, xx) |-> if { x | ys.contains(x) }
//       then xx.deduplicate(ys)
//       else Cons(x, xx.deduplicate(ys))
// fn contains(ε xs: List(a), ε y: a) -> Bool
//   case_ε xs
//     Nil |-> False
//     Cons(x, xx) |-> if x == y
//       then True
//       else xx.contains(y)
// ```
The first list is the main subject to be deduplicated.
We thus need ownership on `xs` and we consume `1` resource token.
The second list is only for inspection.
Therefore, we only borrow `ys`.
The returned list may or may not be an in-place updated version of `xs`,
depending on the runtime uniqueness of `xs`.

Say, at the use site, we want to deduplicate a list by itself:
```sysb
let 1 ns = [1,2,3,4,5]
let 1 ms = ns.deduplicate(ns)
```
This should result in an error, as we cannot consume list `ns`,
possibly mutating it on the way,
while borrowing it at the same time.
System B takes care of this by removing the owned binding of `ns` from the context as soon as it is consumed.
#footnote[Rust users would say the ownership of `ns` _moved_ into `deduplicate`.]
Binding `ns` is not available any more, and consequently cannot be borrowed.

What if we defined `deduplicate` differently and swapped the arguments?
Its type would be:
```sysb
fn deduplicate(ε ys: List(Int), 1 xs: List(Int)) -> List(Int)
```
Here, `xs` is still the main subject and `ys` is only for inspection.

Type checking the term `ns.deduplicate(ns)` should still result in an error,
as owned bindings cannot be borrowed automatically.
We need to create a borrowing block to explicitly state when `ns` is borrowed.
For this, we have two options:
#block(inset: (y: 0.5em), //FIXME: generalise
  side-by-side[
    *Case 1*\ `{ ns | ns }.deduplicate(ns)`
  ][
    *Case 2*\ `{ ns | ns.deduplicate(ns) }`
  ]
)
In case 1 we borrow `ns` only for the duration of passing the first parameter.
We borrow it and immediately return it.
Borrowed bindings are second class and therefore cannot be returned from a block for function.
This case results in an error.// that `ns` cannot be returned owned as it is only available borrowed.

In case 2 we borrow `ns` during the whole call of `deduplicate`.
It is completely fine now to pass `ns` as the first parameter.
However, the second parameter of `deduplicate` consumes its argument,
needing 1 resource token,
but only an ε amount of `ns` is available.
This case will also result in an error.// that `ns` cannot be owned as it is only available borrowed.
We see System B's type system needs to prevent us from borrowing possibly mutating data.

== Reuse

#todo[Add section on reuse]

== Closures

By allowing higher-order functions in System B,
we need to take special care of the available bindings when constructing closures.
Say, we write the following code filtering a list for multiples of 3:
```sysb
let ε m = 3
let 1 xs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let 1 ys = xs.filter(fn(x) x % m == 0) // => [3, 6, 9]
```
The lambda on line~3 closes of variable `m` from its outer scope.
As `filter` asks for a borrowed function,
we allow the construction of a borrowed lambda closing over borrowed variables.

#todo[Add and explain more examples.]

== Datatypes

```sysb
let ε b = ...
let ? x = Some(b)
// ... x should not escape, because b should not escape ...
```

Our typing rules should take care of the case, where `b` is only allowed to be used borrowed,
so any datatype we create which stores borrowed data,
should not be allowed to escape.
[And thus can be stack allocated, if the size of the datatype is statically known.]

#todo[Add and explain more examples.]

#import "/types/definitions.typ": *

= Examples <examples>

In this section we discuss some examples to showcase the features of System B.

*Definitions*

/ Borrowed: binding with quantity ε
/ Owned: binding with quantity 1
/ Shared: binding with quantity ω

/ Consumed: when owned binding is "used up"

== Owning and sharing

The main idea of owning and borrowing in System B is [implemented] by quantity annotations on bindings.
To showcase our approach to linearity and borrowing, let us first look at three basic examples.

#side-by-side[
  ```sysb
  fn identity(1 x: a) -> a
    x
  ```
][
  ```sysb
  fn drop(1 x: a) -> ()
    ()
  ```
][
  ```sysb
  fn dup(ω x: a) -> (a, a)
    (x, x)
  ```
]

The `identity` function in System B is linear.
It takes one owned parameter of polymorphic type `a` and returns it.
However, owned bindings in System B are _affine linear_:
they can be used exactly once or not at all.
This is exemplified by `drop`, which also takes one owned parameter,
but does not do anything with it and simply returns the unit value.
In `dup`, although we need `x` twice, we do not make a distinction between every usage of more than one.
These bindings are _shared_ and denoted by ω.
Shared bindings can be used more then once.

There are three quantities available.
These are:
/ ε:
  borrowed
/ 1:
  consumed
/ ω:
  shared
The intuition behind the three different binding quantities is as follows.
Each quantity represents an amount of _resource tokens_ available for that binding.

For bindings of quantity 1, only one such token is available.
Therefore, it can only be used once or not at all (_affine linear_).
When a function parameter is annotated with this quantity,
we say it _consumes_ its argument.
These bindings can be passed to other functions which consume a resource token,
but cannot be passed to functions which need infinitely many resource tokens (of quantity ω).
Functions that _consume_ an argument, conceptually consume one resource token.
If there is only one token available, the binding will not be accessible after this consumption.

If there are infinitely many resource tokens available,
as is the case for bindings of quantity ω,
only one of infinitely many tokens is consumed,
and thus infinitely many tokens remain.

Even though the data that the binding refers to is shared,
from the perspective of this function, the binding is owned and can only be consumed once.
This design decision has two important consequences:
/ Functions taking owned parameters are can mutate this data in-place, iff it is unique _at runtime_:
  Owned parameters are not guaranteed to have _unique_ ownership of the referred data.
  Therefore, they cannot be mutate it in-place by default.
  However, iff the data is unique _at runtime_ it can be mutated in-place.
  This is because System B guarantees the binding, and thus the data, is used linearly.
  This runtime check can be inserted by the compiler,
  essentially generating two versions of the same function:
    one that mutates in-place when data is unique
    and one that copies when it is shared.
/ Shared data can be passed to owned parameters, forestalling the need to write separate functions for unique and shared data:
  Conceptually they just [pass on one resource token], out of the infinitely many that are available.

== Borrowing

One of the major [pain points] with (affine) linear types,
is the awkward [usage] of functions

//TODO: make example funny
#side-by-side[
  ```sysb
  fn length(1 s: String) -> (Nat, String)
    ...
  fn main()
    let s = "Hello world"
    let (l, s') = s1.length()
    // ...use new `s'`...
  ```
][
  ```sysb
  fn length(ε s: String) -> Nat
    ...
  fn main()
    let s = "Hello world"
    let l = s1.length()
    // ...still use `s`...
  ```
]

```sysb
fn lookup_1(1 ts: Tree(k, v), ω x: k) -> Option(v)
fn lookup_2(1 ts: Tree(k, v), ω x: k) -> (Tree(k,v), Option(v))
fn lookup_3(ε ts: Tree(k, v), ε x: k) -> Option(v)
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
      Leaf -> None
      Node(ls, k, v, rs) -> case x.compare(k)
        LT -> ls.lookup(x)
        EQ -> Some(v)
        GT -> rs.lookup(x)
  ```
][
  ```sysb
  fn lookup(ε t: Tree(k, v), ε y: k) -> Option(v)
    case_ε ts
      Leaf -> None
      Node(ls, k, v, rs) -> case x.compare(k)
        LT -> ls.lookup(x)
        EQ -> Some(v)
        GT -> rs.lookup(x)
  ```
]

Data is not regarded to be second class based on its type.
The focus is on binders and their quantity.
In this way, being second class is not a property of the type,
but a property of the binding,
and every type can be used in a first or second class manner depending on the [bind site].

Bindings of quantity ε only need an infinitely small amount of a resource token.
After a function call taking ε bindings,
We still have the original amount of resource tokens available.
We say these functions _borrow_ their arguments.
This borrow returns after the call ends.

Borrowed parameters can be passed as arguments to other functions that expect to borrow.
As we do not have a full resource token (only an infinitely small amount of it),
we cannot return a borrowed parameter from a function.

== Quantities on bindings

```sysb
fn rebind(qx x : a) -> ()
  let qy y = x
  ()
```

Annotations of quantities are put _on the binder_ and are not part of the type.
This means two things:
1. We have to annotate `let`-bindings as well.
2. We can pass _shared_ bindings as _consumed_ parameters.

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



== Filter

We propose a solution where we do not need mixing of linear and shared types.
Instead, we allow _borrowing_ of consumed _bindings_.
We introduce System B, a small functional programming language with quantity annotations on binders.
In System B, we can write `filter` like so:
```sysb
fn filter(1 xs: List(a), ε p: (ε x: a) -> Bool) -> List(a)
  case_1 xs
    Nil |-> Nil
    Cons(x, xx) |-> if { x | p(x) }
      then Cons(x, xx.filter(p))
      else xx.filter(p)
```
We see parameters in System B are annotated with one of two _quantities_:
1 for consumed (affine linear) usage, and
ε for borrowed (non-escaping) usage.
In our example, `xs` is _consumed_, and thus restricted to be used exactly once or not at all.
This means `xs` can be modified in-place.
Predicate function `p` and its parameter `x` are _borrowed_.
Borrowed binders can be used multiple times, but cannot _escape_ their scope.
They are thus safe to pass on to other functions,
but cannot be returned as a result or saved in data structures.
//
The borrowing block `{x| p(x) }` on line~4,
turns binding `x` from consumed into borrowed during the evaluation of the expression `p(x)`.
Now `p` can take `x` as a borrowed parameter.

== Closures

By allowing higher-order functions in System B,
we need to take special care of the available bindings when constructing closures.
Say, we write the following code filtering a list for multiples of 3:
```sysb
let ε m = 3
let 1 xs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let 1 ys = xs.filter(fn(x) x % m == 0)
// => ys == [3, 6, 9]
```
The lambda on line~3 closes of variable `m` from its outer scope.
As `filter` asks for a borrowed function,
we allow the construction of a borrowed lambda closing over borrowed variables.

== Deduplication

Borrowing of [owned] bindings need special care.
Take as an example deduplication of a list of integers,
which in our calculus has the following type:
```sysb
dedup : (1 xs: List(Int), ε ys: List(Int)) -> List(Int)
```
// fn dedup(1 xs: List(a), ε ys: List(a), ε eq: (a, a) -> Bool) -> List(a)
// fn dedup(1 xs: List(Int), ε ys: List(Int)) -> List(Int)
//   case_1 xs
//     Nil |-> Nil
//     Cons(x, xx) |-> if { x | ys.contains(x) }
//       then xx.dedup(ys)
//       else Cons(x, xx.dedup(ys))
// fn contains(ε xs: List(a), ε y: a) -> Bool
//   case_ε xs
//     Nil |-> False
//     Cons(x, xx) |-> if x == y
//       then True
//       else xx.contains(y)
// ```
The first list is the main subject to be deduplicated.
We thus need [ownership on `xs` and we consume $1$ resource token].
The second list is only for inspection.
Therefore, we only borrow `ys`.
The returned list may or may not be an in-place updated version of `xs`,
depending on the runtime uniqueness of `xs`.

Say, at the use site, we want to deduplicate a list by itself:
```sysb
let 1 ns = [1,2,3,4,5]
let 1 ms = ns.dedup(ns)
```
This should result in an error, as we cannot [consume] list `ns`,
possibly mutating it on the way,
while [borrowing] it at the same time.
System B takes care of this by removing the [linear] binding of `ns` from the context as soon as it [is asked for / consumed].
#footnote[Rust users would say the ownership _moved_ into `dedup`.]
Binding `ns` is not available any more, and consequently cannot be borrowed.

What if we defined `dedup` differently and swapped the arguments?
Its type would be:
```sysb
dedup : (ε ys: List(Int), 1 xs: List(Int)) -> List(Int)
```
Compiling the code in (X) should still result in an error.
System B prevents this.
[Owned] bindings cannot be borrowed automatically,
one has to denote the scope in which an [owned] binding is borrowed.
There are two options:
#block(inset: (y: 0.5em), //FIXME: generalise
  side-by-side[
    *Case 1*\ `{ ns | ns }.dedup(ns)`
  ][
    *Case 2*\ `{ ns | ns.dedup(ns) }`
  ]
)
In case 1 we borrow `ns` only for [the duration of passing the first parameter] and immediately return it.
Borrowed bindings are second class and therefore cannot be returned from a block.
This case results in an error.// that `ns` cannot be returned [consumed] as it is only available borrowed.

In case 2 we borrow `ns` during the whole call of `dedup`.
It is completely fine now to pass `ns` as the first parameter.
However, the second parameter of `dedup` [consumes] its argument,
but only an ε amount of `ns` is available.
This case will also result in an error.// that `ns` cannot be consumed as it is only available borrowed.

== Datatypes

```sysb
let ε borrowed-data = ...
let ? x = Some(borrowed-data)
... x shouldn't escape, because `borrowed-data` shouldn't escape ...
```

Our typing rules should take care of this case, where `borrowed-data` is only allowed to be used borrowed,
so any datatype we create which stores borrowed data,
should not be allowed to escape.
[And thus can be stack allocated, if the size of the datatype is statically known.]
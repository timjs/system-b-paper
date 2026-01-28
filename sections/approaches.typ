#import "/lib/basic/commands.typ": *

= Related approaches <sec:approaches>

== Linear Haskell

Let us compare our implementation of `filter` from @exm:filter
with Linear Haskell @journals-pacmpl-BernardyBNJS18:
#[
  #set raw(lang: "haskell")
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
  The pattern match on `xs` owns the value, and makes the head `x` and tail `xx` also linearly available.

  Now we immediately see a problem:
  `p` needs to be applied to each element of the list and also be threaded through all calls to `filter`.
  We have to make `p` available more then once,
  forcing us to incorporate unrestrictedness into our type system.
  Linear Haskell is able to express this mixture:
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
  Exactly this is what we want to prevent with System B.
]

== Oxidized OCaml

In Oxidized OCaml, we can write a definition that explicitly allocates the list on the stack:
```ocaml
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

#todo[Explain this more]

// In case of stack allocation, the layout would look something like this.
// #table(columns: 1, align: (center,),
//   $n--$,
//   $f$,
//   $"Nil"$,
//   $f(n)$,
//   $arrow.hook.tl$,
//   $f(n-1)$,
//   $arrow.hook.tl$,
//   $dots.v$,
//   $f(0)$,
//   $arrow.hook.tl$,
// )

== Koka

#todo[Extend section]

Koka has _fully in-place_ and _functional but in-place_ functions:
```koka
fip fun f(x_1: τ_1, ...; y_1: σ_1, ...)
```
Here all ```koka x```'s are owned and checked for linear usage,
and  all ```koka y```'s are borrowed.
The equivalent in System B would be:
```sysb
fn f(1 x_1: τ_1, ..., ε y_1: σ_1, ...)
```

== Rust

#todo[Introduce `filter-map` example]
// We'd like to invert the argument Rust makes about borrowing:
// If and only if a value is used borrowed, it cannot escape the function,
// and therefore it can be allocated on the stack.

```sysb
fn filter-map(1 xs: List(a), ε f: (1 x: a) -> Option(b)) -> List(b)
  case_1 xs
    Nil -> Nil
    Cons(x, xx) -> case_1 f(x)
      None -> xx.filter-map(f)
      Some(y) -> Cons(y, xx.filter-map(f))
```

#todo[Explain and compare `filter-map` example]
- We can write a functional specification of this routine.
  Conceptually, we get an immutable list and build and return a new immutable list.
- The list `xs` is owned.
  Therefore, the spine can be modified in-place if it happens to be unique at runtime.
- Every element `x` of the list is owned by `f`.
  Therefore, it can also be modified in-place if it is unique at runtime.

#todo[Compare to Rust's two versions, which both need an unique ```rust &mut``` reference]
```rust
fn retain      : (&mut Vec<a>, f: FnMut(&a)      -> bool) -> () {...}
fn retain_mut : (&mut Vec<a>, f: FnMut(&mut a) -> bool) -> () {...}
```

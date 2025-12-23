#import "/lib/basic/commands.typ": verdicts

= Related approaches <sec:approaches>

== Linear Haskell

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
The pattern match on `xs` owns the value, and makes the head `x` and tail `xx` also linearly available.

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

== Koka

```koka
fip fun f(x_1: τ_1, ..., x_n: τ_n; y_1: σ_1, ..., y_n: σ_n)
```
Here ```koka x_i``` are all owned and checked for linear usage,
and  ```koka y_i``` are all borrowed.
The equivalent in System B is:
```sysb
fn f(1 x_1: τ_1, ..., 1 x_n: τ_n, ε y_1: σ_1, ..., ε y_n: σ_n)
```

== Rust

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
  + The list `xs` is used _consumed_ [linearly, not affine, the size stays the same...].
    Therefore, the spine can be modified in-place if it happens to be _unique_ at runtime.
  + Every element `x` of the list is used _consumed_ by `f`.
    Therefore, it can also be modified in-place if it is _unique_ at runtime.
]

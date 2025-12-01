#import "/lib/basic/commands.typ": verdicts

= Examples <examples>

In this section we discuss some examples to showcase the features of System B.

== Haskell example

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
Therefore, the call `p x` on line~3 owns `x`,
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

=== Solution

We propose a solution where we do not need mixing of consumed and shared types.
Instead, we allow _borrowing_ of consumed _bindings_.
We introduce System B, a small functional programming language with quantity annotations on binders.
In System B, we can write `filter` like so:
```koka
fun filter(1 xs: list<a>, ε p: (ε x: a) -> bool) -> list<a>
  match 1 xs
    Nil -> Nil
    Cons(x, xx) -> if {x| p(x) }
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

By allowing higher-order functions in System B,
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
== Simple owning and sharing functions

When returning a value $v$ from a function, there can be several cases.
Value $v$ is:

1.
 a primitive value $p$; <case-prim>
2.
 a compound value, where $v$: <case-comp>
    1.
 has a _statically known_ size; <case-comp-stc>
    2.
 is _dynamically_ sized; <case-comp-dyn>
3.
 a reference to another value, so actually a location $l$, where $v$: <case-ref>
    1.
 is allocated on the _heap_; <case-ref-heap>
    2.
 is allocated on the _stack_: <case-ref-stack>
        1.
 in the _caller's_ stack frame or even before that; <case-ref-stack-caller>
        2.
 in the _callee's_ stack frame.
<case-ref-stack-callee>

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
  + The list `xs` is used _consumed_ [linearly, not affine, the size stays the same...].
    Therefore, the spine can be modified in-place if it happens to be _unique_ at runtime.
  + Every element `x` of the list is used _consumed_ by `f`.
    Therefore, it can also be modified in-place if it is _unique_ at runtime.
]



= Scratch

== Simple owning and sharing functions

When returning a value $v$ from a function, there can be several cases.
Value $v$ is:

1. a primitive value $p$; <case-prim>
2. a compound value, where $v$: <case-comp>
    1. has a _statically known_ size; <case-comp-stc>
    2. is _dynamically_ sized; <case-comp-dyn>
3. a reference to another value, so actually a location $l$, where $v$: <case-ref>
    1. is allocated on the _heap_; <case-ref-heap>
    2. is allocated on the _stack_: <case-ref-stack>
        1. in the _caller's_ stack frame or even before that; <case-ref-stack-caller>
        2. in the _callee's_ stack frame. <case-ref-stack-callee>

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

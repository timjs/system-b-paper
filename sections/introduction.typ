#import "/lib/basic/commands.typ": rephrase

= Introduction

We describe the design space for safe memory management in programming languages along two orthogonal axes: _efficiency_ and _polymorphism_.

The efficiency axis measures the runtime cost of memory management.
At one extreme, memory safety is ensured with minimal programmer burden but incurs significant runtime overhead –
such as large memory footprints, global pauses, or frequent heap traversals.
At the other extreme, memory is managed with negligible runtime cost.
In this case however, the type discipline is either much more strict, often imposing constraints that limit flexibility;
or non existent, and memory management is left completely to the programmer.

The polymorphism axis measures the ability to abstract over memory management strategies.
In the ideal case, a single function definition could be specialized into multiple implementations,
each using a different memory management discipline, without requiring changes to the source.
In less polymorphic systems, functions must be rewritten for each ownership mode or allocation method.
These stricter disciplines can also lead to code duplication.
Then logically identical functionality must be expressed in multiple forms to accommodate different ownership or allocation requirements.
This duplication increases code size and reduces maintainability.

This work proposes a type system that classifies bindings into three ownership modes: _borrowed_, _consumed_, and _shared_.
Borrowed bindings cannot escape their scope:
ownership remains with the caller, and no #rephrase[runtime ownership tracking] is required.
Owned bindings must be used at most once,
enabling reuse of memory when unique ownership can be confirmed at runtime.
Shared bindings have unrestricted usage and may be freely returned or stored.

By distinguishing these ownership modes,
the type system enables both safety and flexibility:
- it supports higher-order reasoning about ownership,
- allows the compiler to generate multiple optimized implementations from a single function body,
- and facilitates efficient resource reuse when possible.
Furthermore, when a non-escaping value has statically known size,
the compiler can automatically allocate it on the stack, avoiding heap allocation entirely.

== Languages on the axes

[TS: Nog wat inkorten]

Our two-axis framework for reasoning about safe memory management can be illustrated
by positioning existing programming languages according to their efficiency and polymorphism characteristics.

On the efficiency axis, fully garbage-collected languages such as Haskell or OCaml sit toward the lower end:
they provide strong safety guarantees with minimal programmer effort,
but incur significant runtime overhead due to stop-the-world garbage collection, large heap footprints, and costly root scans.
At the opposite end, system languages such as C and Zig achieve extremely low runtime overhead
by leaving memory management entirely in the hands of the programmer, but offer no safety guarantees.
Restricting our view to safe languages, Rust, Cogent, and Clean approach the upper end of the axis.
These languages enforce strict ownership and lifetime rules, eliminating many categories of runtime overhead.
However, these strict typing rules can limit flexibility and, without additional polymorphism,
lead to code duplication when supporting multiple memory usage patterns.

The polymorphism axis reflects a language’s ability to abstract over memory management strategies.
#rephrase[Languages like Clean exhibit low polymorphism in this respect:
  programmers must write separate functions for uniquely owned data and for shared data.]
Rust, while offering more flexibility, still requires distinct function signatures and implementations for different allocation strategies –
stack versus heap allocation, boxed versus reference-counted values versus atomic reference counting, copy-on-write types, and so on.
This lack of polymorphism forces developers to duplicate logically identical code across ownership and allocation variations,
increasing maintenance effort.

Koka represents an interesting point between the extremes on both axes.
It employs reference counting to ensure deterministic and precise reclamation of memory.
When a value is no longer reachable, it is freed immediately.
A sophisticated static analysis [cite Perseus] minimizes the cost of reference count adjustments,
and runtime support allows reuse of uniquely owned memory cells, reducing allocation churn.
Koka’s existing type system can reason about first-order borrowed and owned parameters,
enabling some degree of polymorphism, but falls short when it comes to higher-order parameters.

The type system proposed in this work extends Koka’s capabilities to reason about borrowed, owned, and shared bindings for higher-order functions.
This enables multiple optimized implementations to be generated from a single function definition,
bridging part of the gap toward the high-polymorphism end of the axis without sacrificing efficiency.
In particular, it allows stack allocation for non-escaping values of known size,
and safe reuse of memory when unique ownership can be established at runtime.

=== Shorter

The two-axis framework for safe memory management can be illustrated by placing existing languages along the efficiency and polymorphism dimensions.

On the efficiency axis, fully garbage-collected languages such as Haskell or OCaml sit near the lower end:
they ensure safety but incur runtime costs from stop-the-world pauses, heap traversals, and large memory footprints.
At the opposite end, C and Zig achieve minimal overhead but provide no safety guarantees.
Among safe languages, Rust, Cogent, and Clean approach the high-efficiency end, using strict ownership and lifetime rules to minimize runtime cost—though this strictness often limits flexibility.

On the polymorphism axis, Clean requires separate function versions for uniquely owned versus shared data.
Rust offers more flexibility but still demands different function signatures and implementations for various allocation strategies
(e.g., stack, heap, boxed, reference-counted, atomic, copy-on-write).
This leads to code duplication when the same logic must be adapted for different memory modes.

Koka lies between the extremes on both axes.
It uses reference counting for deterministic reclamation,
with static analysis [cite Perseus] to reduce counting overhead and runtime reuse of uniquely owned cells to cut allocations.
Its current type system supports first-order borrowed and consumed parameters;
the type system proposed here extends this to higher-order parameters and introduces explicit borrowed, consumed, and shared modes.
This allows the compiler to generate optimized implementations from a single function body and to automatically allocate non-escaping, sized values on the stack.

== Contributions

//TODO

== Organisation

//TODO

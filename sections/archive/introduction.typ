
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

// == Motivation
...

== Contributions
The combination of linear types and borrowing is a promising approach
to incorporate functional programming techniques like higher-order functions and immutable data types
into systems programming.
By annotating binders instead of types,
there is no stratification of linear and non-linear types.
Every type can be owned, and therefore be mutated in-place, or borrowed.
Also, as borrowed values cannot escape their scope, they coincide with being second class.

In the remaining of this paper, we dive into the System B language and its properties.
We present:

- the language System B, a small functional programming language with quantity annotations on binders;
- a bidirectional type system for System B keeping track of these quantities, combining affine linear types with borrowing, mechanised in Agda; //of its soundness [and completeness];
- a small-step operational semantics for System B, showing all allocations can be done on the stack;
- an extension of System B with the notion of _shared_ binders, called System Bs.

==== Organisation

The remaining of this paper is structured as follows.
In the next section, @examples, we show motivating examples of System B,
discussing the implications of our design.
Thereafter, we formalise the syntax and semantics of System B in @theory.
Section @metatheory contains metatheoretical properties of System B.
After discussing related work in @related-work,
we conclude and present future work in @conclusion.

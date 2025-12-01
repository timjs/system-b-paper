#import "/lib/basic/logos.typ"
#show: logos.init

/*
#show terms: text.with(fill: gray)

/ Context:
  - What is the broad context of the work?
  - What is the importance of the general research area?
*/

Safe memory management is crucial in programming languages, balancing runtime overhead, flexibility, and programmer effort. Existing approaches either impose runtime overhead (e.g., garbage collection) or restrict flexibility (e.g., strict ownership systems) which often leads to code duplication.

/*
/ Inquiry:
  - What problem or question does the paper address?
  - How has this problem or question been addressed by others (if at all)?
*/

This work addresses the challenge of designing a system that supports performant and polymorphic memory management in a functional language with higher-order functions.
// Prior systems like Koka provide partial solutions but lack full higher-order ownership polymorphism.
/*
/ Approach:
  - What was done that unveiled new knowledge?
*/
We present System B, a calculus distinguishing _borrowed_, _consumed_, and _shared_ bindings, enabling multiple optimized implementations from a single function definition. Bindings that are only borrowed, coincide with _second class values_ and can be allocated on the stack. While providing a functional interface, _uniquely owned_ memory at runtime is safely reusable. We demonstrate System B's feasibility by positioning it along efficiency and polymorphism axes relative to existing languages.
/*
/ Knowledge:
  - What new facts were uncovered?
  - If the research was not results-oriented, what new capabilities are enabled by the work?
*/
We demonstrate System B's feasibility by positioning it along efficiency and polymorphism axes relative to existing languages.//, showing it bridges the gap between safety, performance, and abstraction.

/*
/ Grounding:
  - What argument, feasibility proof, artifacts, or results and evaluation support this work?
*/
Our (ongoing) formalisation of System B in the Agda proof assistent ensures soundness and completeness of our type system
and safety with respect to a resource aware operational semantics.
/*
/ Importance:
  - Why does this work matter?
*/
We believe System B hits a sweet spot in safe, maintainable, and efficient code,
without compromising on functional language features.
// offering a framework for designing languages that unify these traditionally conflicting goals.

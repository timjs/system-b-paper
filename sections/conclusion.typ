= Conclusion <conclusion>

== Future work

We see multiple options for future work.

- Add System B to an existing programming language like Koka.
  Koka already supports _fully in-place_ (FIP) @journals-pacmpl-LorenzenLS23 and _functional but in-place_ (FBIP) @conf-pldi-ReinkingXML21 annotations,
  but does not support borrowing and owning annotations on higher order functions.
- Compiling System B to Rust, using reference counted smart pointers (using ```rust std::rc::Rc``` or similar) would be worth investigating.
  Not only would this approach validate our work,
  we would be able to compile System B down to performant machine code.
  Also, it would be worth to compare performance and programmer effort between these two.
- Some types, such as file and socket handles, are not ment to be shared
  and should only be used owned of borrowed.
  Other types, such as substrings or array slices, are possibly ment to be truly second class.
  They should not be saved or returned and therefore only be bound borrowed.
  We would like to investigate the option to annotate types to restrict their possible binding quantities
  to accommodate these examples.
- Inference of borrowing regions and of quantities.
- (Linearly) owned data that can be manipulated by consuming but does not escape should be marked as such.
  This can be allocated on the stack as long as the size is statically known and the datatype cannot grow dynamically (such as linked lists).

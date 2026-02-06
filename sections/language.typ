#import "/lib/basic/commands.typ": many, more, most, maybe, grammar
#import "/lib/basic/bricks.typ": figure
#import "/types/definitions.typ": *
#import "/types/judgements.typ": *

#let short-grammars = true

= Language and semantics <theory>

== Notation

We write:\
  - $many(x, n)$ for an _ordered_ set of $x$es of length $n$, so $x_1, ..., x_n$;
  - $more(x)$ for an _unordered, possibly empty_ set of $x$es;
  - $most(x)$ for an _unordered, non-empty_ set of $x$es;
  - $maybe(x)$ for an _optional_ $x$.

== Language

@fig:syntax-expressions, @fig:syntax-types, @fig:syntax-values, and @fig:syntax-sugar
contain all grammar rules of System B.

#figure(caption: [Expression syntax])[$
  // grammar("Programs", p,
  //   more(d)\; e, "main"
  // ) \
  // grammar("Declarations", d,
  //   type(X, many(c^n (many(tau, n)), m)), "types",
  // ) \
  \ grammar("Expressions", e, short: #short-grammars,
    y, "lookup",
    borrow(more(y), e), "borrow",
    bind(q_0, x_0, e_0, e), "bind",
  )
  \ grammar("Expressions", e, short: #short-grammars, continuation: #true,
    apply(e_0, many(e, n)), "apply",
    define(many(y, k-1), pars(q, x, tau, n), e_0), "abstract",
  )
  \ grammar("Expressions", e, short: #short-grammars, continuation: #true,
    create(c, many(e, k)), "construct",
    match(q_0, e_0, arms(c, many(x, k), e, m)), "match",
  )
  \ grammar("Values", v^many(y, k), short: #short-grammars,
    define(many(y, k-1), pars(q, x, tau, n), e_0), "abstract",
    create(c, many(y, k)), "construct",
    y, "lookup",
  )
  // grammar("Basic values", b,
  //   tuple(many(b,n)), "tuple",
  //   variant(c, many(b,n)), "variant",
  //   ) \
  \ grammar("Identifiers", x\, y, short: #short-grammars)
  \ grammar("Arity", n\, m\, k, short: #short-grammars)
  \ grammar("Constants", c, short: #short-grammars)
$]<fig:syntax-expressions>
// #footnote[Note we have $b subset v subset a$]


#figure(caption: [Atomic expression syntax])[$
  \ grammar("Expressions", e, short: #short-grammars,
      bind(q, x, a, e), "bind",
      match(q, y, arms(c, many(x, k), e, m)), "match",
      a, "return",
  )
  \ grammar("Atomic expressions", a, short: #short-grammars,
      // y, "lookup",
      borrow(more(y), e), "borrow",
      apply(y_0, many(y,n)), "apply",
      v, "create",
  )
  \ grammar("Values", v, short: #short-grammars,
    y, "lookup",
    w, "writeable value",
  )
  \ grammar("Writeable values", w^many(y, k), short: #short-grammars,
    define(many(y, k-1), pars(q, x, tau, n), e), "abstract",
    create(c, many(y, k)), "construct",
  )
$]

#figure(caption: [Type syntax])[$
  \ grammar("Types", tau, short: #short-grammars,
    phi, "function type",
    delta, "data type",
    // List(tau), "list",
  )
  \ grammar("Function types", phi, short: #short-grammars,
    Function(many(qt(q, tau), n), tau_0), "function type",
  )
  \ grammar("Data types", delta, short: #short-grammars,
    Variant(many(create(c, many(tau, n)), m)), "sum type",
  )
  \ grammar("Quantities", q, short: #short-grammars,
    epsilon, "borrowed",
    1, "owned",
    omega, "shared",
  )
  \ grammar("Contexts", Gamma, short: #short-grammars,
    empty, "empty",
    Gamma\, par(q, x, tau), "binding",
    Gamma\, diamond^k, "reuse token",
  )
$]<fig:syntax-types>

#figure(caption: [Grammars for (heap) semantics])[$
  \ grammar("Expressions", e, short: #short-grammars,
    ..., "expressions",
    alloc(k, e), "allocate",
    free(k, e), "free",
    clone(y, e), "clone",
    drop(y, e), "drop",
  )
  \ grammar("Writeable values", w, short: #short-grammars,
    v^many(y,k), "value",
    diamond^k, "reuse token",
  )
$]<fig:syntax-values>

#figure(caption: [Sugar])[
  ```sysb
  x_0.f(x_1, ..., x_n))                       ~~>  f(x_0, x_1, ..., x_n)
  if e_0 then e_1 else e_2                 ~~>  case e_0 { True |-> e_1, False |-> e_2}
  ```
  // when { g_1 |-> e_1; ...; else |-> e_n }  ~~>  case g_1 { True |-> e_1, False |-> when { ...; else |-> e_n } } \
  // when { many(g |-> e, n); "else" |-> e_(n+1) } &~> "case" g_1 space { "True" |-> e_1; "False" |-> "when" { many(g |-> e, n-1);  "else" |-> e_(n+1)}} \
  // "use" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \

  // $
  //    x_0.f(many(x, n))   &~> f(x_0, many(x,n)) \
  //    "if" e_0 "then" e_1 "else" e_2         &~> "case" e_0 space { "True" |-> e_1, "False" |-> e_2} \
  //    "when" { g_1 |-> e_1; ...; "else" |-> e_n } &~> "case" g_1 space { "True" |-> e_1, "False" |-> "when" { ...; "else" |-> e_n } } \
  //    "when" { many(g |-> e, n); "else" |-> e_(n+1) } &~> "case" g_1 space { "True" |-> e_1; "False" |-> "when" { many(g |-> e, n-1);  "else" |-> e_(n+1)}} \
  //    "use" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
  // $
]<fig:syntax-sugar>

#pagebreak()

== Typing rules

#figure(caption: [Synthesizing type rules for System B])[$
  framed(synthesize(
    below(Gamma, arrow.t),
    below(e, arrow.t),
    below(q, arrow.t),
    below(tau, arrow.b),
    below(Gamma', arrow.b)
  )) \
  \ bold("Variables") \
  judgements.var.epsilon wide
  judgements.var.nu \
  judgements.var.sub \
  judgements.borrow.nu \
  judgements.bind.single \
  \ bold("Functions") \
  judgements.abs.epsilon.uncurried \
  judgements.abs.one.uncurried \
  judgements.abs.omega.uncurried \
  judgements.app.lambda.uncurried \
  judgements.app.omega.uncurried \
  \ bold("Datatypes") \
  judgements.construct.uncurried \
  // judgements.construct.uncurried \
  judgements.case.uncurried \
  \ bold("Memory") \
  judgements.memory.alloc wide
  judgements.memory.clone \
  judgements.memory.free wide
  judgements.memory.drop \
$]<fig:typing>

// #figure(caption: [Checking type rules for System B])[$
//   framed(check(
//     below(Gamma, arrow.t),
//     below(many(e, n), arrow.t),
//     below(many(q, n), arrow.t),
//     below(many(tau, n), arrow.t),
//     below(Gamma', arrow.b)
//   )) \
// $]

#figure(caption: [Spine typing rules for System B])[$
  framed(synthesizes(
    below(Gamma, arrow.t),
    below(many(e, n), arrow.t),
    below(many(q, n), arrow.t),
    below(many(tau, n), arrow.t),
    below(Gamma', arrow.b)
  )) \
  judgements.spine.empty \
  judgements.spine.rest \
$]<fig:typing-spine>

The algorithmic typing rules of System B are given in @fig:typing and @fig:typing-spine.
The typing relation $synthesize(Gamma, e, q, tau, Gamma')$ can be read as
#quote[
  making use of context $Gamma$, in quantity context $q$ expression $e$ yields type $tau$ and modified context $Gamma'$.
]
In the following subsections we explain these typing rules.

#todo[Introduce the term _quantity context_ properly.]

=== Variable lookup

Variable lookup comes in two flavours.
Owned bindings with quantity $1$ are looked up and removed from the context as shown in rule $"Var"_1$.
Borrowed and unrestricted bindings with quantities $epsilon$ and $omega$ respectively,
are looked up, but stay in the resulting context.
Rules $"Var"_mu$ define this for $mu in {epsilon, omega}$ simultaneously.
// $
//   rules.var.one \
//   rules.var.mu \
// $
We have a _weakening_ rule which states that unrestricted bindings can be used owned and borrowed freely.
// Rules $"Var"_pi$ also state that unrestricted bindings can be borrowed freely.
// #aside[
//   Equivalently, we could define weakening as a general rule on bindings instead of a rule for variable lookup.
//   However, this way our rule set would be nondeterministic.
//   $
//   grayed(rules.weak)
//   $
// ]
// $
//   rules.var.pi
// $

To allow owned bindings, that is bindings with quantity $1$, to be borrowed,
we need to do additional bookkeeping.
Borrows are only valid in a lexical region.
After this region ends, we restore the original quantity on the binding,
as shown in rule $"Bor"_1$.
// $
//   rules.borrow.one
// $
#todo[Add explanation why owned functions cannot be borrowed.]
Here, we need to take care borrowed bindings do not escape from this region.
Therefore, we check expression $e_0$ in an owned quantity context.
/*
_lift_ quantity $q$ of the expression surroundings to be an owned quantity.
That is, borrowed expression surroundings are lifted to unrestricted contexts,
the two owning quantities stay the same.
The definition of lifting is as follows.
$
  function(lift(dot) : "Quantity" -> "Quantity",
    lift(epsilon), omega,
    lift(q), q,
  )
$
*/

/*
  Alternatively, we could enforce explicit borrowing of unrestricted bindings, in the same way we do that for owned ones.
  We can change $"Borrow"_1$ to also include $omega$ bindings.
  Then, we need to alter $"Var"_pi$ to remove $epsilon$ as a free borrow.
  // $
  //   grayed(rules.var.weak\ rules.borrow.nu)
  // $
  This restricts the places where we can use explicit borrowing.
]
#todo[
  Is this good or bad? Could help in borrow inference: only there were owned variables are used...
]
*/

=== Functions

For function abstraction, we have three cases, one for each quantity.
Depending on the quantity of the expression surroundings,
anonymous function blocks have access to different sets of bindings.
/ $epsilon$:
  As we are in a borrowed expression surroundings, function blocks cannot be returned nor stored: they are _second-class_.
  Therefore, these blocks have access to all borrowed bindings as well as all unrestricted bindings.
  As they can be called multiple times (the code is borrowed and can be used multiple times),
  we cannot allow usage of owned bindings.
/ $omega$:
  For unrestricted expression surroundings the situation in different.
  As these function blocks are owned, they _can_ be stored or returned.
  Therefore, we need to make sure second-class bindings are not stored in its closure.
  Borrowed bindings should not escape, only unrestricted bindings are allowed.
/ $1$:
  Similarly, owned blocks are first-class and can be saved or returned,
  so we cannot close over borrowed bindings.
  However, as we know that the resulting closure can only be used _once_,
  in this case we can also allow access to owned bindings.
// $
//   rules.abs.epsilon.uncurried\
//   rules.abs.one.uncurried\
//   rules.abs.omega.uncurried\
// $

For the bodies of the abstractions, there are two things to keep in mind.
First, we should not allow to return bindings that are borrowed, so the quantity context of the body should be owning and cannot be $epsilon$.
Second, the body _should not know_ how many times its result will be used.
Take for example the identity function from @exm:identity.
// $
// declare("identity", arg(x, 1, tau), x) quad
// $
// which by definition [X] itself is unrestricted
// $
// bind(omega, "identity", closure(#none, arg(x, 1, tau), x), "").
// $
This does not mean the body of the abstraction should be checked in an $omega$ context.
We have binding $x$ owned in the context, we can return it, as it is owned.
However, how the result will be used is a responsibility of the caller.
This means, it suffices to check the body of an abstraction in a owned context.

To select bindings with the proper quantity from the context, we use _context filtering_ which is defined as follows.
#todo[Fix $q$ being once upright, once italic...]
$
  function(Gamma div q : "Context" times "Quantity" -> "Context",
    nothing div q, nothing,
    (Gamma with arg(x, q, tau)) div q, Gamma div q with arg(x, q, tau),
    (Gamma with arg(x, q', tau)) div q, Gamma div q,
  )
$

When functions are applied in an expression surroundings of quantity $q$,
the function itself needs to be available $q$ times.
/*
Quantities of the arguments are determined by the function's type signature.
// $
//   rules.wilt.uncurried \
// $
#todo[
  Is lowering really needed here?
  Calls can be just borrowed, that's probably enough.
  However, do we restrict or allow something when calls cannot be $omega$?
]

$
  function(lower(dot) : "Quantity" -> "Quantity",
    lower(omega), epsilon,
    lower(q), q,
  )
$
*/

Problems arise when owned  arguments are passed to functions.
Owned arguments are linear and could be returned by a function.
We need to make sure the returned value can also only be used once.
/*
  The identity function simply from @exm:identity returns its only parameter.
  The quantity of this parameter cannot be $epsilon$,
  as borrowed parameters cannot be returned from functions,
  so it should be owned.
  We could pick $omega$, but then we'd restrict ourselves because it cannot be used on owned arguments.
  Therefore, the sensible choice is to pick $1$.
  $
    declare("identity", arg(x, 1, tau), x)
  $
*/
Take for example:
```sysb
let 1 a = 42
let ω b = identity(a)
(b, b)
```
Variable $a$ is used by passing it to `identity`, the returned value $b$ however, is made available with quantity $omega$.
Therefore, we are allowed to create a pair of two $b$'s and we've indirectly duplicated $a$...

There are two solutions to this problem:
1. Functions with owned parameters can only be called in a owned quantity context.
2. Functions with owned parameters, when called in an unrestricted quantity context, need their arguments to be unrestricted as well.

The first option would be a severe restriction, as many functions with owned parameters should be usable on unrestricted arguments, and the results would need to be used owned,
so we go for the second option and restrict the quantities $many(q, n)$ in rule $"App"_omega$:
// $
//   rules.app.pi.uncurried \
//   rules.app.omega.uncurried \
// $

$
  function(freeze(dot) : "Quantity" -> "Quantity",
    freeze(1), omega,
    freeze(q), q,
  )
$


=== Datatypes

When creating datatypes in a $q$-context, we check each actual parameter in the same $q$-context.
Allowing to create datatypes in a borrowed context,
gives rise to optimisations like stack allocation.
// $
//   rules.construct.uncurried \
// $
Note the similarities and differences between the $"App"$ rules and rule $"Con"$:
- Both lookup the type of the function or constructor,
  which directs the type of the arguments and the returntype of the application or construction.
- In application, the quantities of the arguments are directed by the function type,
  while in construction, these quantities are directed by the expression surroundings.

When destructuring datatypes, we have two quantities to take into account:
- The quantity in which the whole destructuring expression is going to be evaluated.
  We call this the _quantity context_.
  #todo[Explain this earlier]
- The quantity of the matched parts of the datatype, that are made available in continuation of the program.
  This is also the quantity that the scrutiny needs to be available for.
  To accommodate for this,
  we annotate destructuring constructs in our language with an addition quantity $q_0$.
  #todo[Add example on this in @sec:examples]
// $
//   rules.match.uncurried
// $

Because now we have multiple branches that can be taken, we need to _merge_ the resulting contexts of each branch and remove the freshly introduced bindings if still existing.
As after branching, contexts can only differ in removed owned bindings,
merging two contexts is simply set intersection.
#todo[Check this! Aren't we passing let-bound variables to the next argument?]

=== Spine typing

#todo[Explain spine typing rules from @fig:typing-spine]

/*

=== Tuples

Tuples are _unboxed_, which means they don't allocate space on the heap and therefore do not store their components in the way datatypes do.
Therefore they their components can be borrowed.
// $
//   rules.pair.uncurried \
// $
Due to this design decision, we can define value binding in terms of tuple creation and destruction.
#sidenote[
  Otherwise we would not be able to _reborrow_ a variable, that is, bind a borrowed variable to a new name.
  ```kotlin
  fun reborrow(ε x : a)
      val ε y = x
      ...
  ```
]
$
  shorthands(:=,
    val(q, x, e, c), val(q, (x), (e), c), "value binding",
  )
$

For the splitting of tuples, we ask an expression $e_0$ to be available for quantity $q_0$.
The resulting bindings $x_1$ and $x_2$ are then made available for the same quantity $q_0$ in the remaining part of the program.
Note we need to remove these bindings from the resulting context $Gamma_2$ if they still exist.
This is similar to the way we handle matching on datatypes.
$
  rules.split.uncurried
$

=== Built-ins

Note that pre-defined functions, as well as any top-level functions, can be used unrestricted.
So their body is checked in a surrounding of quantity $omega$.
$
  shorthands(":",
    "fold"_q, ->(qt(q, List(tau_1)), qt(1, tau_2), qt(epsilon, ->(qt(q, tau_1), qt(1, tau_2), tau_2)), tau_2), "fold list",
  ) \
  shorthands(":",
    "Nil"_tau, List(tau), "nil list",
    "Cons", ->(tau, List(tau), List(tau)), "cons list",
  ) \
  shorthands(":=",
    "Bool", variants("False"(), "True"()), "boolean type",
    "Option"(tau), variants("None"(), "Some"(tau)), "option type",
    "Result"(tau_1, tau_2), variants("Wrong"(tau_1), "Right"(tau_2)), "either type",
  ) \
$

*/

== Semantic rules

// #let evaluate(from, into) = {
//   let (fs1, hs1, ss1, is1, q1, e1) = from
//   let (fs2, hs2, ss2, is2, q2, e2) = into
#let evaluateFHSI(fs1, hs1, ss1, is1, q1, e1, fs2, hs2, ss2, is2, q2, e2) = {
  $
    fs1 meta(|) hs1 meta(|) ss1 meta(|) is1 meta(tack.r) q1 meta(dot) e1
    space &meta(-->) space
    fs2 meta(|) hs2 meta(|) ss2 meta(|) is2 meta(tack.r) q2 meta(dot) e2
  $
}


#let evaluateHS(hs1, ss1, q1, e1, hs2, ss2, q2, e2) = {
  $
    hs1 meta(|) ss1 meta(tack.r) q1 meta(dot) e1
    space &meta(-->) space
    hs2 meta(|) ss2 meta(tack.r) q2 meta(dot) e2
  $
}
#let evaluateRow(hs1, ss1, is1, q1, e1, hs2, ss2, is2, q2, e2) = (
    $hs1$, $meta(|)$, $ss1$, $meta(|)$, $is1$, $meta(|)$, $q1$, $meta(dot)$, $e1$,
    $space meta(-->) space$,
    $hs2$, $meta(|)$, $ss2$, $meta(|)$, $is2$, $meta(|)$, $q2$, $meta(dot)$, $e2$,
)
#let evaluations(..rules) = {
  let rows = rules.pos().map( (row) => evaluateRow(..row) ).join()
  table(columns: 19, align: left, inset: 0pt, column-gutter: 0.5em, row-gutter: 1em,
  ..rows)
}

#let state((hs, ss, qs, es)) = {
  // $ hs meta(bar.v) ss meta(bar.v) cs meta(tack.r) qs meta(dot) es $
  $
    #let mq = $q$
    #let me = $e$
    hs meta(bar.v)
    ss meta(tack.r)
    qs meta(dot)
    es
  $
  // let sep = $space.thin bar.v space.thin$
  // $ hs meta(sep) ss meta(sep) cs meta(sep) qs meta(sep) es $
}
#let evaluate(from, into, ..args) = rule(
  state(from),
  $meta(-->)$,
  state(into),
  ..args,
)

Notes:
- always $r >= 1$
- only `let` changes/switches $q$-context (temporarily)
- borrow and call create a fresh stack frame

#figure(caption: [Reference counted heap and stack semantics for System B])[$
  \ framed(evaluate(
    H, S, q, e;
    H', S', q', e';
  ))

  \ \ bold("Evaluation")

  // \ judgement("Evaluate",
  //     evaluate(
  //       H, S, q, e_0;
  //       H, S, q, e_1;
  //     ),
  //     evaluate(
  //       H, S, q, E[e_0];
  //       H, S, q, E[e_1];
  //     ),
  //   )

  \ judgement("Bind",
      evaluate(
        H, S, q_0, a_0;
        H', S', q_0, y_0;
      ),
      evaluate(
        H, S, q, bind(q_0, x_0, a_0, e);
        H', S', q, substitute(e, x_0, y_0);
      ),
    )

  \ judgement("Borrow",
      evaluate(
        H, S :: empty, q, e_0;
        H', S :: F', q, y';
      ),
      evaluate(
        H, S, q, borrow(more(x), e_0);
        H', S, q, y';
      ),
    )

  \ judgement("Call",
      evaluate(
        H, S :: empty, q, substitutes(e_0, x, y, n);
        H', S :: F', q, y';
      ),
      evaluate(
        H, S, q, y_0(many(y, n));
        H', S, q, y';
      ),
      where: ref(y_0, define(many(z, k-1), many(par(q, x, tau), n), e_0)) in H union S union E,
    )
  $ $

  // \ \ & bold("Binding")
  // \   & "No variable rules!"
  // \ evaluate(
  //     H, S, q, bind(q_0, x_0, y_0, e);
  //     H, S, q, substitute(e, x_0, y_0);
  //   ),

  \ \ & bold("Storing")
  \ evaluate(name: "Store"_epsilon,
      H, S :: F, epsilon, w^many(y, k);
      H, S :: F with ref(y_0, w^many(y, k)), epsilon, y_0;
    )
  \ evaluate(name: "Store"_(1,omega),
      H with diamond^k, S, mu, w^many(y, k);
      H with ref(y_0, ri: 1, w^many(y, k)), S, mu, y_0;
      condition: mu in {1, omega},
    )

  \ \ & bold("Allocating")
  \ evaluate(name: "Alloc",
      H, S, q, alloc(k, e);
      H with diamond^k, S, q, e;
    )
  \ evaluate(name: "Free",
      H with diamond^k, S, q, free(k, e);
      H, S, q, e;
    )
  \ evaluate(name: "Clone",
      H with ref(y, ri: r, w), S, q, clone(y, e);
      H with ref(y, ri: r+1, w), S, q, e;
    )
  \ evaluate(name: "Drop"^(>1),
      H with ref(y, ri: r, w), S, q, drop(y, e);
      H with ref(y, ri: r-1, w), S, q, e;
    )
  \ evaluate(name: "Drop"^(=1), // "-Free"
      H with ref(y, ri: 1, w), S, q, drop(y, e);
      H, S, q, e;
    )

  \ \ & bold("Matching")
  \ evaluate(name: "Match"_epsilon, // "-Borrow",
    H, S, q, match(epsilon, y_0, arms(c, many(x, k), e, m));
    H, S, q, substitutes(e_i, x, y, k_i);
    where: ref(y_0, ri: r, create(c_i, many(y, k_i))) in H union S
  )
  \ evaluate(name: "Match"_1^(>1), // "-Alloc",
    H with ref(y_0, ri: r, create(c_i, many(y, k_i))), S, q, match(1, y_0, arms(c, many(x, k), e, m));
    H with ref(y_0, ri: r-1, create(c_i, many(y, k_i))) with diamond^k, S, q, substitutes(e_i, x, y, k_i);
  )
  \ evaluate(name: "Match"_1^(=1), // "-Reuse",
    H with ref(y_0, ri: 1, create(c_i, many(y, k_i))), S, q, match(1, y_0, arms(c, many(x, k), e, m));
    H with diamond^k, S, q, substitutes(e_i, x, y, k_i);
  )
  \ evaluate(name: "Match"_omega^(>1), // "-Drop",
    H with ref(y_0, ri: r, create(c_i, many(y, k_i))), S, q, match(omega, y_0, arms(c, many(x, k), e, m));
    H with ref(y_0, ri: r-1, create(c_i, many(y, k_i))), S, q, substitutes(e_i, x, y, k_i);
  )
  \ evaluate(name: "Match"_omega^(=1), // "-Free",
    H with ref(y_0, ri: 1, create(c_i, many(y, k_i))), S, q, match(omega, y_0, arms(c, many(x, k), e, m));
    H, S, q, substitutes(e_i, x, y, k_i);
  )

  /*
  \ & bold("Operations")
  \ evaluate(name: "Reserve",
    H, S :: s, Reserve(k)\; o, q, e;
    H, S :: s\, ref(a_0, #none, diamond^k), o, q, e;
  )
  \ evaluate(name: "Push",
    H, S, Push\; o, q, e;
    H, S :: empty, o, q, e;
  )
  \ evaluate(name: "Pop",
    H, S :: s, Pop\; o, q, e;
    H, S, o, q, e;
  )
  \ evaluate(name: "Alloc",
    H, S, Alloc(k)\; o, q, e;
    H\, ref(a_0, 0, diamond^k), S, o, q, e;
  )
  \ evaluate(name: "Free",
    H\, ref(a_0, 0, diamond^k), S, Free(k)\; o, q, e;
    H, S, o, q, e;
  )
  \ evaluate(name: "Clone",
    H\, ref(a_0, r,   u^many(a,k)), S, Clone(a_0)\; o, q, e;
    H\, ref(a_0, r+1, u^many(a,k)), S, o, q, e;
  )
  \ evaluate(name: "Drop"_1,
    H\, ref(a_0, 1, u^many(a,k)), S, Drop(a_0)\; o, q, e;
    H\, ref(a_0, 0, diamond^k), S, Free(k)\; Drop(many(a,k))\; o, q, e;
  )
  \ evaluate(name: "Drop"_(r+1),
    H\, ref(a_0, r+1, u^many(a,k)), S, Drop(a_0)\; o, q, e;
    H\, ref(a_0, r, diamond^k), S, o, q, e;
  )
  \ evaluate(name: "Reuse"_1,
    H\, ref(a_0, 1, u^many(a,k)), S, Reuse(a_0)\; o, q, e;
    H\, ref(a_0, 0, diamond^k), S, Drop(many(a,k))\; o, q, e;
  )
  \ evaluate(name: "Reuse"_(r+1),
    H\, ref(a_0, r+1, u^many(a,k)), S, Reuse(a_0)\; o, q, e;
    H\, ref(a_0, r+1, u^many(a,k)), S, Alloc(k)\; o, q, e;
  )
  \
  \ & bold("Expressions")
  \ evaluate(name: "Store"_epsilon,
    H, S :: s\, ref(a_0, #none, diamond^k), empty, epsilon, u^many(a, k);
    H, S :: s\, ref(a_0, #none, u^many(a, k)), empty, epsilon, a_0
  )
  \ evaluate(name: "Store"_1,
    H\, ref(a_0, 0, diamond^k), S, empty,  1, u^many(a, k);
    H\, ref(a_0, 1, u^many(a, k)), S, empty, 1, a_0;
  )
  \ evaluate(name: "Store"_omega,
    H\, ref(a_0, 0, diamond^k), S, empty, omega, u^many(a, k);
    H\, ref(a_0, 1, u^many(a, k)), S, Clone(many(a,k)), omega, a_0;
  )
  \ evaluate(name: "Alloc"_epsilon,
    H, S, empty, epsilon, u^many(a, k);
    H, S, Reserve(k), epsilon, u^many(a, k);
  )
  \ evaluate(name: "Alloc"_(1,omega), condition: mu in {1, omega},
    H, S, empty, mu, u^many(a, k);
    H, S, Alloc(k), mu, u^many(a, k);
  )

  \ & bold("")
  \ evaluate(name: "Bind",
    H, S, empty, q, bind(q_0, x_0, a_0, e);
    H, S, empty, q, subst(e, x_0, a_0);
  )

  \ evaluate(name: "Borrow",
    H, S, empty, q, borrow(most(x), e);
    H, S, Push, q, scope(e);
  )

  \ evaluate(name: "Call"_epsilon,
    H, S, empty, epsilon, applies(a_0, a, n);
    H, S, #highlight($Clone(many(a,k))$)\; Push, epsilon, scope(substs(e, x, a, n));
    where: ref(a_0, #none, define(many(a,k), many(x,n), e) in H union S union F)
  )
  \ evaluate(name: "Call"_1,
    H, S, empty, 1, applies(a_0, a, n);
    H, S, Drop(a_0)\; Push, 1, scope(substs(e, x, a, n));
    where: ref(a_0, 1, define(many(a,k), many(x,n), e) in H)
  )
  \ evaluate(name: "Call"_omega,
    H, S, empty, omega, applies(a_0, a, n);
    H, S, Clone(many(a,k))\; Drop(a_0)\; Push, omega, scope(substs(e, x, a, n));
    where: ref(a_0, r, define(many(a,k), many(x,n), e) in H)
  )
  \ evaluate(name: "Call"_(1,omega),
    H, S, empty, (1,omega), applies(a_0, a, n);
    H, S, Clone(many(a,k))\; Drop(a_0)\; Push, (1,omega), scope(substs(e, x, a, n));
    where: ref(a_0, r, define(many(a,k), many(x,n), e) in H)
  )

  \ evaluate(name: "Return",
    H, S, empty, q, scope(a);
    H, S, Pop, q, a;
  )
  // \ evaluate(name: "Return"_(epsilon,1), condition: mu in {epsilon, 1},
  //   H, S, empty, mu, scope(a);
  //   H, S, Pop, mu, a;
  // )
  // \ evaluate(name: "Return"_omega,
  //   H, S, empty, omega, scope(a);
  //   H, S, Clone(a)\; Pop, omega, a;
  // )

  // \ evaluate(name: "Call",
  //   H, ref(a_0, r, fn(many(x,n)), )
  // )
  */
$]<fig:semantics>

@fig:semantics contain our reference counted heap and stack semantics.

#todo[
  There are some problems with our operation semantics...
  - We cannot make sure inserted `clone` and `drop` operations are safe to insert or not. So how to prove correctness?
  - Because these semantics handle operations separate from expressions, proving preservation is on one hand easy (we only need to take care of basic expressions), but on the other hand incomplete (as we cannot prove correctness of the operations with respect to the typing system).

  What we probably need to do is to make our type system truly linear (not affine linear).
  That is, in the calculus the operations `drop`, `clone`, `borrow`, `alloc`, and `free` need to be part of _expressions_.
  They should be checked by type system for proper usage.
  (Off course, they can be inserted by some algorithm, like Perseus, but in this paper, they should be inserted by hand.)
  This is needed to prove _preservation_ of our semantics with respect to our typing rules, but it would change our typing rules quite a bit...
]

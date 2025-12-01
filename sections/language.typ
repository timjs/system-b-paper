#import "/lib/basic/commands.typ": many, more, most, maybe
#import "/lib/basic/commands.typ": grammar
#import "/types/definitions.typ": *
#import "/types/judgements.typ": *

= Language and semantics <theory>

== Notation

// #show math.upright: text

$
   x_0.f(many(x, n))                      &~> f(x_0, many(x,n)) \
   "if" e_0 "then" e_1 "else" e_2         &~> "case" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "when" { e_0 |-> e_1; "else" |-> e_2 } &~> "case" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "with" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
  //  "when" { many(p |-> e, n) "else" |-> e_(n+1) } &~> "case" p_1 space { "True" |-> e_1; "False" |-> "case" p_2 space { "True" |-> e_2; "False" |-> ...
}} \
$

== Language

We write:\
  - $many(x, n)$ for an _ordered_ set of $x$es of length $n$, so $x_1, ..., x_n$;
  - $more(x)$ for an _unordered, possibly empty_ set of $x$es;
  - $most(x)$ for an _unordered, non-empty_ set of $x$es;
  - $maybe(x)$ for an _optional_ $x$.

#figure(caption: [Syntax for System B])[$
  // grammar("Modules", m,
  //   more(d)\; e, "main"
  // ) \
  // grammar("Declarations", d,
  //   type(X, many(C^n (many(tau, n)), m)), "types",
  // ) \

  grammar("Expressions", e,
    x, "variable",
    val(q_0, x_0, e_0, e), "bind",
    bor(more(x), e), "borrow",
    abs(many(arg(x, q, tau), n), e_0), "abstract",
    app(e_0, many(e, n)), "apply",
    variant(C, many(e, n)), "construct",
    case(q_0, e_0, many(variant(C, many(x, n)) -> e, m)), "case",
  ) \
  grammar("Values", v,
    absa(more(z), many(arg(x, q, tau), n), e_0), "abstraction",
    variant(C, many(v, n)), "variant",
  ) \
  // grammar("Basic values", b,
  //   tuple(many(b, n)), "tuple",
  //   variant(C, many(b, n)), "variant",
  //   ) \
$]
// #footnote[Note we have $b subset v subset e$]

#figure(caption: [Type syntax for System B])[$
  grammarshort("Types", tau,
    phi, "function type",
    Variant(many(variant(C, many(tau, n)), m)), "sum type",
    // List(tau), "list",
  ) \
  grammarshort("Function types", phi,
    Function(many(qt(q, tau), n), tau_0), "function type",
  ) \
  grammarshort("Quantities", q,
    epsilon, "borrowed",
    1, "linear",
    omega, "unrestricted",
  ) \
  "add typing context" \
$]

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
  judgements.var.one wide
  judgements.var.mu \
  judgements.var.weak \
  judgements.borrow.one.one \
  judgements.bind.one \
  \ bold("Functions") \
  judgements.abs.epsilon.uncurried \
  judgements.abs.one.uncurried \
  judgements.abs.omega.uncurried \
  judgements.app.lambda.uncurried \
  judgements.app.omega.uncurried \
  \ bold("Datatypes") \
  judgements.construct.one \
  // judgements.construct.uncurried \
  judgements.case.uncurried \
$]

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
$]

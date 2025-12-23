#import "/lib/basic/commands.typ": many, more, most, maybe
#import "/lib/basic/commands.typ": grammar
#import "/lib/basic/bricks.typ": figure
#import "/types/definitions.typ" as b
#import "/types/definitions.typ": *
#import "/types/judgements.typ": *

#let short-grammars = true

= Language and semantics <theory>

== Notation

// #show math.upright: text

```sysb
x_0.f(many(x, n))                        ~~>  f(x_0, many(x,n))
if e_0 then e_1 else e_2                 ~~>  case e_0 { True |-> e_1, False |-> e_2}
when { g_1 |-> e_1; ...; else |-> e_n }  ~~>  case g_1 { True |-> e_1, False |-> when { ...; else |-> e_n } } \
when { many(g |-> e, n); "else" |-> e_(n+1) } &~> "case" g_1 space { "True" |-> e_1; "False" |-> "when" { many(g |-> e, n-1);  "else" |-> e_(n+1)}} \
"use" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
```
$
   x_0 triangle.stroked.r f(many(x, n))   &~> f(x_0, many(x,n)) \
   "if" e_0 "then" e_1 "else" e_2         &~> "case" e_0 space { "True" |-> e_1, "False" |-> e_2} \
   "when" { g_1 |-> e_1; ...; "else" |-> e_n } &~> "case" g_1 space { "True" |-> e_1, "False" |-> "when" { ...; "else" |-> e_n } } \
   "when" { many(g |-> e, n); "else" |-> e_(n+1) } &~> "case" g_1 space { "True" |-> e_1; "False" |-> "when" { many(g |-> e, n-1);  "else" |-> e_(n+1)}} \
   "use" x_0 <- f(many(e, n)); e_0       &~> f(many(e, n), |x_0| e_0) \
$

== Language

We write:\
  - $many(x, n)$ for an _ordered_ set of $x$es of length $n$, so $x_1, ..., x_n$;
  - $more(x)$ for an _unordered, possibly empty_ set of $x$es;
  - $most(x)$ for an _unordered, non-empty_ set of $x$es;
  - $maybe(x)$ for an _optional_ $x$.

#figure(caption: [Expression syntax])[$
  // grammar("Modules", m,
  //   more(d)\; e, "main"
  // ) \
  // grammar("Declarations", d,
  //   type(X, many(c^n (many(tau, n)), m)), "types",
  // ) \
  \ grammar("Expressions", e, short: #short-grammars,
    x, "variable",
    bind(q_0, x_0, e_0, e), "bind",
    borrow(more(x), e), "borrow",
  )
  \ grammar("Expressions", e, short: #short-grammars, next: #true,
    abs(pars(q, x, tau, n), e_0), "abstract",
    app(e_0, many(e,n)), "apply",
  )
  \ grammar("Expressions", e, short: #short-grammars, next: #true,
    create(c, many(e, k)), "construct",
    match(q_0, e_0, many(create(c, many(x,k)) -> e, m)), "case",
  )
  \ grammar("Values", v, short: #short-grammars,
    closure(many(z,k), many(x,n), e_0), "abstraction",
    create(c, many(v,k)), "variant",
  )
  \ grammar("Identifiers", x\, y\, z, short: #short-grammars)
  \ grammar("Arity", k\, n\, m, short: #short-grammars)
  \ grammar("Constants", c, short: #short-grammars)
  // grammar("Basic values", b,
  //   tuple(many(b,n)), "tuple",
  //   variant(c, many(b,n)), "variant",
  //   ) \
$]
// #footnote[Note we have $b subset v subset e$]

#figure(caption: [Type syntax])[$
  \ grammar("Types", tau, short: #short-grammars,
    phi, "function type",
    delta, "data type",
    // List(tau), "list",
  )
  \ grammar("Function types", phi, short: #short-grammars,
    Fn(many(qt(q, tau), n), tau_0), "function type",
  )
  \ grammar("Data types", delta, short: #short-grammars,
    Variant(many(create(c, many(tau, n)), m)), "sum type",
  )
  \ grammar("Quantities", q, short: #short-grammars,
    epsilon, "borrowed",
    1, "linear",
    omega, "unrestricted",
  )
  \ grammar("Contexts", Gamma, short: #short-grammars,
    empty, "empty",
    Gamma\, par(q, x, tau), "cons",
  )
$]

#figure(caption: [Instruction syntax])[$
  \ grammar("Instruction", i, short: #short-grammars,
  // \ grammar("Operations", o, short: #short-grammars,
    Drop(a), "drop",
    Clone(a), "clone",
    Reuse(a), "reuse",
    Alloc(k), "allocate",
    Free(k), "free",
  )
  \ grammar("Instructions", i, short: #short-grammars, next: #true,
    Pop, "pop",
    Push, "push",
    Reserve(k), "reserve",
  )
  \ grammar("Addresses", a, short: #short-grammars)
$]

#figure(caption: [Updatable and writeable values])[$
  \ grammar("Updatable values", u^many(a,k), short: #short-grammars,
    closure(many(a,k), many(x,n), e), "closure",
    create(c, many(a,k)), "constructor",
  )
  \ grammar("Writeable values", w, short: #short-grammars,
    u^many(a,k), "updatable value",
    a, "address",
    diamond^k, "reuse token",
  )
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

#let state((hs, ss, cs, qs, es)) = {
  // $ hs meta(bar.v) ss meta(bar.v) cs meta(tack.r) qs meta(dot) es $
  $
    #let mq = $q$
    #let me = $e$
    hs meta(bar.v)
    ss meta(tack.r)
    #if cs != $empty$ [$cs meta(tack.r)$]
    #if qs != $q$ or es != $e$ [$qs meta(dot) es$]
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

#figure(caption: [Reference counted heap and stack semantics for System B])[$
  \ framed(evaluate(
    H, S, more(o), q, e;
    H', S', more(o'), q', e';
  ))
  $ $

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
    H, S, empty, epsilon, calls(a_0, a, n);
    H, S, #highlight($Clone(many(a,k))$)\; Push, epsilon, scope(substs(e, x, a, n));
    where: ref(a_0, #none, closure(many(a,k), many(x,n), e) in H union S union F)
  )
  \ evaluate(name: "Call"_1,
    H, S, empty, 1, calls(a_0, a, n);
    H, S, Drop(a_0)\; Push, 1, scope(substs(e, x, a, n));
    where: ref(a_0, 1, closure(many(a,k), many(x,n), e) in H)
  )
  \ evaluate(name: "Call"_omega,
    H, S, empty, omega, calls(a_0, a, n);
    H, S, Clone(many(a,k))\; Drop(a_0)\; Push, omega, scope(substs(e, x, a, n));
    where: ref(a_0, r, closure(many(a,k), many(x,n), e) in H)
  )
  \ evaluate(name: "Call"_(1,omega),
    H, S, empty, (1,omega), calls(a_0, a, n);
    H, S, Clone(many(a,k))\; Drop(a_0)\; Push, (1,omega), scope(substs(e, x, a, n));
    where: ref(a_0, r, closure(many(a,k), many(x,n), e) in H)
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
$]

#import "definitions.typ": judgement, synthesize, with, more, borrow, lift, tuple, each, many, merge, wilt, freeze, fun, arg, qt, lookup, variant, apply, val, match, fn, split, function, synthesizes, empty

#let judgements = (

  var: (
    one: $
      judgement("Var"_1,
        space,
        synthesize(Gamma with arg(x, 1, tau), x, 1, tau, Gamma),
      )
    $,
    mu: $
      judgement("Var"_mu,
        space,
        synthesize(Gamma with arg(x, mu, tau), x, mu, tau, Gamma with arg(x, mu, tau)),
        condition: mu in {epsilon, omega}
      )
    $,
    pi: $
      judgement("Var"_pi,
        space,
        synthesize(Gamma with arg(x, omega, tau) , x, pi, tau, Gamma with arg(x, omega, tau)),
        condition: pi in {1, epsilon}
        )
    $,
    epsilon: $
      judgement("Var"_epsilon,
        space,
        synthesize(Gamma with arg(x, epsilon, tau) , x, epsilon, tau, Gamma with arg(x, epsilon, tau)),
        )
    $,
    weak: $
      judgement("Var"_"weak",
        space,
        synthesize(Gamma with arg(x, omega, tau) , x, 1, tau, Gamma with arg(x, omega, tau)),
      )
    $,
  ),

  weak: $
    judgement("Weak",
      synthesize(Gamma, x, omega, tau, Gamma),
      synthesize(Gamma, x, 1, tau, Gamma),
    )
  $,

  borrow: (
    nu: $
      judgement("Borrow"_nu,
        synthesize(Gamma_0 with more(arg(x, epsilon, tau) ), e_0, lift(q), tau_0, Gamma_1 with more(arg(x, epsilon, tau))),
        synthesize(Gamma_0 with more(arg(x, nu, tau)), borrow(more(x), e_0), q, tau_0, Gamma_1 with more(arg(x, nu, tau))),
        condition: nu in {1, omega} and tau != phi
      )
    $,
    one: (
      one: $
        judgement("Borrow"_1,
          synthesize(Gamma_0 with more(arg(x, epsilon, tau) ), e_0, 1, tau_0, Gamma_1 with more(arg(x, epsilon, tau))),
          synthesize(Gamma_0 with more(arg(x, 1, tau)), borrow(more(x), e_0), q, tau_0, Gamma_1 with more(arg(x, 1, tau))),
          condition: tau != phi
        )
      $,
      lift: $
        judgement("Borrow"_1,
          synthesize(Gamma_0 with more(arg(x, epsilon, tau) ), e_0, lift(q), tau_0, Gamma_1 with more(arg(x, epsilon, tau))),
          synthesize(Gamma_0 with more(arg(x, 1, tau)), borrow(more(x), e_0), q, tau_0, Gamma_1 with more(arg(x, 1, tau))),
          condition: tau != phi
        )
      $,
    ),
  ),

  bind: (
    one: $
      judgement("Let",
        synthesize(Gamma_0, e_0, q_0, tau_0, Gamma_1),
        synthesize(Gamma_1 with arg(x_0, q_0, tau_0), e, q, tau, Gamma_2),
        synthesize(Gamma_0, val(q_0, x_0, e_0, e), q, tau, Gamma_2 without x_0),
      )
    $,
    uncurried: $
      judgement("Let",
        synthesize(Gamma_0, e_0, q_0, tuple(many(tau, n)), Gamma_1),
        synthesize(Gamma_1 with many(arg(x, q_0, tau), n), e, q, tau, Gamma_2),
        synthesize(Gamma_0, val(q_0, tuple(many(x, n)), e_0, e), q, tau, Gamma_2 without many(x, n)),
      )
    $,
  ),

  // judgement("Abs",
  //   synthesize(Gamma_0^nu with many(arg(x, q, tau), n), e_0, lift(q), tau_0, Gamma_1),
  //   synthesize(Gamma_0^epsilon with Gamma_0^nu, fn(many(arg(x, q, tau), n), e_0), q, //     function(many(tau^q, n), tau_0), Gamma_0^epsilon with Gamma_1 without many(x, n)),
  // )

  abs: (
    epsilon: (
      curried: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0^epsilon with Gamma_0^omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(arg(x_1, q_1, tau_1), e_0), epsilon, function(qt(q_1, tau_1), tau_0), Gamma_0^1 union Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0^epsilon with Gamma_0^omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(many(arg(x, q, tau), n), e_0), epsilon, function(many(qt(q, tau), n), tau_0), Gamma_0^1 union Gamma_1 without many(x, n)),
        )
      $,
      one: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0^epsilon with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(many(arg(x, q, tau), n), e_0), epsilon, function(many(qt(q, tau), n), tau_0), Gamma_0^1 union Gamma_1 without many(x, n)),
        )
      $,
    ),
    one: (
      curried: $
        judgement("Abs"_1,
          synthesize(Gamma_0^1 with Gamma_0^omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(arg(x_1, q_1, tau_1), e_0), 1, function(qt(q_1, tau_1), tau_0), Gamma_0^epsilon union Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_1,
          synthesize(Gamma_0^1 with Gamma_0^omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(many(arg(x, q, tau), n), e_0), 1, function(many(qt(q, tau), n), tau_0), Gamma_0^epsilon union Gamma_1 without many(x, n)),
        )
      $,
      one: $
        judgement("Abs"_1,
          synthesize(Gamma_0^1 with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(many(arg(x, q, tau), n), e_0), 1, function(many(qt(q, tau), n), tau_0), Gamma_0^epsilon union Gamma_1 without many(x, n)),
        )
      $,
    ),
    omega: (
      curried: $
        judgement("Abs"_omega,
          synthesize(Gamma_0^omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(arg(x_1, q_1, tau_1), e_0), omega, function(qt(q_1, tau_1), tau_0), Gamma_0^epsilon with Gamma_0^1 union Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_omega,
          synthesize(Gamma_0^omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, fn(many(arg(x, q, tau), n), e_0), omega, function(many(qt(q, tau), n), tau_0), Gamma_0^epsilon union Gamma_0^1 with Gamma_1 without many(x, n)),
        )
      $,
    ),
  ),

  app: (
    lambda: (
      curried: $
        judgement("App"_lambda,
          synthesize(Gamma_0, e_0, epsilon, function(qt(q_1, tau_1), tau_0), Gamma_1),
          synthesize(Gamma_1, e_1, q_1, tau_1, Gamma_2),
          synthesize(Gamma_0, apply(e_0, e_1), lambda, tau_0, Gamma_2),
          condition: lambda in {epsilon, 1}
        )
      $,
      uncurried: $
        judgement("App"_lambda,
          synthesize(Gamma_0, e_0, epsilon, function(many(qt(q, tau), n), tau_0), Gamma_1),
          each(i in 1..n),
          synthesize(Gamma_(i-1) merge Gamma_i, e_i, q_i, tau_i, Gamma_(i+1)),
          synthesize(Gamma_0, apply(e_0, many(e, n)), lambda, tau_0, Gamma_(n+1)),
          condition: lambda in {epsilon, 1}
        )
      $,
      one: $
        judgement("App",
          synthesize(Gamma_0, e_0, epsilon, function(many(qt(q, tau), n), tau_0), Gamma_1),
          synthesizes(Gamma_0 merge Gamma_1, many(e, n), many(q, n), many(tau, n), Gamma_(n+1)),
          synthesize(Gamma_0, apply(e_0, many(e, n)), q, tau_0, Gamma_(n+1)),
        )
      $,
    ),
    omega: (
      curried: $
        judgement("App"_omega,
          synthesize(Gamma_0, e_0, epsilon, function(qt(q_1, tau_1), tau_0), Gamma_1),
          synthesize(Gamma_1, e_1, freeze(q_1), tau_1, Gamma_2),
          synthesize(Gamma_0, apply(e_0, e_1), omega, tau_0, Gamma_2),
        )
      $,
      uncurried: $
        judgement("App"_omega,
          synthesize(Gamma_0, e_0, epsilon, function(many(qt(q, tau), n), tau_0), Gamma_1),
          each(i in 1..n),
          synthesize(Gamma_(i-1) merge Gamma_i, e_i, freeze(q_i), tau_i, Gamma_(i+1)),
          synthesize(Gamma_0, apply(e_0, many(e, n)), omega, tau_0, Gamma_(n+1)),
        )
      $,
    ),
  ),

  wilt: (
    curried: $
      judgement("Wilt",
        synthesize(Gamma_0, e_0, 1, function(qt(q_1, tau_1), tau_0), Gamma_1),
        synthesize(Gamma_1, e_1, q_1, tau_1, Gamma_2),
        synthesize(Gamma_0, wilt apply(e_0, e_1), 1, tau_0, Gamma_2),
      )
    $,
    uncurried: $
      judgement("Wilt",
        synthesize(Gamma_0, e_0, 1, function(many(qt(q, tau), n), tau_0), Gamma_1),
        each(i in 1..n),
        synthesize(Gamma_(i-1) merge Gamma_i, e_i, q_i, tau_i, Gamma_(i+1)),
        synthesize(Gamma_0, wilt apply(e_0, many(e, n)), 1, tau_0, Gamma_(n+1)),
      )
    $,
  ),

  pair: (
    curried: $
      judgement("Pair",
        synthesize(Gamma_1, e_1, q, tau_1, Gamma_2),
        synthesize(Gamma_2, e_2, q, tau_2, Gamma_3),
        synthesize(Gamma_1, tuple(e_1, e_2), q, tuple(tau_1, tau_2), Gamma_3),
      )
    $,
    uncurried: $
      judgement("Pair",
        each(i in 1..n),
        synthesize(Gamma_(i-1) merge Gamma_i, e_i, q, tau_i, Gamma_(i+1)),
        synthesize(Gamma_1, tuple(many(e, n)), q, tuple(many(tau, n)), Gamma_(n+1)),
      )
    $,
  ),
  split: (
    curried: $
      judgement("Split",
        synthesize(Gamma_0, e_0, q_0, tuple(tau_1, tau_2), Gamma_1),
        synthesize(Gamma_1 with arg(x_1, q_0, tau_1) with arg(x_2, q_0, tau_2), e, q, tau, Gamma_2),
        synthesize(Gamma_0, split(q_0, tuple(x_1, x_2), e_0, e), q, tau, Gamma_2 without x_1 without x_2),
      )
    $,
    uncurried: $
      judgement("Split",
        synthesize(Gamma_0, e_0, q_0, tuple(many(tau, n)), Gamma_1),
        synthesize(Gamma_1 with many(arg(x, q_0, tau), n), e, q, tau, Gamma_2),
        synthesize(Gamma_0, split(q_0, tuple(many(x, n)), e_0, e), q, tau, Gamma_2 without many(x, n)),
      )
    $,
  ),

  construct: (
    curried: $
      judgement("Construct",
        lookup(Delta, C, function(tau_1, tau_0)),
        synthesize(Gamma_1, e_1, q, tau_1, Gamma_2),
        synthesize(Gamma_1, variant(C, e_1), q, tau_0, Gamma_2),
      )
    $,
    uncurried: $
      judgement("Construct",
        lookup(Delta, C, function(many(tau, n), tau_0)),
        each(i in 1..n),
        synthesize(Gamma_(i-1) merge Gamma_i, e_i, q, tau_i, Gamma_(i+1)),
        synthesize(Gamma_1, variant(C, many(e, n)), q, tau_0, Gamma_(n+1)),
      )
    $,
    one: $
      judgement("Construct",
        lookup(Delta, C, function(many(tau, n), tau_0)),
        synthesizes(Gamma_1, many(e, n), q, many(tau, n), Gamma_(n+1)),
        synthesize(Gamma_1, variant(C, many(e, n)), q, tau_0, Gamma_(n+1)),
      )
    $,
  ),
  match: (
    curried: $
      judgement("Match",
        synthesize(Gamma_0, e_0, q_0, tau_0, Gamma'_0),
        each(i in 1..2),
        lookup(Delta, C_i, function(tau_i, tau_0)),
        synthesize(Gamma'_0 with arg(x_i, q_0, tau_i), e_i, q, tau, Gamma_i),
        synthesize(Gamma_0, match(q_0, e_0, many(variant(C, x) |-> e, 2)), q, tau, Gamma_1 merge Gamma_2),
      )
    $,
    uncurried: $
      judgement("Match",
        synthesize(Gamma_0, e_0, q_0, tau_0, Gamma'_0),
        each(i in 1..m),
        lookup(Delta, C_i, function(many(tau, n_i), tau_0)),
        synthesize(Gamma'_0 with many(arg(x, q_0, tau), n_i), e_i, q, tau_i, Gamma_i),
        synthesize(Gamma_0, match(q_0, e_0, many(variant(C, many(x, n)) |-> e, m)), q, tau, merge_(i in 1..m) Gamma_i),
        condition: "same"\(many(tau, m)\),
      )
    $,
  ),

  spine: (
    empty: $
      judgement("Empty",
        synthesizes(Gamma_0, empty, empty, empty, Gamma_0),
      )
    $,
    rest: $
      judgement("Rest",
        synthesize(Gamma_0, e_0, q_0, tau_0 ', Gamma_1),
        tau_0 ' equiv tau_0,
        synthesizes(Gamma_0 merge Gamma_1, many(e, n), many(q, n), many(tau, n), Gamma_(n+1)),
        synthesizes(Gamma_0, e_0 with many(e, n), q_0 with many(q, n), tau_0 with many(tau, n), Gamma_(n+1)),
      )
    $,
  )

)



  // rule("Inl",
  //   synthesize(Gamma_1, e_1, q, tau_1, Gamma_2),
  //   synthesize(Gamma_1, variant("Inl", e_1), q, variants(tau_1, tau_2), Gamma_2),
  // ) quad
  // rule("Inr",
  //   synthesize(Gamma_1, e_1, q, tau_1, Gamma_2),
  //   synthesize(Gamma_1, variant("Inr", e_1), q, variants(tau_2, tau_1), Gamma_2),
  // )
  // rule("Des",
  //   synthesize(Gamma_0, e_0, q_0, variants(many(tau_i, 2)), Gamma'_0),
  //   each(i in 1..2),
  //   synthesize(Gamma'_0 with arg(x_i, q_0, tau_i), e_i, q, tau, Gamma_i),
  //   synthesize(Gamma_0, match(q_0, e_0, many(variant(C, x) |-> e, 2)), q, tau, Gamma_1 without x_1 merge Gamma_2 without x_2),
  // )

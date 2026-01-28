#import "/lib/basic/commands.typ": *
#import "definitions.typ": judgement, synthesize, div, with, without, more, borrow, lift, tuple, each, many, merge, wilt, freeze, arg, qt, lookup, create, app, bind, match, abs, split, Fn, synthesizes, empty

#let judgements = (

  var: (
    one: $
      judgement("Var"_1,
        strut,
        synthesize(Gamma with arg(x, 1, tau), x, 1, tau, Gamma),
      )
    $,
    mu: $
      judgement("Var"_(epsilon,omega),
        strut,
        synthesize(Gamma with arg(x, mu, tau), x, mu, tau, Gamma with arg(x, mu, tau)),
        condition: mu in {epsilon, omega}
      )
    $,
    weak: $
      judgement("Var"_"weak",
        strut,
        synthesize(Gamma with arg(x, omega, tau) , x, mu, tau, Gamma with arg(x, omega, tau)),
        condition: mu in {1, epsilon}
        )
    $,
    epsilon: $
      judgement("Var"_epsilon,
        strut,
        synthesize(Gamma with arg(x, epsilon, tau) , x, epsilon, tau, Gamma with arg(x, epsilon, tau)),
        )
    $,
    weakalt: $
      judgement("Var"_"weak",
        strut,
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
      judgement("Bor"_nu,
        synthesize(Gamma_0 with more(arg(x, epsilon, tau) ), e_0, lift(q), tau_0, Gamma_1 with more(arg(x, epsilon, tau))),
        synthesize(Gamma_0 with more(arg(x, nu, tau)), borrow(more(x), e_0), q, tau_0, Gamma_1 with more(arg(x, nu, tau))),
        condition: nu in {1, omega} and tau != phi
      )
    $,
    one: (
      one: $
        judgement("Bor"_1,
          synthesize(Gamma_0 with more(arg(x, epsilon, tau) ), e_0, 1, tau_0, Gamma_1 with more(arg(x, epsilon, tau))),
          synthesize(Gamma_0 with more(arg(x, 1, tau)), borrow(more(x), e_0), q, tau_0, Gamma_1 with more(arg(x, 1, tau))),
          condition: tau != phi
        )
      $,
      lift: $
        judgement("Bor"_1,
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
        synthesize(Gamma_0, bind(q_0, x_0, e_0, e), q, tau, Gamma_2 without x_0),
      )
    $,
    uncurried: $
      judgement("Let",
        synthesize(Gamma_0, e_0, q_0, tuple(many(tau, n)), Gamma_1),
        synthesize(Gamma_1 with many(arg(x, q_0, tau), n), e, q, tau, Gamma_2),
        synthesize(Gamma_0, bind(q_0, tuple(many(x, n)), e_0, e), q, tau, Gamma_2 without many(x, n)),
      )
    $,
  ),

  // judgement("Abs",
  //   synthesize(Gamma_0^nu with many(arg(x, q, tau), n), e_0, lift(q), tau_0, Gamma_1),
  //   synthesize(Gamma_0^epsilon with Gamma_0^nu, abs(many(arg(x, q, tau), n), e_0), q, //     Fn(many(tau^q, n), tau_0), Gamma_0^epsilon with Gamma_1 without many(x, n)),
  // )

  abs: (
    epsilon: (
      curried: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0 div epsilon with Gamma_0 div omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(arg(x_1, q_1, tau_1), e_0), epsilon, Fn(qt(q_1, tau_1), tau_0), Gamma_0 div 1 with Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0 div epsilon with Gamma_0 div omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(many(arg(x, q, tau), n), e_0), epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_0 div 1 with Gamma_1 without many(x, n)),
        )
      $,
      one: $
        judgement("Abs"_epsilon,
          synthesize(Gamma_0 div epsilon with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(many(arg(x, q, tau), n), e_0), epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_0 div 1 with Gamma_1 without many(x, n)),
        )
      $,
    ),
    one: (
      curried: $
        judgement("Abs"_1,
          synthesize(Gamma_0 div 1 with Gamma_0 div omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(arg(x_1, q_1, tau_1), e_0), 1, Fn(qt(q_1, tau_1), tau_0), Gamma_0 div epsilon with Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_1,
          synthesize(Gamma_0 div 1 with Gamma_0 div omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(many(arg(x, q, tau), n), e_0), 1, Fn(many(qt(q, tau), n), tau_0), Gamma_0 div epsilon with Gamma_1 without many(x, n)),
        )
      $,
      one: $
        judgement("Abs"_1,
          synthesize(Gamma_0 div 1 with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(many(arg(x, q, tau), n), e_0), 1, Fn(many(qt(q, tau), n), tau_0), Gamma_0 div epsilon with Gamma_1 without many(x, n)),
        )
      $,
    ),
    omega: (
      curried: $
        judgement("Abs"_omega,
          synthesize(Gamma_0 div omega with arg(x_1, q_1, tau_1), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(arg(x_1, q_1, tau_1), e_0), omega, Fn(qt(q_1, tau_1), tau_0), Gamma_0 div epsilon with Gamma_0 div 1 with Gamma_1 without x_1),
        )
      $,
      uncurried: $
        judgement("Abs"_omega,
          synthesize(Gamma_0 div omega with many(arg(x, q, tau), n), e_0, 1, tau_0, Gamma_1),
          synthesize(Gamma_0, abs(many(arg(x, q, tau), n), e_0), omega, Fn(many(qt(q, tau), n), tau_0), Gamma_0 div epsilon with Gamma_0 div 1 with Gamma_1 without many(x, n)),
        )
      $,
    ),
  ),

  app: (
    lambda: (
      curried: $
        judgement("App"_(epsilon,1),
          synthesize(Gamma_0, e_0, epsilon, Fn(qt(q_1, tau_1), tau_0), Gamma_1),
          synthesize(Gamma_1, e_1, q_1, tau_1, Gamma_2),
          synthesize(Gamma_0, app(e_0, e_1), mu, tau_0, Gamma_2),
          condition: mu in {epsilon, 1}
        )
      $,
      // uncurried: $
      //   judgement("App"_(epsilon,1),
      //     synthesize(Gamma_0, e_0, epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
      //     each(i in 1..n),
      //     synthesize(Gamma_(i-1) merge Gamma_i, e_i, q_i, tau_i, Gamma_(i+1)),
      //     synthesize(Gamma_0, app(e_0, many(e, n)), mu, tau_0, Gamma_(n+1)),
      //     condition: mu in {epsilon, 1}
      //   )
      // $,
      uncurried: $
        judgement("App"_(epsilon,1),
          synthesize(Gamma_0, e_0, epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
          synthesizes(Gamma_1, many(e, n), many(q, n), many(tau, n), Gamma_(n+1)),
          synthesize(Gamma_0, app(e_0, many(e, n)), mu, tau_0, Gamma_(n+1)),
          condition: mu in {epsilon, 1}
        )
      $,
      one: $
        judgement("App",
          synthesize(Gamma_0, e_0, epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
          synthesizes(Gamma_0 merge Gamma_1, many(e, n), many(q, n), many(tau, n), Gamma_(n+1)),
          synthesize(Gamma_0, app(e_0, many(e, n)), q, tau_0, Gamma_(n+1)),
        )
      $,
    ),
    omega: (
      curried: $
        judgement("App"_omega,
          synthesize(Gamma_0, e_0, epsilon, Fn(qt(q_1, tau_1), tau_0), Gamma_1),
          synthesize(Gamma_1, e_1, freeze(q_1), tau_1, Gamma_2),
          synthesize(Gamma_0, app(e_0, e_1), omega, tau_0, Gamma_2),
        )
      $,
      // uncurried: $
      //   judgement("App"_omega,
      //     synthesize(Gamma_0, e_0, epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
      //     each(i in 1..n),
      //     synthesize(Gamma_(i-1) merge Gamma_i, e_i, freeze(q_i), tau_i, Gamma_(i+1)),
      //     synthesize(Gamma_0, app(e_0, many(e, n)), omega, tau_0, Gamma_(n+1)),
      //   )
      // $,
      uncurried: $
        judgement("App"_omega,
          synthesize(Gamma_0, e_0, epsilon, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
          synthesizes(Gamma_1, many(e, n), many(freeze(q), n), many(tau, n), Gamma_(n+1)),
          synthesize(Gamma_0, app(e_0, many(e, n)), omega, tau_0, Gamma_(n+1)),
          condition: phantom(mu in {epsilon, 1})
        )
      $,
    ),
  ),

  wilt: (
    curried: $
      judgement("Wilt",
        synthesize(Gamma_0, e_0, 1, Fn(qt(q_1, tau_1), tau_0), Gamma_1),
        synthesize(Gamma_1, e_1, q_1, tau_1, Gamma_2),
        synthesize(Gamma_0, wilt app(e_0, e_1), 1, tau_0, Gamma_2),
      )
    $,
    uncurried: $
      judgement("Wilt",
        synthesize(Gamma_0, e_0, 1, Fn(many(qt(q, tau), n), tau_0), Gamma_1),
        each(i in 1..n),
        synthesize(Gamma_(i-1) merge Gamma_i, e_i, q_i, tau_i, Gamma_(i+1)),
        synthesize(Gamma_0, wilt app(e_0, many(e, n)), 1, tau_0, Gamma_(n+1)),
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
      judgement("Con",
        lookup(Delta, C, Fn(tau_1, tau_0)),
        synthesize(Gamma_1, e_1, q, tau_1, Gamma_2),
        synthesize(Gamma_1, create(C, e_1), q, tau_0, Gamma_2),
      )
    $,
    uncurried: $
      judgement("Con",
        lookup(Delta, C, Fn(many(tau, n), tau_0)),
        each(i in 1..n),
        synthesize(Gamma_(i-1) merge Gamma_i, e_i, q, tau_i, Gamma_(i+1)),
        synthesize(Gamma_1, create(C, many(e, n)), q, tau_0, Gamma_(n+1)),
      )
    $,
    one: $
      judgement("Con",
        lookup(Delta, C, Fn(many(tau, n), tau_0)),
        synthesizes(Gamma_1, many(e, n), q, many(tau, n), Gamma_(n+1)),
        synthesize(Gamma_1, create(C, many(e, n)), q, tau_0, Gamma_(n+1)),
      )
    $,
  ),
  case: (
    curried: $
      judgement("Des",
        synthesize(Gamma_0, e_0, q_0, tau_0, Gamma'_0),
        each(i in 1..2),
        lookup(Delta, C_i, Fn(tau_i, tau_0)),
        synthesize(Gamma'_0 with arg(x_i, q_0, tau_i), e_i, q, tau, Gamma_i),
        synthesize(Gamma_0, match(q_0, e_0, many(create(C, x) |-> e, 2)), q, tau, Gamma_1 merge Gamma_2),
      )
    $,
    uncurried: $
      judgement("Des",
        stacking(
          synthesize(Gamma_0, e_0, q_0, tau_0, Gamma'_0),
          spreading(
            each(i in 1..m),
            lookup(Delta, C_i, Fn(many(tau, n_i), tau_0)),
            synthesize(Gamma'_0 with many(arg(x, q_0, tau), n_i), e_i, q, tau_i, Gamma_i),
            tau_i equiv tau,
          ),
        ),
        synthesize(Gamma_0, match(q_0, e_0, many(create(C, many(x, n)) |-> e, m)), q, tau, merge_(i in 1..m) Gamma_i),
        // condition: "same"(many(tau, m)),
      )
    $,
  ),

  spine: (
    empty: $
      judgement("Empty",
        strut,
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
  //   synthesize(Gamma_0, case(q_0, e_0, many(variant(C, x) |-> e, 2)), q, tau, Gamma_1 without x_1 merge Gamma_2 without x_2),
  // )

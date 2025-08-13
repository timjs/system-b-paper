#import "../basic/commands.typ": *


//// Setups ////////////////////////////////////////////////////////////////////////////////////////

#set math.lr(size: 1em) // Magic! :-D

#let use-coloring = false


//// Quantities ////////////////////////////////////////////////////////////////////////////////////

// #let qt(quant, name) = $attach(tl: quant, name)$
#let qt(quant, name) = $quant dot name$

#let quantities = $cal(Q)$
#let lift(it) = $ceil(it)$
#let lower(it) = $floor(it)$
#let freeze(it) = $abs(it)$


//// Judgements ////////////////////////////////////////////////////////////////////////////////////

#let input = if use-coloring {text.with(fill: blue)} else {identity}
#let output = if use-coloring {text.with(fill: red)} else {identity}

#let meta(it) = $greyed(it)$

#let lookup(contextIn, name, type) = $
  input(contextIn) space meta(tack.r) space input(name) space meta(:) space output(type)
$
// #let check(contextIn, expression, quantity, type, contextOut) = $
//   input(contextIn) space meta(tack.r) space input(quantity) space meta(dot) space input(expression) space meta(arrow.l.double) space output(type) space meta(tack.l) space output(contextOut)
// $
#let synthesize(contextIn, expression, quantity, type, contextOut) = $
  input(contextIn) space meta(tack.r) space input(quantity) space meta(dot) space input(expression) space meta(:) space output(type) space meta(tack.l) space output(contextOut)
$
#let synthesizes(contextIn, expressions, quantities, types, contextOut) = $
  input(contextIn) space meta(forces) space input(quantities) space meta(dot) space input(expressions) space meta(:) space output(types) space meta(#rotate(180deg, forces)) space output(contextOut)
$

// #let with = math.dot
#let with = $comma space$
#let merge = $inter$


//// Declarations //////////////////////////////////////////////////////////////////////////////////

#let type(name, items) = $keyword("type") space name = angle.l items angle.r$

#let fun(name, pars, body, cont) = $keyword("def")space name(pars) space body; space cont$
#let val(quant, names, body, cont) = $keyword("let")^quant space names = body; space cont$

//// Expressions ///////////////////////////////////////////////////////////////////////////////////

#let arg(name, quant, type) = $qt(quant, name) : type$

// #let bor(args, body) = $""^args {body}$
// #let bor(args, body) = $keyword("borrow") args keyword("in") body$
#let bor(args, body) = ${args | body}$
// #let lam(pars, body) = $|pars| space body$
#let lam(pars, body) = $keyword("fn")(pars) space body$
// #let lam(pars, body) = $lambda (pars) . space body$
#let cls(vars, pars, body) = $attach(tl: vars, |pars|) space body$
#let app(func, args) = $func(args)$

#let tuple(..items) = {
  let items = items.pos().join([,])
  $(items)$
}
#let split(quant, names, body, cont) = $keyword("split")^quant space names = body; space cont$
#let variant(ctor, args) = $ctor(args)$
#let match(quant, body, arms) = $keyword("match")^quant space body space {arms}$
//arms.pos().chunks(2).map(((pat, exp)) => pat |-> exp)$
// #let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list keyword("from") accum keyword("with") var1, var2 |-> body$
#let list(items) = $[items]$
#let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list, accum, {var1, var2 |-> body}$
#let wilt = $keyword("wilt")$
#let bind(name, body, cont) = $keyword("with") space name space <- body; space cont$


//// Types /////////////////////////////////////////////////////////////////////////////////////////

#let Function(..from, to) = {
  let from = from.pos().join($, space$)
  $(from) arrow to$
  // let from = from.pos().join($times$)
  // $(from -> to)$
}
#let Type(name, ..inner) = {
  let inner = inner.pos().join($, space$)
  // $name angle.l inner angle.r$
  $name(inner)$
}
#let List(inner) = Type("List", inner)
#let Variant(..items) = {
  let items = items.pos().join($,$)
  $[ items ]$
}

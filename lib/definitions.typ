#import "commands.typ": *

//// Setups ////

#let setups = (
  color: false,
)

#let quantities = $cal(Q)$
#let lift(it) = $ceil(it)$
#let lower(it) = $floor(it)$
#let freeze(it) = $abs(it)$

#let input = if setups.color {text.with(fill: blue)} else {identity}
#let output = if setups.color {text.with(fill: red)} else {identity}

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
#let merge = $sect$

//// Language constructs ////

// #let qt(quant, name) = $attach(tl: quant, name)$
#let qt(quant, name) = $quant dot name$
#let arg(name, quant, type) = $qt(quant, name) : type$

#let fun(name, pars, body, cont) = $keyword("fun")space name\(pars\) space body; space cont$
#let val(quant, names, body, cont) = $keyword("val")^quant space names = body; space cont$

// #let borrow(args, body) = $""^args {body}$
#let borrow(args, body) = $\{args keyword("in") body\}$
// #let fn(pars, body) = $|pars| space body$
#let fn(pars, body) = $keyword("fn")\(pars\) space body$




#let cls(vars, pars, body) = $attach(tl: vars, |pars|) space body$
#let apply(func, args) = $func\(args\)$
#let tuple(..items) = {
  let items = items.pos().join([,])
  $\(items\)$
}
#let variant(ctor, args) = $ctor\(args\)$
#let list(items) = $\[items\]$
#let split(quant, names, body, cont) = $keyword("split")^quant space names = body; space cont$
#let match(quant, body, arms) = $keyword("match")^quant space body space \{arms\}$
//arms.pos().chunks(2).map(((pat, exp)) => pat |-> exp)$
// #let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list keyword("from") accum keyword("with") var1, var2 |-> body$
#let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list, accum, {var1, var2 |-> body}$
#let wilt = $keyword("wilt")$
#let bind(name, body, cont) = $keyword("with") space name space <- body; space cont$

#let function(..from, to) = {
  let from = from.pos().join($, space$)
  $\(from\) arrow to$
  // let from = from.pos().join($times$)
  // $\(from -> to\)$
}
#let type(name, ..inner) = {
  let inner = inner.pos().join($, space$)
  // $name angle.l inner angle.r$
  $name(inner)$
}
#let List(inner) = type("List", inner)
#let variants(..items) = {
  let items = items.pos().join($,$)
  $angle.l items angle.r$
}
#let type(name, items) = $keyword("type") space name = angle.l items angle.r$

#import "/lib/basic/commands.typ": *


//// Setups ////////////////////////////////////////////////////////////////////////////////////////

#let use-coloring = false


//// Quantities ////////////////////////////////////////////////////////////////////////////////////

// #let qt(quant, name) = $attach(tl: quant, name)$
#let qt(quant, name) = $quant dot name$

#let epsilon = $upright(epsilon)$
#let omega = $upright(omega)$

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

#let div = $class("unary", |)$
#let with = $comma space$ // $space union space$
#let without = $-$
#let merge = $ inter $ //FIXME: needs to be in display mode?


//// Declarations //////////////////////////////////////////////////////////////////////////////////

#let type(name, items) = $keyword("type") space name = angle.l items angle.r$

#let declare(name, parameters, body, continuation: none) = $keyword("fn") name parameters {body}$
// #let declare(name, pars, body, cont) = $keyword("def") space name(pars) space body; space cont$
#let bind(quantities, names, body, continuation) = $keyword("let") quantities dot names = body; space continuation$

//// Expressions ///////////////////////////////////////////////////////////////////////////////////

#let par(q, x, t) = $qt(#q, #x) : #t$
#let pars(q, x, t, n) = $many(par(#q, #x, #t), #n)$

#let scope(borrow: none, body) = ${ space.thin
  #if borrow != none {$borrow |$}
  body space.thin }
$
#let borrow(xs, body) = scope(borrow: xs, body) //${args | body space}$

#let apply(func, args) = $func ( args )$
#let applies(f, xs, n) = $#f ( many(#xs, #n) )$

#let split(quant, names, body, cont) = $keyword("split") quant dot names = body; space cont$
#let create(ctor, args) = $ctor ( args )$
#let match(quant, body, arms) = $keyword("case") quant dot body space.en {arms}$
#let arm(con, vars, expr) = $apply(con, vars) |-> expr$
#let arms(con, vars, expr, count) = $many(arm(con, vars, expr), count)$

//// Old ////
#let arg(name, quant, type) = par(quant, name, type)

// #let bor(args, body) = $""^args {body}$
// #let bor(args, body) = $keyword("borrow") args keyword("in") body$

#let define(vars, pars, body) = $keyword("fn")^vars (pars) space body$
// #let abs(pars, body) = $|pars| space body$
// #let abs(pars, body) = $lambda (pars) . space body$
#let abstract(pars, body) = define("", pars, body)

#let tuple(..items) = {
  let items = items.pos().join([,])
  $(items)$
}
//arms.pos().chunks(2).map(((pat, exp)) => pat |-> exp)$
// #let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list keyword("from") accum keyword("with") var1, var2 |-> body$
#let list(items) = $[items]$
#let fold(quant, list, accum, var1, var2, body) = $keyword("fold")^quant space list, accum, {var1, var2 |-> body}$
#let wilt = $keyword("wilt")$
#let use(name, body, cont) = $keyword("use") space name space <- body; space cont$


//// Types /////////////////////////////////////////////////////////////////////////////////////////

#let Function(..from, to) = {
  let from = from.pos().join($, space$)
  $(from) -> to$
  // let from = from.pos().join($times$)
  // $(from -> to)$
}
#let Type(name, ..inner) = {
  let inner = inner.pos()
  if inner.len() == 0 {
    $name$
  } else {
    let inner = inner.join($, space$)
    // $name angle.l inner angle.r$
    $name(inner)$
  }
}
#let Bool = Type("Bool")
#let List(inner) = Type("List", inner)
#let Variant(..items) = {
  let items = items.pos().join($,$)
  ${ items }$
}

//// Instructions //////////////////////////////////////////////////////////////

#let ref(ai, ri, vi) = $ai scripts(|->)^ri vi$

#let instruction(name, arg, cont) = [
  $keyword(name) med arg; space cont$
]

#let alloc = instruction.with("alloc")
#let free = instruction.with("free")
#let drop = instruction.with("drop")
#let clone = instruction.with("clone")

#let instruction(name, arg) = [
  $keyword(name) #if arg != none [$med arg$]$
]

#let Alloc = instruction.with("alloc")
#let Free = instruction.with("free")

#let Drop = instruction.with("drop")
#let Clone = instruction.with("clone")
#let Reuse = instruction.with("reuse")

#let Push = instruction("push", none)
#let Pop = instruction("pop", none)
#let Reserve = instruction.with("reserve")

#let Error = $class("normal", arrow.zigzag)$
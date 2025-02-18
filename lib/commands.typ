#import "helpers.typ": *

//// Text ////

#let verdicts(it) = {
  set enum(numbering: always($plus.circle$))
  set list(marker: $minus.circle$)
  it
}

#let logo = smallcaps

#let framed = box.with(stroke: 1pt, inset: 4pt)
#let greyed = text.with(fill: gray)


//// Math ////

#let empty = $\[\]$

#let below(item, script) = $limits(strut item)_greyed(script)$

// #let many(item, amount) = {
//   let end = if amount == "" {$thin$} else {$thick$}
//   $overline(thin item thin)^amount$
// }
#let many(item, amount) = $overline(strut thin item thick)^amount$ // Vectors
#let more(item) = $many(item, *)$ // Sets
#let most(item) = $many(item, +)$ // Nonempty sets
#let maybe(item) = $many(item, ?)$ // Optionals

// #let each(it) = $forall_(it)$
#let each(it) = $"for each" it$

#let keyword = compose(math.sans, math.bold)
#let argument = math.italic

#let judgement(name, ..premises, conclusion, condition: none) = {
  let premises = premises.pos().join($wide$)
  $ #text(smallcaps(name)) space frac(premises, conclusion) space #condition $
}

// #let constants(name, symbol, ..rules) = table(
//   columns: 2,
//   align: (right, left),
//   ..rules
// )

#let grammar(name, symbol, ..rules) = table(
  columns: 4,
  align: (right, center, left, left),
  $symbol$, $::=$, none, name + ":",
  ..spread(rules, 2, ((rule, desc)) => (none, $|$, $rule$, "– " + desc))
)

#let function(signature, ..rules) = table(
  columns: 3,
  align: (left, center, left),
  table.cell(colspan: 3, signature),
  ..spread(rules, 2, ((pattern, definition)) => (pattern, $=$, definition))
)

#let shorthands(relation, ..rules) = table(
  columns: 4,
  align: (right, center, left, left),
  ..spread(rules, 3, ((short, long, description)) => (short, relation, long, "– " + description))
)

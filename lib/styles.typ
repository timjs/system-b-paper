#import "helpers.typ": *

#let template(body) = context {

  set page(
    paper: "us-letter",
    margin: (
      inside: 1in,
      outside: 1.5in,
      top: 1.33in,
      bottom: 2in,
    ),
    numbering: "1",
    number-align: top + right,
  )

  set text(size: 9pt)
  set par(justify: true, leading: 0.85em)

  set heading(numbering: "1.1")
  show heading: text.with(font: "Libertinus Sans")
  show heading.where(level: 4).or(heading.where(level: 5)): set heading(numbering: none)

  show math.equation: text.with(font: ("Libertinus Math", "New Computer Modern Math"))

  show raw: text.with(font: "Fira Code") // (font: "Libertinus Sans")
  set raw(syntaxes: ("assets/koka.sublime-syntax", "assets/fsharp.sublime-syntax")) // theme: "black-white.tmTheme")

  body

}

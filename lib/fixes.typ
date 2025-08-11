#import "helpers.typ": *

#let init(body) = {

  set raw(syntaxes: ("assets/koka.sublime-syntax", "assets/fsharp.sublime-syntax")) // theme: "black-white.tmTheme")

  show heading.where(level: 4).or(heading.where(level: 5)): set heading(numbering: none)

  // HACK!
  // Use custom counter that keeps track of enum items.
  let enum-numbering = (..it) => {
    counter("enum").update(it.pos())
    numbering("1.1.", ..it)
  }

  set enum(numbering: enum-numbering, full: true)
  show ref: it => {
    let el = it.element
    // if el != none and el.func() == enum.item {
    //   // Reference to an enum.item. Currently only works for _explicitly_ numbered enums; also, the
    //   // label must be immediately after the enum.item, but _not_ part of it (i.e., not indented).
    //   let sup = it.supplement;
    //   let (text, style) = if sup == auto {
    //     // Default reference text and style.
    //     ("", "(1.1)")
    //   } else if sup.func() == text {
    //     // The author provided a replacement for "Item"
    //     ([#sup.text~], "1")
    //   } else {
    //     // The author provided a replacement for "Item" and a numbering scheme.
    //     let ch = sup.children
    //     (ch.slice(0, -1).join(), ch.at(-1).text)
    //   }
    //   link(el.location())[#text#numbering(style, el.number)]
    if el != none and el.func() == text {
      let sup = it.supplement;
      // Check if the author provided a replacement for "Case"
      let text = if sup == auto { "Case" } else if type(sup) == content { sup } else { "Case" }
      // Override enum references.
      // As `enum.item` is currently not a "locatable" element,
      // we're using our own counter from above.
      link(el.location())[#text~#numbering("(1.1)", ..counter("enum").at(el.location()))]
    } else {
      // Other references as usual.
      it
    }
  }

  body
}

// #let template(body) = context {

//   set page(
//     paper: "us-letter",
//     margin: (
//       inside: 1in,
//       outside: 1.5in,
//       top: 1.33in,
//       bottom: 2in,
//     ),
//     numbering: "1",
//     number-align: top + right,
//   )

//   set text(size: 9pt)
//   set par(justify: true, leading: 0.85em)

//   set heading(numbering: "1.1")
//   show heading: text.with(font: "Libertinus Sans")

//   show math.equation: text.with(font: ("Libertinus Math", "New Computer Modern Math"))

//   show raw: text.with(font: "Fira Code") // (font: "Libertinus Sans")

//   body
// }

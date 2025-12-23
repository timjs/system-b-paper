#import "/lib/basic/helpers.typ": always
#import "/lib/basic/commands.typ": word, greyed

#let basic-layout(
  body,
) = {
  // set block(inset: (x: 1em, y: 0.5em))
  body
}

#let pretty-raw(
  language,
  body,
) = {
  show raw.where(lang: language): (it) => {
    show "_1": sub("1")
    show "_n": sub("n")

    it
  }

  body
}

#let pretty-system-b(
  sans-font: "Libertinus Sans",
  keyword-style: strong,
  type-style: smallcaps,
  variable-style: emph,
  mark-style: highlight,
  body,
) = {

  let keyword(name, body) = {
    show word(name): keyword-style
    body
  }
  let type(name, body) = {
    show word(name): type-style
    body
  }
  // let type-var(name, body) = {
  //   show word(name): emph //smallcaps
  //   body
  // }
  let variable(char, body) = {
    show word(char): variable-style
    show word(char + "s"): variable-style
    show word(char + char): variable-style
    body
  }
  let symbol(chars, repl, body) = {
    show chars: always(repl)
    body
  }
  let mark(chars, body) = {
    show chars: mark-style
    body
  }

  set highlight(fill: gray, extent: 1pt)

  show raw: set block(inset: (x: 1em, y: 0.5em))

  show raw.where(lang: "sysb"): (it) => {
    set text(font: sans-font, size: 1.25em) //NOTE: reset 0.8em raw font size by using 1.25em

    show: keyword.with("let")
    show: keyword.with("use")
    show: keyword.with("if")
    show: keyword.with("then")
    show: keyword.with("else")
    show: keyword.with("when")
    show: keyword.with("fn")
    show: keyword.with("case")
    show: keyword.with("of")
    show: keyword.with("in")
    show: keyword.with("as")

    show: type.with("Unit") //TODO: what about constructor with same name?
    show: type.with("Pair") //TODO: what about constructor with same name?
    show: type.with("Bool")
    show: type.with("Nat")
    show: type.with("Int")
    show: type.with("Real")
    show: type.with("String")
    show: type.with("Option")
    show: type.with("Result")
    show: type.with("List")
    show: type.with("Tree")

    show: variable.with("a")
    show: variable.with("b")
    show: variable.with("c")
    show: variable.with("d")
    show: variable.with("e")
    show: variable.with("f")
    show: variable.with("g")
    show: variable.with("h")
    show: variable.with("i")
    show: variable.with("j")
    show: variable.with("k")
    show: variable.with("l")
    show: variable.with("m")
    show: variable.with("n")
    show: variable.with("o")
    show: variable.with("p")
    show: variable.with("q")
    show: variable.with("r")
    show: variable.with("s")
    show: variable.with("t")
    show: variable.with("u")
    show: variable.with("v")
    show: variable.with("w")
    show: variable.with("x")
    show: variable.with("y")
    show: variable.with("z")

    show: mark.with("?")

    // show regex("\_\S+"): (it) => super(it.trim("^")) //NOTE: doesn't work: "element text has no method `trim`"
    show "^ε": super("ε")
    show "^1": super("1")
    show "^ω": super("ω")
    show "_ε": sub("ε")
    show "_0": sub("0")
    show "_1": sub("1")
    show "_2": sub("2")
    show "_3": sub("3")
    show "_4": sub("4")
    show "_5": sub("5")
    show "_6": sub("6")
    show "_7": sub("7")
    show "_8": sub("8")
    show "_9": sub("9")
    show "_n": sub("n")
    show "_ω": sub("ω")

    show "  ": sym.space.quad

    show ":": $space.thin :$
    show "|": $|$
    show "|->": $|->$
    show "->": $->$
    show "|>": $triangle.stroked.r$
    show "==": $equiv$

    show regex("//.+"): greyed

    it
  }
  set raw(lang: "sysb")

  body
}
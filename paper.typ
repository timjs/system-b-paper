#import "/lib/acmart/template.typ"
#import "/lib/basic/setups.typ"
#import "/lib/basic/logos.typ"
#import "/lib/basic/parts.typ"
#import "/templates.typ"
#import "/types/definitions.typ": *
#import "/types/judgements.typ": *

#show: template.acmart.with(
  format: "acmsmall",
  title: [
    Borrowing is 2nd class, owning is 1st class, sharing is for all
    (draft #datetime.today().display())
  ],
  authors: (
    (
      name: "Tim Steenvoorden",
      email: "tim.steenvoorden@ou.nl",
      orcid: "0002-8436-2054",
      affiliation: (
        institution: "Open University",
        streetaddress: "<address>",
        city: "Heerlen",
        country: "the Netherlands",
      ),
    ),
  ),
  abstract: include "sections/abstract.typ",
  acmJournal: "JACM",
)
#show: setups.libertinus
#show: setups.init
#show: logos.init
#show: templates.pretty-system-b
#show: templates.pretty-raw.with("koka")
#show: templates.basic-layout

#show heading.where(level: 4).or(heading.where(level: 5)): set heading(numbering: none)
#set math.lr(size: 1em) // Magic! :-D
#set table(stroke: none)

#include "/sections/introduction.typ"
#include "/sections/examples.typ"
#include "/sections/approaches.typ"
#include "/sections/language.typ"
#include "/sections/guarantees.typ"
#include "/sections/related.typ"
#include "/sections/conclusion.typ"

#bibliography(("tex/dblp.bib", "tex/other.bib"),
  // style: "association-for-computing-machinery",
  style: "american-psychological-association",
)

#show: parts.appendix
// #include "/sections/scratch.typ"

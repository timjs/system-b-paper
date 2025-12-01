#import "/lib/acmart/template.typ"
#import "/lib/basic/setups.typ"
#import "/lib/basic/logos.typ"
#import "/types/definitions.typ": *
#import "/types/judgements.typ": *

#show: template.acmart.with(
  format: "acmsmall",
  title: [Borrowing is second class],
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
#show: setups.init
// #show: setups.libertinus
#show: logos.init

#show heading.where(level: 4).or(heading.where(level: 5)): set heading(numbering: none)
#set math.lr(size: 1em) // Magic! :-D
#set table(stroke: none)

#include "/sections/introduction.typ"
#include "/sections/examples.typ"
#include "/sections/related.typ"
#include "/sections/language.typ"
#include "/sections/guarantees.typ"
#include "/sections/conclusion.typ"



// = Bibliography

#bibliography(("tex/dblp.bib", "tex/other.bib"),
  // style: "association-for-computing-machinery",
  style: "american-psychological-association",
)

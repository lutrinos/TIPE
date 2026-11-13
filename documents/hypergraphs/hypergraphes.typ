// global
#import "/customization/lib.typ": template

//local
#import "/customization/colors.typ": *

#let font = "New Computer Modern"

#show: template.with(
  lang: "fr",

  // personal/subject related stuff
  author: "Nathan Tillier",
  title: "Hypergraphes",
  date: "Janvier 2026",

  // formatting settings
  body-font: font,
  cover-font: font,

  // chapters that need special placement
  abstract: none, //include "chapter/abstract.typ",

  // equation settings
  equate-settings: (breakable: true, sub-numbering: true, number-mode: "label"),
  equation-numbering-pattern: "(1.1)",

  // colors
  cover-color: color1,
  heading-color: color2,
  link-color: color3,
)

// ------------------- content -------------------
#include "chapter/resume.typ"

#include "chapter/introduction.typ"
#include "chapter/representation.typ"
#include "chapter/dual.typ"
#include "chapter/coloration.typ"
#include "chapter/matroides.typ"

#include "chapter/appendix.typ"

// ------------------- bibliography -------------------
//#bibliography("bibliography.bib")


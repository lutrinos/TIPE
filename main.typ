// global
#import "./lib.typ": template

//local
#import "customization/colors.typ": *


#show: template.with(
  lang: "fr",

  // personal/subject related stuff
  author: "Nathan TILLIER",
  title: "Hypergraphes",
  date: "Juin 2025",

  // formatting settings
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

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
#include "chapter/introduction.typ"
#include "chapter/representation.typ"
#include "chapter/dual.typ"
#include "chapter/coloration.typ"
#include "chapter/appendix.typ"

// ------------------- bibliography -------------------
#bibliography("bibliography.bib")


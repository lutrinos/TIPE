#import "@preview/datify:1.0.0": *

#import "/customization/lib.typ": template
#import "/customization/colors.typ": *

#let font = "New Computer Modern"

#show: template.with(
  lang: "fr",

  // personal/subject related stuff
  author: "Nathan TILLIER",
  title: "Hypergraphes acycliques et résolution de contraintes",
  date: custom-date-format(datetime.today(), pattern: "long", lang: "fr"),

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

#include "chapitres/generalites.typ"
#include "chapitres/algebre.typ"

#include "chapitres/database.typ"
#include "chapitres/oral.typ"

// #include "chapitres/notes.typ"

// ------------------- bibliography -------------------
#bibliography("bibliography.bib")

// packages
#import "@preview/great-theorems:0.1.2": *
#import "@preview/rich-counters:0.2.2": rich-counter

// local
#import "colors.typ": *
#import "languages.typ": *

// counter for mathblocks
#let prop = rich-counter(
  identifier: "proposition",
  inherited_levels: 0,
)

#let def = rich-counter(
  identifier: "definition",
  inherited_levels: 0,
)

#let ex = rich-counter(
  identifier: "example",
  inherited_levels: 0,
)

#let my_mathblock = mathblock.with(
  radius: 0pt,
  inset: 0.8em,
  breakable: false,
  //titlix: title => [(#title):],
)

// theorem etc. settings
#let theorem = my_mathblock(
  counter: prop,
  blocktitle: get-label("theorem"),
  fill: color1.lighten(90%),
  stroke: (
    left: color1.darken(20%),
  ),
)

#let proposition = my_mathblock(
  counter: prop,
  blocktitle: get-label("proposition"),
  fill: color2.lighten(90%),
  stroke: (
    left: color2.darken(20%),
  ),
)

#let corollary = my_mathblock(
  counter: prop,
  blocktitle: get-label("corollary"),
  fill: color3.lighten(90%),
  stroke: (
    left: color3.darken(20%),
  ),
)

#let lemma = my_mathblock(
  counter: prop,
  blocktitle: get-label("lemma"),
  fill: color4.lighten(90%),
  stroke: (
    left: color4.darken(20%),
  ),
)

#let definition = my_mathblock(
  counter: def,
  blocktitle: get-label("definition"),
  radius: 0pt,
  fill: color5.lighten(95%),
  stroke: (
    left: color5.darken(20%),
  ),
)

#let remark = my_mathblock(
  blocktitle: get-label("remark"),
  fill: color1.lighten(90%),
  stroke: (
    left: color1.darken(20%),
  ),
)

#let reminder = my_mathblock(
  blocktitle: get-label("reminder"),
  fill: color3.lighten(90%),
  stroke: (
    left: color3.darken(20%),
  ),
)

#let example = my_mathblock(
  counter: ex,
  blocktitle: get-label("example"),
  fill: color2.lighten(90%),
  stroke: (
    left: color2.darken(20%),
  ),
)

#let question = my_mathblock(
  blocktitle: get-label("question"),
  fill: color3.lighten(75%),
  stroke: (
    left: color3.darken(20%),
  ),
)

#let proof = proofblock(prefix: [_#get-label("proof")._])

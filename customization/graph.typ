#import "@preview/cetz:0.4.0": *
#import draw: *
#import calc: sin, cos, rem-euclid

#let hypergraph(
  nodes: (),
  edges: (),
  weights: (),
  gap: 60pt,
  opacity: 40%,
) = {
  let n = nodes.fold(0, (acc, node) => calc.max(acc, node.at(0), node.at(1)))
  let radius = gap * 0.4

  let pos((x, y)) = (
    (x + 1) * gap,
    (y + 1) * gap,
  )

  let circumferences((ax, ay), (bx, by)) = {
    let alpha = calc.atan2(bx - ax, by - ay)
    let beta = calc.atan2(ax - bx, ay - by)
    return (alpha, beta)
  }

  let colors = (
    // rgb(255, 204, 204),
    // rgb(178, 255, 183),
    // rgb(199, 251, 255),
    // rgb(242, 204, 255),
    rgb("F49097"),
    rgb("#aaffaa"),
    rgb("#ffffbb"),
    rgb("#c8e1ff"),
    rgb("#fdcae1"),
    rgb("DFB2F4"),
  )

  block(
    breakable: false,
    inset: 18pt,
    radius: 10pt,
    //fill: luma(250),
    width: 100%,
  )[
    #set align(center)
    #canvas(
      {
        let i = 0
        for edge in edges {
          let w = weights.at(i, default: 1)

          if type(edge) == int {
            circle(
              pos(nodes.at(edge)),
              radius: (radius * w, radius * w),
              stroke: none,
              fill: colors.at(rem-euclid(i, colors.len())).transparentize(opacity),
            )
          } else {
            merge-path(
              stroke: none,
              fill: colors.at(rem-euclid(i, colors.len())).transparentize(opacity),
              {
                let pnode = nodes.at(edge.at(0))
                let palpha = none

                for i in range(1, edge.len() + 2) {
                  let node = nodes.at(edge.at(rem-euclid(i, edge.len())))

                  let (x1, y1) = pos(pnode)
                  let (x2, y2) = pos(node)

                  let (alpha, beta) = circumferences(pnode, node)

                  if palpha != none and calc.abs(alpha - palpha) >= 1deg {
                    let m = palpha + 20deg
                    arc-through(
                      (x1 + w * radius * sin(palpha), y1 - w * radius * cos(palpha)),
                      (x1 + w * radius * sin(m), y1 - w * radius * cos(m)),
                      (x1 + w * radius * sin(alpha), y1 - w * radius * cos(alpha)),
                    )
                    // bezier-through(
                    //   (x1 + w * radius * sin(palpha), y1 - w * radius * cos(palpha)),
                    //   (x1 + w * radius * sin(m), y1 - w * radius * cos(m)),
                    //   (x1 + w * radius * sin(alpha), y1 - w * radius * cos(alpha)),
                    // )
                  }

                  line(
                    (x1 - w * radius * sin(beta), y1 + w * radius * cos(beta)),
                    (x2 + w * radius * sin(alpha), y2 - w * radius * cos(alpha)),
                  )

                  pnode = node
                  palpha = alpha
                }
              },
            )
          }

          i += 1
        }

        let i = 0
        for node in nodes {
          let (x, y) = pos(node)
          circle((x, y), radius: (2pt, 2pt), fill: black)
          content((x + 7pt, y + 7pt), [$v_#(i)$])
          i += 1
        }
      },
      length: gap * (n + 1),
    )
  ]
}

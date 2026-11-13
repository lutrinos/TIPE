#import "/customization/great-theorems-customized.typ": *

= Duals

Que se passe-t-il lorsqu'on prend un hypergraphe, puis que ses arêtes deviennent ses sommets et ses sommets ses arêtes (intuitivement) ? On appelle cet hypergraphe un dual.

== Définition

#definition(title: "Dual")[
  Soit $H$ un hypergraphe sur $X$, $H = (X; E_1, ..., E_m)$. On peut lui faire correspondre un hypergraphe $H^* = (E; X_1, ..., X_n)$ dont
  - les sommets sont les points $e_1, ..., e_m$ représentant respectivement $E_1, ..., E_m$
  - les arêtes sont les ensembles $X_1, ..., X_n$ représentant respectivement $x_1, ..., x_n$.

  On a alors pour $j in [| 1, n |]$,
  $ X_j = { e_i | i <= m, x_j in E_i } $

  On appelle cet hypergraphe $H^*$ l'_hypergraphe dual_ de $H$.
]

#proof[
  $H^*$ est-il bien un hypergraphe ?

  D'une part $X_j != emptyset$ car $H$ est un hypergraphe donc l'union de ses arêtes recouvre $X$ ce qui implique que tous ses sommets sont au moins dans une arête.

  D'autre part $ union.big_(i=1)^m X_j = E $ car l'inclusion directe est évidente, et comme $E_i != emptyset$ alors toutes les arêtes de $H$ possèdent au moins un sommet $x_i$ ce qui justifie l'inclusion réciproque.
]

#remark[
  Pour que le dual soit bien défini, il faut que les deux propriétés de la définition initiale soient respectées.

  D'ailleurs, on remarque que la première condition sur l'hypergraphe implique la seconde sur le dual, et la seconde sur l'hypergraphe implique la première sur le dual.
]

== Propriétés

#proposition(title: "Matrice d'adjacence")[
  Soit $H$ un hypergraphe et $M$ sa matrice d'adjacence. Alors la matrice d'adjacence de $H^*$ est $M^tack.b$
]

#proof[
  Cela découle de la définition directement. En effet, avec $M$ matrice d'adjacence de $H$ hypergraphe et $M'$ matrice d'adjacence de $H^*$,
  $
    & M_(i,j) = 1 \
    & ==> "le sommet" x_i "est dans l'arête" E_j \
    & ==> "le sommet" e_j "est dans l'arête " X_i \
    & ==> M'_(j, i) = 1
  $

  Et en passant à la négation on a également
  $ M_(i, j) = 0 ==> M'_(j,i) = 0 $

  Ce qui donne, puisque la matrice est à valeur dans ${0, 1}$ que pour tout $i, j$ ,$ M_(i, j) = M'_(j, i) $
  Et dès lors (les dimensions coincident), $ M' = M^tack.b $
]

#corollary(title: "Involution du dual")[
  Pour tout hypergraphe $H$, $ (H^*)^* = H $
]

#proof[
  Cela se déduit directement de la proposition précédente, du fait qu'une matrice d'adjacence correspond de manière unique à un hypergraphe et que $(M^tack.b)^tack.b = M$.
]

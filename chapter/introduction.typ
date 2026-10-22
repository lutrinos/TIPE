#import "../customization/great-theorems-customized.typ": *
#import "../customization/graph.typ": *

= Introduction aux hypergraphes

La théorie des hypergraphes est un généralisation de la théorie des graphes (non orientés) où une arête peut relier plus de deux sommets entre eux. Par exemple, dans un hypergraphe, 4 sommets peuvent tout à fait être relié par une seule arête.

== Définitions fondamentales

Dans le cadre de la théorie des hypergraphes, on appelle les arêtes des hyperarêtes, même si on fera souvent un abus de language en les appelant arêtes comme pour un graphe.

#definition(title: "Hypergraphe")[
  Soit $X = { x_1, x_2, ..., x_n }$ un ensemble fini. Un hypergraphe sur $X$ est une famille $H = (E_1, E_2, ..., E_p)$ de parties de $X$ avec :
  $ forall in bracket.l.double 1, p bracket.r.double, E_i != emptyset $
  Et
  $ union.big_(i=1)^p E_i = X $
]

Les éléments de $X$ sont les sommets, et les éléments de la famille $H$ sont les arêtes de l'hypergraphe. Un hypergraphe n'a donc, avec cette définition, aucun sommet isolé.

#remark[
  Il existe une autre définition sans l'hypothèse de l'union. Un hypergraphe est alors une paire ordonnée $(X,H)$ telle que $X$ soit un ensemble et $H$ une famille de sous-ensemble non vides de $X$.
]

Dès lors, un graphe est un hypergraphe dont toutes les arêtes relient deux sommets (non nécessairement différents si on autorise la présence de boucles), soit pour tout $i$
$ abs(E_i) in {1, 2} $

#example[
  Un hypergraphe connu est l'hypergraphe du plan de Fano.

  #figure(
    image("../images/fano.png", width: 160pt),
    caption: [Hypergraphe du plan de Fano],
  )
]

Cet hypergraphe contient 7 sommets numérotés de 0 à 6 donc $ X = {0, 1, 2, 3, 4, 5, 6} $
Et les arêtes sont ici représentées par des droites et cercles, soit $ H = { {0,1,3}, {0,4,5}, {0,2,6}, {1,2,4}, {3,4,6}, {3,2,5}, {5,1,6} } $

On définit ensuite certaines notations relatives aux hypergraphes.

#definition(title: "Notations")[
  Soit un hypergraphe $H$ sur $X$, on définit les notations suivantes.
  - l'_ordre_ de $H$ est le nombre de sommets qu'on note $ n(H) = abs(X) $
  - le _nombre d'arêtes_ de $H$ est noté $ m(H) = abs(H) $
  - le _rang_ de $H$ le cardinal maximal des arêtes $ r(H) = max_j (abs(E_j)) $
  - l'_anti-rang_ de $H$ le cardinal minimal des arêtes $ s(H) = min_j (abs(E_j)) $
]

Prenons l'hypergraphe suivant.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (2, 0),
    (0, 1),
    (1, 1),
    (2, 1),
  ),
  edges: (
    (1, 2, 5),
    (0, 1, 2),
    (1, 2),
    3,
  ),
  weights: (1, 0.8, 0.6, 1, 1),
)


On retrouve les même notions d'ordre et de nombre d'arête que pour les graphes, auxquelles on a ajouté le rang et l'anti-rang d'un hypergraphe, qui caractérisent des propriétés portant sur les arêtes.

On introduit la notion d'hypergraphe simple généralisant celle de graphe simple, donc on aura besoin par la suite.

#definition(title: "Hypergraphe simple")[
  Un hypergraphe simple sur $X$ est un hypergraphe $H = (E_1, E_2, ..., E_p)$ dont aucune arête n'en contient une autre. \
  Autrement dit, pour tout $i, j in bracket.l.double 1, p bracket.r.double$
  $ E_i subset E_j /*" ou " E_j subset E_j*/ ==> i = j $
]

#remark[
  On appelle famille de Sperner un hypergraphe simple dont aucune arête n'est contenue dans une autre.
]

Par exemple, l'hypergraphe du plan de Fano est un hypergraphe simple : aucune arête n'est "incluse" dans une autre (les droites et cercles ne se superposent pas).

Cette définition est cohérente avec celle des graphes simples pour lesquels il y a au plus une arête entre deux sommets, à la différence des multigraphes.

#definition(title: "Hypergraphe uniforme et complet")[
  Pour un hypergraphe $H$ sur $X$, on dit que $H$ est _uniforme_ si toutes ses arêtes ont le même cardinal $ r(H) = s(H) $
  On dit de plus qu'il est _r-uniforme_ si $H$ est simple uniforme de rang $r$.

  Cet hypergraphe est dit _r-complet_ si $H$ est l'ensemble des parties de $X$ de cardinalité $r$, on le note $K_n^r$ avec $n = abs(X)$.
]

Pour $r=2$, on retrouve la définition de graphe complet (pour deux sommets _u_ et _v_ quelconques il existe une arête reliant _u_ et _v_).

#reminder[
  Attention, il faut que l'hypergraphe soit simple ! Si on a égalité du rang et de l'anti-rang il faut que tout les éléments de $H$ soient deux à deux différents (qu'il n'y ait pas d'arêtes dupliquées).
]

Pour définir le degré d'un sommet dans un hypergraphe, on utilise parallèlement la notion d'étoile centrée en un sommet.

#definition(title: "Degré")[
  Soit $x in X$, on appelle étoile centrée en $x$ l'hypergraphe partiel de $H$ formé des arêtes contenant $x$, qu'on note $H(x)$.

  Le degré du sommet $x$ est alors $ d_H (x) = m(H(x)) $
]

Encore une fois, on retrouve une définition du degré proche de celle sur les graphes, il s'agit du nombre d'arêtes dont un des extrémités est $x$ (même si une hyperarête a en quelque sorte plusieurs extrémités).

== Hypergraphes particuliers

Certains hypergraphes possèdent des caractéristiques particulières qu'on peut retrouver régulièrement.

On définit ensuite un hypergraphe partiel issu d'un hypergraphe auquel on a a retiré des arêtes.

#definition(title: "Hypergraphe partiel")[
  Soit $H = (E_1, E_2, ..., E_p)$ un hypergraphe sur $X$. On appelle hypergraphe partiel de $H$ engendré par un ensemble $J subset.eq { 1,2, ..., p }$ la famille
  $ H_J = (E_j | j in J) $
]

Puis un sous-hypergraphe (d'un hypergraphe auquel on a retiré des sommets).

#definition(title: "Sous-hypergraphe")[
  Soit $H = (E_1, E_2, ..., E_p)$ un hypergraphe sur $X$. On appelle sous-hypergraphe de $H$ induit par un ensemble $A subset.eq X$ la famille
  $ H_A = (E_j | E_j subset.eq A " pour " i <= j <= m) $
]

== Représentations



== Propriétés

#theorem(title: "Théorème de Sperner")[
  Soit $H$ un hypergraphe simple d'ordre $n$ sur $X$, alors
  $ sum_(E in H) binom(n, abs(E))^(-1) <= 1 $
  Et
  $ abs(H) <= binom(n, floor(n / 2)) $
]

#proof[
  On considère $E$ partie quelconque de $X$ fixée, et $sigma$ une permutation de $bracket.l.double 1, abs(X) bracket.r.double$ dans $X$. On dit que $sigma$ débute par $E$ si
  $ E = { sigma(i) | 1 <= i <= abs(E) } $
  Comme l'hypergraphe $H$ est simple, une même permutation $sigma$ ne peut pas débuter par deux parties $E_i$ et $E_j$ distinctes de $H$ (par l'absurde, on peut prendre $abs(E_i) <= abs(E_j)$ et $E_i subset E_j => i = j$).

  Donc toutes les permutations débutant par $E$ sont distinctes, et on en dénombre $abs(E)!(n-abs(E))!$. Or il y a $n!$ permutations de $X$, donc
  $ sum_(E in H) abs(E)!(n-abs(E))! <= n! $
  D'où en divisant par $n!$
  $ sum_(E in H) binom(n, abs(E))^(-1) <= 1 $
  La deuxième inégalité s'obtient en remarquant que pour tout $k in NN$
  $ binom(n, floor(n / 2)) >= binom(n, k) " donc " binom(n, floor(n / 2))^(-1) <= binom(n, k)^(-1) $
  Et donc
  $
    abs(H) binom(n, floor(n / 2))^(-1) = sum_(E in H) binom(n, floor(n / 2))^(-1) <= sum_(E in H) binom(n, abs(E))^(-1) <= 1
  $
  On en déduit que
  $ abs(H) <= binom(n, floor(n / 2)) $
]

On remarque d'ailleurs que ces limites peuvent être atteintes dans des cas particuliers



#import "@preview/lovelace:0.3.0": *

#import "/customization/great-theorems-customized.typ": *
#import "/customization/graph.typ": *

#let ac = [$alpha$-acyclicité]
#let bc = [$beta$-acyclicité]
#let gc = [$gamma$-acyclicité]

= Généralités

La théorie des hypergraphes est une généralisation de la théorie des graphes, en particulier ceux non orientés, dans laquelle une arête peut relier plus de deux sommets entre eux. Les dessins ont l'avantage d'être proches, avec les arêtes ("hyperarêtes") représentées par des tracés fermés entourant les sommets.

La figure ci-dessous en donne un aperçu.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (2, 0),
    (2, 1),
    (1, 1),
  ),
  edges: (
    (0, 1),
    (1, 2, 3),
    (4, 3),
  ),
)

Sur cet hypergraphe, une première arête rouge relie les sommets $v_0$ et $v_1$, une seconde jaune les sommets $v_3$ et $v_4$, tandis qu'une dernière (verte) relie les sommets $v_1$, $v_2$ et $v_3$.


== Quelques définitions

Dans le cadre de la théorie des hypergraphes, on appelle les arêtes des hyperarêtes. On fera souvent (voire systématiquement) un abus de language en les appelant arête comme pour un graphe.

#definition(title: "Hypergraphe")[
  Soit $X = { x_1, x_2, ..., x_n }$ un ensemble fini. Un hypergraphe sur $X$ est une famille $H = (E_1, E_2, ..., E_p)$ de parties de $X$ vérifiant :

  1. $ forall i in bracket.l.double 1, p bracket.r.double, space E_i != emptyset $

  2. $ union.big_(i=1)^p E_i = X $
]

Quelques observations :
- les éléments de $X$ sont les sommets de l'hypergraphe, et les éléments de la famille $H$ sont les arêtes de l'hypergraphe. On réduira souvent l'hypergraphe à $H$ la famille de ses arêtes, $X$ étant défini implicitement par l'union des éléments de $H$.
- une autre notation présente dans la littérature est $H = (V, cal(E))$ où $V$ est l'ensemble des sommets et $cal(E)$ est la famille des hyperarêtes.
- un graphe est alors un hypergraphe dont toutes les arêtes relient deux sommets _exactement_ (nécessairement différents si on n'autorise pas la présence de boucles)
$ forall i, abs(E_i) = 2 $

#remark[
  Cette définition#footnote[Donnée notamment par Claude Berge, ancien directeur de recherches au CNRS, dans son ouvrage _Graphes et hypergraphes_ @berge1970] est assez contraignante. On peut en trouver une autre (sur _Wikipédia_ notamment) ne mentionnant pas la seconde condition. D'autres propriétés figurant dans @delaitre2009 peuvent faire office d'introduction aux hypergraphes (et aux matroïdes).

  Un hypergraphe n'a, avec la définition précédente, aucun sommet isolé.
]

== Développements sur l'acyclicité

La généralisation de l'acyclicité aux hypergraphes est ambigüe : réaliser un cycle revient essentiellement à partir d'un sommet puis d'y retourner sans "revenir sur son chemin". Comme toute généralisation qui se respecte, la restriction de la condition d'acyclicité doit rester valide dans le cadre d'un graphe non orienté.

#remark[
  Les définitions suivantes proviennent de la thèse de David Duris @duris2009, soutenue en 2009 (donc relativement ancienne).
]

Plusieurs définition de l'acyclicité ont donc vu le jour : l'#ac, la #bc, la #gc et la Berge-acyclicité.

Ces différences proviennent du point de vue porté sur les hypergraphes :
- la Berge-acyclicité nous vient de Claude Berge.
- la #bc de la combinatoire (et de Berge aussi). Un hypergraphe $beta$-acyclique (_super-balanced hypergraph_ en anglais), partage certaines caractéristiques des graphes bipartis#footnote[https://en.wikipedia.org/wiki/Balanced_hypergraph].
- l'#ac et la #gc tirent les origine des bases données. On s'y intéressera donc tout particulièrement.

#remark[
  Il est important de noter que ces définitions de sont pas équivalentes ! Elles traduisent des propriétés certes similaires mais sensiblement différentes.
]

Dans certaines définitions d'acyclicité qui seront données, un chemin sera décrit pas une suite alternant entre arête et sommet. Les arêtes constituent le "véhicule" permettant de passer d'un sommet à l'autre, et deux sommets peuvent avoir plusieurs arêtes communes par lesquelles on peut passer.

Par convention, un cycle commencera par une arête et terminera par un sommet appartenant à cette première arête.

#definition(title: "Berge-acyclicité")[
  Soit $H$ un hypergraphe sur $X$.

  Un _Berge-cycle_ est une suite $(E_1, x_1, ..., E_p, x_p)$ où $p >= 2$ telle que

  1. les $E_i$ sont des arêtes distinctes

  2. les $x_i$ sont des sommets distincts

  3. pour tout $i in bracket.double 1, p bracket.double.r$, $x_i in E_i inter E_(i+1)$ (avec $E_(n+1) = E_1$)

  $H$  est dit _Berge-acyclique_ s'il ne contient aucun _Berge-cycle_.
]

Dans l'essentiel, cela revient à dire qu'on a trouvé un chemin partant et revenant à $x_1$ par des sommets et arêtes distinctes.

Attention ! L'une de ces conditions n'implique pas l'autre, contrairement aux chemins élémentaires et simples dans des graphes, où un chemin élémentaire est forcément simple.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (1, 1),
    (0, 1),
  ),
  edges: (
    (0, 3),
    (0, 1, 2),
    (3, 2),
  ),
)

Ici, passer par les sommets $(v_0, v_1, v_2, v_3)$ distincts ne garantit pas que les arêtes soient distinctes (parce qu'une arête n'est pas définie par un couple de deux sommets).

/*De même dans l'exemple suivant, où passer par les sommets $(v_0, v_1, v_2, v_0, v_4, v_3, v_0)$ respecte le caractère distinct des sommets, mais pas des arêtes.

#hypergraph(
  nodes: (
    (1, 0),
    (2, 0),
    (2, 1),
    (1, 1),
    (0, 1),
  ),
  edges: (
    (0, 1),
    (1, 2),
    (2, 0),
    (0, 3),
    (3, 4),
    (4, 0),
  ),
  gap: 40pt,
)*/

L'hypergraphe suivant est Berge-acyclique en revanche.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (2, 0),
    (2, 1),
    (3, 1),
  ),
  edges: (
    (1, 2, 3),
    (0, 1),
    (3, 4),
  ),
)

/*
#definition(title: [#bc])[
  Soit $H$ un hypergraphe sur $X$, et $cal(E) = (E_1, x_1, ..., E_p, x_p)$ un Berge-cycle.

  $cal(E)$ est un $beta$-cycle si $x_i$ appartient à $E_i$, $E_(i+1)$ et à aucun autre $E_j$.

  $H$ est dit $beta$-acyclique s'il ne contient aucun $beta$-cycle.
]

La #bc diffère de la Berge-acyclicité en ce que*/

La Berge-acyclicité est sans doute la généralisation la plus directe de l'acyclicité aux hypergraphes. Ce sera en revanche l'#ac qui nous intéressera le plus (voir l'application aux bases de données)

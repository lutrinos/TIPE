#import "/customization/great-theorems-customized.typ": *
#import "/customization/graph.typ": *

#let ac = [$alpha$-acyclicité]
#let bc = [$beta$-acyclicité]
#let gc = [$gamma$-acyclicité]

= Généralités

La théorie des hypergraphes est une généralisation de la théorie des graphes, et en particulier des graphes non orientés, dans laquelle une arête peut relier plus de deux sommets entre eux. L'intuition derrière reste sensiblement la même, à l'exception des représentations d'hypergraphes qui varient légèrement de celle des graphes : les arêtes ont plus tendance à être représentées sous forme d'ellipses ou de formes entourant des groupes de sommets ("hyperarêtes").

Le dessin ci-dessous en donne un aperçu.

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

Une première arête rouge relie les sommets $v_0$ et $v_1$, une seconde jaune les sommets $v_3$ et $v_4$, tandis qu'une dernière relie les sommets $v_1$, $v_2$ et $v_3$.


== Quelques définitions

Dans le cadre de la théorie des hypergraphes, on appelle les arêtes des hyperarêtes. On fera souvent (voire systématiquement) un abus de language en les appelant arête comme pour un graphe.

La définition ci-après introduit de manière plus précise ce qu'est un hypergraphe, et en constitue une première approche formelle.

#definition(title: "Hypergraphe")[
  Soit $X = { x_1, x_2, ..., x_n }$ un ensemble fini. Un hypergraphe sur $X$ est une famille $H = (E_1, E_2, ..., E_p)$ de parties de $X$ vérifiant :

  1. $ forall i in bracket.l.double 1, p bracket.r.double, space E_i != emptyset $

  2. $ union.big_(i=1)^p E_i = X $
]

Les éléments de $X$ sont les sommets de l'hypergraphe, et les éléments de la famille $H$ sont les arêtes de l'hypergraphe. On réduira souvent l'hypergraphe à $H$ la famille de ses arêtes, $X$ étant défini implicitement par l'union des éléments de $H$.

En outre, $X$ est *fini*, ce qui implique qu'on ne s'intéressera pas à une généralisation des graphes infinis.

#remark[
  Cette définition#footnote[Donnée notamment par Claude Berge, ancien directeur de recherches au CNRS, dans son ouvrage _Graphes et hypergraphes_] est assez contraignante. On peut en trouver une autre (sur _Wikipédia_ notamment) ne mentionnant pas la seconde condition.

  Un hypergraphe n'a donc, avec la définition précédente, aucun sommet isolé.
]

Dès lors, un graphe est un hypergraphe dont toutes les arêtes relient deux sommets exactement (nécessairement différents si on n'autorise pas la présence de boucles), soit pour tout $i$
$ abs(E_i) = 2 $

Une autre notion, réutilisée ultérieurement pour les bases de données, est celle d'arbre de jointure. Tout hypergraphe n'admet pas nécessairement un arbre de jointure, mais il est définit de la manière suivant sous réserve d'existence.

#definition(title: "Arbre de jointure")[
  Soit $H$ un hypergraphe sur $X$. On considère $T$ un graphe dont les sommets sont les arêtes de $H$.

  $T$ est un arbre de jointure de $H$ si et seulement si
  1. Pour tout sommet $v$ de $H$, le sous-graphe de $T$ engendré par l'ensemble des sommets de $T$ contenant $v$ (les arêtes de $H$ contenant $v$) est connexe.
  2. $T$ est un arbre
]

Bien évidemment, un des buts sera de déterminer s'il existe un arbre de jointure, et de le calculer au passage.

== Développements sur l'acyclicité

La généralisation de l'acyclicité aux hypergraphes est ambigüe : réaliser un cycle revient essentiellement à partir d'un sommet avant de revenir sur lui-même sans "repartir en  arrière". Comme toute généralisation qui se respecte, la restriction de la condition d'acyclicité sur un hypergraphe doit rester valide dans le cadre d'un graphe non orienté.

Plusieurs définition de l'acyclicité ont donc vu le jour : l'#ac, la #bc, la #gc et la Berge-acyclicité. Il est important de noter ces définitions de sont pas équivalentes ! Notamment,

#align(center)[
  Berge-acyclicité $<==$ #gc $<==$ #bc $<==$ #ac
]

Ces différences proviennent du point de vue porté sur les hypergraphes :
- la Berge-acyclicité nous vient de Claude Berge.
- la #bc de la combinatoire (et de Berge aussi). Un hypergraphe $beta$-acyclique (_super-balanced hypergraph_ en anglais), partage certaines caractéristiques des graphes bipartis#footnote[https://en.wikipedia.org/wiki/Balanced_hypergraph].
- l'#ac et la #gc tirent les origine des bases données. On s'y intéressera donc tout particulièrement.

#definition(title: "Berge-acyclicité")[
  Soit $H$ un hypergraphe sur $X$.

  Un _Berge-cycle_ est une suite $(E_1, x_1, ..., E_p, x_p)$ où $p >= 2$ telle que

  1. les $E_i$ sont des arêtes distinctes

  2. les $x_i$ sont des sommets distincts

  3. pour tout $i in bracket.double 1, p bracket.double.r$, $x_i in E_i inter E_(i+1)$ (avec $E_(n+1) = E_1$)

  $H$  est dit _Berge-acyclique_ s'il ne contient aucun _Berge-cycle_.
]

Dans l'essentiel, cela veut dire qu'on a trouvé un chemin partant et revenant à $x_1$ par des sommets et arêtes distinctes.

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
  weights: (0.8, 0.8, 0.8),
  gap: 40pt,
)

Ici, passer par les sommets $(v_0, v_1, v_2, v_3)$ distincts ne garantit pas que les arêtes soient distinctes (parce qu'une arête n'est pas définie par un couple de deux sommets). De même dans l'exemple suivant, où passer par les sommets $(v_0, v_1, v_2, v_0, v_4, v_3, v_0)$ respecte le caractère distinct des sommets, mais pas des arêtes.

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
)

Ces deux hypergraphes ne sont pas Berge-acyclique, le suivant l'est en revanche !

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
  gap: 40pt,
)

#definition(title: [#bc])[
  Soit $H$ un hypergraphe sur $X$, et $cal(E) = (E_1, x_1, ..., E_p, x_p)$ un Berge-cycle.

  $cal(E)$ est un $beta$-cycle si $x_i$ appartient à $E_i$, $E_(i+1)$ et à aucun autre $E_j$.

  $H$ est dit $beta$-acyclique s'il ne contient aucun $beta$-cycle.
]

#definition(title: [#ac])[
  Soit $H$ un hypergraphe sur $X$. $H$ est $alpha$-acyclique s'il contient un arbre de jointure.
]

== Réduction Graham-Yu-Ozsoyoglu

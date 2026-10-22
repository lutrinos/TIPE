#import "../customization/great-theorems-customized.typ": *

= Représentation des hypergraphes

Il existe différentes manières de réprésenter un hypergraphe avec un schéma et en mémoire. On introduit également ici le graphe représentatif d'un hypergraphe, amenant à la notion de dual.

== Représentation graphique

Lorsqu'on représente un graphe, on dessine dans un premier temps les sommets sous forme de points dans l'espace, avant de relier les sommets entre eux pour chaque arête du graphe. Toutefois, quand on considère un hypergraphe, une arête relie plus de deux sommets, donc un segment reliant deux sommets ne suffit pas. On représente donc une arête par une surface recouvrant les sommets qu'elle relie, comme le suggère les représentations précédentes. Il s'agit sans doute de la repésentation la plus intuitive parce qu'étant la plus proche de celle des graphes.

L'illustration disponible sur Wikipédia utilise cette représentation de manière moins schématique que celle utilisée ici.

#figure(image("../images/hyp_wiki.png", width: 200pt), caption: [Exemple de réprésentation d'hypergraphe (Wikipédia)])

Il est également possible de représenter les arêtes comme des lignes de couleurs, reliant entre eux toutes les sommets de l'arête.

#figure(image("../images/hyp_line.png", width: 200pt), caption: [Exemple de représentation d'hypergraphe (lignes)])

== Matrice d'adjacence

Tout comme les graphes, on peut représenter un hypergraphe sous la forme d'une matrice d'adjacence.

#definition(title: "Matrice d'adjacence")[
  Soit $H$ un hypergraphe sur $X$. On appelle matrice d'adjacence de $H$ la matrice $cal(A)$ telle que
  $ forall a_(i,j) in cal(A), a_(i,j) = cases(1 " si " v_i in E_j, 0 " sinon") $
  Avec $n = abs(X)$ et $m = abs(H)$, on a donc $cal(A) in cal(M)_(n,m)({0,1})$
]

Ainsi, les lignes correspondent aux sommets et indiquent si le sommet $v_i$ est dans l'arête $E_j$,  tandis que les colonnes correspondent aux arêtes.

De plus, on remarque qu'il n'y a pas de perte d'information : pour un nombre d'arêtes donné une matrice correspond de manière unique à un hypergraphe (à condition qu'il n'y ait ni de ligne ni de colonne nulle).

#proposition[
  L'ensemble des hypergraphes sur $X = {x_1, ..., x_n}$ à $m$ arêtes est en bijection avec $cal(M)_(n.m) ({0, 1})$
]

#proof[
  On pose $A$ l'ensemble des hypergraphes sur $X = {x_1, ..., x_n}$ à $m$ arêtes, et on considère $phi : A --> cal(M)_(n,m) ({0,1})$ associant à un hypergraphe sa matrice d'adjacence. Montrons que $phi$ est bijective.

  Injection : Soient $H$, $H'$ deux hypergraphes tels que $phi(H) = phi(H') = M$. Alors $H$ et $H'$ ont les mêmes arêtes reliant les même sommets, donc pour tout $i$, $E_i = E'_i$ et $H = H'$.

  Surjection : Pour $M in cal(M)_(n,m) ({0,1})$, on construit juste le graphe qui lui correspond.
]

_Note : C'est juste une formalisation de l'idée._

#question[
  Il y a-t-il des propriétés particulières reliant les matrices d'adjacences avec les hypergraphes ? (graphes simples, r-uniforme...)
]

== Graphe représentatif

Cette partie permet de faire (partiellement) le pont entre les graphes et hypergraphes.

#definition(title: "Graphe représentatif")[
  Soit un hypergraphe $H = (E_1, E_2, ..., E_p)$ sur $X$. Son _graphe représentatif_ $L(H)$ est le graphe dont les sommets sont des points $e_1, e_2, ..., e_p$ représentant respectivement les arêtes de $H$ et tel que $e_i$ est relié à $e_j$ si et seulement si
  $ E_i inter E_j != emptyset $
]

#theorem[
  Tout graphe est graphe représentatif  d'un hypergraphe linéaire, _i.e_ donc les arêtes sont d'intersection non vide deux-à-deux.
]

#proof[
  À faire.
]

#theorem(title: "Graphe représentatif d'un graphe simple - Beineke")[
  Un graphe est le graphe représentatif d'un certain graphe simple s'il ne contient aucun des  sous-graphes induits suivants.

  _Écrire les neufs sous-graphes induits._
]

#proof[
  À faire
]

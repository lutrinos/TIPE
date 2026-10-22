#import "/customization/great-theorems-customized.typ": *
#import "/customization/graph.typ": *

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(
  radius: 0pt,
  zebra-fill: none,
  languages: codly-languages,
)

= Application aux bases de données

#remark[
  La majorité des éléments de cette partie (algorithmes et autres) tirent leur origine de ce papier @luo2025 (anglophone) sur l'optimisation des recherches acycliques ainsi que de @lecture2019
]

== Acyclicité et arbres de jointure

Dans le cadre de l'application aux bases de données la notion d'arbre de jointure est particulièrement intéressante. Tout hypergraphe n'admet pas nécessairement un arbre de jointure, et il est défini de la manière suivante sous réserve d'existence.

On s'intéresse tout d'abord à la manière dont on va contruire l'hypergraphe, à partir d'une requête  conjonctive.

#definition(title: "Hypergraphe d'une requête")[
  Soit une requête acyclique $q$.
  $ q(x_1, ..., x_n) :- R_1(arrow(y_1)),...,R_p (arrow(y_p)) $
  On pose l'hypergraphe $H(q) = (V, E)$ associé à $q$ de la façon suivante :
  - l'ensemble des sommets $V$ contient toutes les variables du corps de $q$
  - l'ensemble des arêtes $E$ contient, pour chaque clause atomique de la requête, l'ensemble des variables apparaissant dedans.
]

On cherche ensuite un cas dans lequel la requête est plus  simple à utiliser (_i.e._ avec moins de conditions contraignantes). Une manière est de cherche un arbre de jointure sur cet hypergraphe.

#definition(title: "Arbre de jointure")[
  Soit $H$ un hypergraphe sur $X$. On considère $T$ un graphe ayant pour sommets les arêtes de $H$.

  $T$ est un arbre de jointure de $H$ si et seulement si

  1. Pour tout sommet $v$ de $H$, le sous-graphe de $T$ engendré par l'ensemble des sommets de $T$ contenant $v$ est connexe.

  2. $T$ est un arbre.
]

Bien évidemment, un des buts sera de déterminer s'il existe un arbre de jointure (réduction GYO). Cet arbre de jointure n'est bien évidemment pas unique.

#definition(title: [$alpha$-acyclicité])[
  Soit $H$ un hypergraphe sur $X$. $H$ est $alpha$-acyclique s'il contient un arbre de jointure.
]

Cette définition d'$alpha$-acyclicité ne va pas de soi...mais ce n'est pas là où il faut mettre l'accent. En revanche, un point qui peut poser problème est la connexité : ce qui nous intéresse est que la requête soit acyclique, connexe ou non.

On utilise alors, de manière similaire à la théorie des graphes, le vocable de forêt.

#definition(title: "Forêt de jointure")[
  Un forêtde jointure d'une requête conjonctive est une forêt $F = (V, E)$ dont tous les sommets sont des clauses atomiques de $q$ et tel que pour chaque paire de clauses atomiques $R$ et $S$ ayant des variables en commun, les condition suivantes soient vérifiées :
  - $R$ et $S$ appartiennent à la même composante connexe.
  - toutes les variables communes à $R$ et $S$ sont présentes  sur un unique chemin de $R$ à $S$.

  On appelle $F$ arbre de jointure si c'est un arbre.
]

#proposition[
  Une requête conjonctive est acyclique si et seulement si elle possède une forêt de jointure.
]

== Réduction Graham-Yu-Ozsoyoglu

Les algorithmes décris dans cette partie proviennent en partie de @lecture2019. Il est intéressant de  remarquer que l'approche diffère légèrement de @duris2009 et @braultbaron2014 par la définition du procédé.  L'algorithme présenté est plus pratique dans le cadre théorique, l'implémentation différera légèrement pour des raisons de commodité.

Pour cela on définit _an hear_, innocemment traduit en français par oreille#footnote[À vrai dire, je n'ai pas cherché la traduction académique française.].

#definition(title: "Oreille")[
  Une oreille d'un hypergraphe $H$ est une arête $E$ telle qu'il existe une autre arête $F$ appelée _arête témoin_ vérifiant

  Pour tout sommet $x in E$ non exclusivement dans $E$, $x in F$.
]

#hypergraph(
  nodes: (
    (0, 0),
    (0, 1),
    (1, 1),
    (1, 0),
    (2, 1),
    (3, 0),
    (3, 1),
    (4, 0),
  ),
  edges: (
    (0, 1),
    (2, 3, 4),
    (2, 3),
    (5, 6),
    (5, 7),
    (6, 7, 6),
  ),
)

Dans l'hypergraphe ci-dessus, seules les arêtes rouges, vertes et jaunes sont des oreilles.

L'algorithme suivant, dit de réduction GYO (pour Graham-Yu-Ozsoyoglu) permet de détecter l'$alpha$-acyclicité d'un hypergraphe.

#code(title: "Graham-Yu-Ozsoyoglu")[
  - *Entrée : * hypergraphe $H$
  - *Sortie : * booléen indiquant si $H$ est acyclique
  - $$
  - *Tant que * $H$ a une oreille *faire*
    - $e <-$ oreille de $H$
    - retirer toutes les arêtes exclusivement dans $e$
    - retirer $e$
  - *Fin*
  - $$
  - *Renvoyer* $H$ est l'hypergraphe vide
  #h(1fr)
]

L'implémentation consiste par contre à appliquer successivement ces deux règles :
- on enlève tous les sommets présents dans une seule arête
- si une arête est incluse dans une autre arête, on la retire

On peut montrer que l'hypergraphe est $alpha$-acyclique si et seulement si on obtient l'hypergraphe vide à la fin de cette procédure.

L'idée est la suivante :
- dès qu'on retire un sommet isolé, on ne perd aucune information sur $T$. On retire d'ailleurs son arête avec si elle ne contient que lui.
- si une arête $E$ est incluse dans une autre arête $F$, alors les sommets $E$ et $F$ sont nécessairement reliés dans $T$ (on crée la connexité sans briser l'acyclicité).
- si une de ces étapes n'est pas faisable et que l'hypergraphe n'est pas vide, on ne  peut pas contruire $T$ : on créera forcément un cycle.

Et alors, quelle utilité lors de requêtes ? Une fois l'arbre de jointure enraciné, les informations se propageant par les arêtes, des feuilles aux parents successifs, contiennent toute l'information nécessaire pour réaliser la requête !

#reminder[
  Réfléchir aux requêtes triangulaires, et à ce qui coince ensuite pour les requêtes cycliques.
]

/*
#code(title: "Graham-Yu-Ozsoyoglu")[
  - *Entrée : * hypergraphe $H$
  - *Sortie : * booléen indiquant si $H$ est acyclique

  - invalide $<-$ vrai

  - *Tant que * invalide *faire*
    - *Si* il existe $v$ sommet isolé dans $H$ *alors*
      - retirer $v$ de $H$
      - *Continuer*
    - *Si* il existe $E$ arête vide de $H$ *alors*
      - retirer $E$ de $H$
      - *Continuer*
    - *Si* il existe $E subset E'$ dans $H$ *alors*
      - retirer $E$ de $H$
      - *Continuer*
    - *Sinon*
      - invalide $<-$ faux

  - *Si* $H$ est vide *alors*
    - *Renvoyer* vrai
  - *Sinon*
    - *Renvoyer* faux
  #h(1fr)
]*/

== Algorithme de Yannakakis

Cet algorithme est expliqué dans @lecture2019, la thèse @duris2009 cite également le papier original et l'auteur (Yannakakis) à de nombreuses reprises. Il a été initialement présenté dans @yannakakis1981.

À faire :
- présenter l'algorithme, expliquer pourquoi il fonctionne (préparer des éléments de preuve)
- simuler "à la main" l'exécution d'une requête ?
#code(title: "Yannakakis")[
  - *Entrée : * une requête conjonctive $q$, une instance $I$
  - *Sortie : * $q(I)$
  - $$
  - $J <-$ instance consistante issue de $I$
  - $T <-$ arbre de jointure de $q$ avec une racine choisie arbitrairement
  - $R_1, ..., R_n <-$ parcours postfixe de $T$
  - *Pour* $i = 1, ..., n$ *faire*
    - $S_1, ..., S_k$ enfants de $R_i$ dans $T$
    - *Pour* $j = 1, ..., k$ *faire*
      - $R_i^J <- pi_("vars"(R_i) union "head"(q)) (R_i^J join S_j^J)$
    - *Fin*
  - *Fin*
  #h(1fr)
]


L'idée derrière est d'élaguer au plus tôt les résultats intermédiaires, qui ne seront pas tous pertinents ultérieurement, afin que les résultats intermédiaires de la jointure .

L'idée derrière l'algorithme est que si on a une variable $x$ apparaissant dans un noeud et non dans son parent de l'arbre de jointure, celle-ci n'apparaît dans aucun des ancêtres.

```
To show that we obtain the desired complexity, we will prove that no intermediate result can grow
more than a polynomial in the size of the input and output. Consider some node with atom R and
children S1, . . . , Sn. Then the algorithm will replace this node with a new node T′ = πY∪Z(T),
where T = R ./ S1 ./ . . . Sn, Y are the variables in R, and Z are the variables in head(q) \ Y. Since
Y, Z are disjoint, πY∪Z (T) ⊆ πY (T) × πZ (T). Now notice that πY (T) is at most the size of R. Also,
πZ (T) is bounded by the size of the output (but only because we took care of dangling tuples by
applying the full reducer).
```


#theorem(title: "Complexité temporelle")[
  L'algorithme de Yannakakis évalue une requête conjonctive acyclique en un temps polynomial par rapport à la taille de la requête, l'entrée et la sortie.

  En pratique, si $I$ est une instance de taille $N$, alors
  - si $q$ est une requête booléenne, la requête est évaluée en $O(N)$.
  - si $q$ _is full_, la requête est évaluée en $O(N + "SORTIE")$ ou $"SORTIE"$ est la taille de la sortie.
]

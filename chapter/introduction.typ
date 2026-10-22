#import "../customization/great-theorems-customized.typ": *
#import "../customization/graph.typ": *

= Introduction aux hypergraphes

La théorie des hypergraphes est une généralisation de la théorie des graphes (des graphes non orientés plus particulièrement) où une arête peut relier plus de deux sommets entre eux. Par exemple, dans un hypergraphe, 4 sommets peuvent tout à fait être relié par une seule et même arête.

== Premières définitions

Dans le cadre de la théorie des hypergraphes, on appelle les arêtes des hyperarêtes, même si on fera souvent un abus de language en les appelant arêtes comme pour un graphe.

#definition(title: "Hypergraphe")[
  Soit $X = { x_1, x_2, ..., x_n }$ un ensemble fini. Un hypergraphe sur $X$ est une famille $H = (E_1, E_2, ..., E_p)$ de parties de $X$ avec :
  1. $ forall i in bracket.l.double 1, p bracket.r.double, E_i != emptyset $
  2. $ union.big_(i=1)^p E_i = X $
]

Les éléments de $X$ sont les sommets, et les éléments de la famille $H$ sont les arêtes de l'hypergraphe.

En outre, $X$ est *fini*, ce qui implique qu'on ne s'intéressera pas à une généralisation des graphes infinis.

#remark[
  Cette définition#footnote[Donnée notamment par Claude Berge, ancien directeur de recherches au CNRS, dans son ouvrage _Graphes et hypergraphes_] est assez contraignante. On peut en trouver une autre (sur Wikipédia notamment) ne mentionnant pas la seconde condition.

  Un hypergraphe n'a donc, avec la définition précédente, aucun sommet isolé.
]

Dès lors, un graphe est un hypergraphe dont toutes les arêtes relient deux sommets exactement (non nécessairement différents si on autorise la présence de boucles), soit pour tout $i$
$ abs(E_i) in {1, 2} $

#remark[
  On trouve parfois la notation $ H = (X; E_1, ..., E_m) $
]

#example[
  Un hypergraphe connu#footnote[Proche de la représentation des reliques de la mort dans _Les Reliques de la Mort_ de la saga éponyme Harry Potter] est l'hypergraphe du plan de Fano.

  #figure(image("../images/fano.png", width: 160pt), caption: [Hypergraphe du plan de Fano])
]

Cet hypergraphe contient 7 sommets numérotés de 0 à 6 donc $ X = {0, 1, 2, 3, 4, 5, 6} $
Et les arêtes sont ici représentées par des droites et cercles, ce qui donne $ H = { {0,1,3}, {0,4,5}, {0,2,6}, {1,2,4}, {3,4,6}, {3,2,5}, {5,1,6} } $

On définit ensuite certaines notations relatives aux hypergraphes.

#definition(title: "Notations")[
  Soit un hypergraphe $H$ sur $X$, on définit les notations suivantes.
  - l'_ordre_ de $H$ est le nombre de sommets qu'on note $ n(H) = abs(X) $
  - le _nombre d'arêtes_ de $H$ est noté $ m(H) = abs(H) $
  - le _rang_ de $H$ le cardinal maximal des arêtes $ r(H) = max_j (abs(E_j)) $
  - l'_anti-rang_ de $H$ le cardinal minimal des arêtes $ s(H) = min_j (abs(E_j)) $
]

#remark[
  On retrouve les même notions d'ordre et de nombre d'arête que pour les graphes, auxquelles on a ajouté le rang et l'anti-rang d'un hypergraphe, qui caractérisent des propriétés portant sur les arêtes dans ce cadre précis.
]

Prenons l'hypergraphe $(X, H)$ suivant.

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
  weights: (1, 1, 0.8, 1, 1),
)

Ses noeuds sont numérotés de 0 à 5, il a donc 6 noeuds et est d'ordre 6. Il a de plus 4 arêtes (bleue, rouge, jaune et verte). L'arête recouvrant le plus de sommet est l'arête rouge, et celle recouvrant le moins de sommet l'arête bleue. Le rang de ce graphe est donc 3 et son anti-rang est 1.

#proposition[
  Pour tout graphe $(X,H)$ avec $H$ non vide, on a l'inégalité suivante.
  $ 1 <= s(H) <= r(H) <= abs(X) = n(H) $
]

#proof[
  Il s'agit d'une conséquence logique de la définition donnée :
  - toutes les arêtes sont non vides donc de cardinaux strictement positif
  - l'élément maximal est supérieur à l'élément minimal
  - l'arête la plus grande ne peut pas relier plus de sommet qu'il n'y en a
]

On introduit la notion d'hypergraphe simple généralisant celle de graphe simple.

#definition(title: "Hypergraphe simple")[
  Un hypergraphe simple sur $X$ est un hypergraphe $H = (E_1, E_2, ..., E_p)$ dont aucune arête n'en contient une autre. \
  Autrement dit, pour tout $i, j in bracket.l.double 1, p bracket.r.double$
  $ E_i subset E_j /*" ou " E_j subset E_j*/ ==> i = j $
]

Par exemple, l'hypergraphe du plan de Fano est un hypergraphe simple : aucune arête n'est "incluse" dans une autre (les droites et cercles ne se superposent pas). Au contraire, dans l'exemple suivant, l'arête jaune est "contenue" dans l'arête verte donc cet hypergraphe n'est pas simple.

#remark[
  Cette définition est cohérente avec celle des graphes simples pour lesquels il y a au plus une arête entre deux sommets, à la différence des multigraphes.
]

Ainsi, tout graphe simple est un hypergraphe simple.

#proof[
  Soit $G = (V, E)$ un graphe simple, supposant qu'il existe $e_i$ et $e_j$ arêtes liant $x_p$ et $x_q$ sommets de $G$. Alors $e_i$ = $e_j$ (égalité d'ensembles, non de 2-uplets) et en particulier $e_i subset e_j$ ce qui correspond à la définition donnée.
]

#definition(title: "Hypergraphe uniforme et complet")[
  Pour un hypergraphe $H$ sur $X$, on dit que $H$ est _uniforme_ si toutes ses arêtes ont le même cardinal $ r(H) = s(H) $
  On dit de plus qu'il est _r-uniforme_ si $H$ est simple uniforme de rang $r$.

  Il est dit _r-complet_ si $H$ est l'ensemble des parties de $X$ de cardinalité $r$, on le note $K_n^r$ avec $n = abs(X)$.
]

#remark[
  Pour $r=2$, on retrouve la définition de graphe complet (pour deux sommets _u_ et _v_ quelconques il existe une arête reliant _u_ et _v_).
]

D'ailleurs la notation est la même !

#lemma[
  Pour $0 <= r <= n$, $ abs(K_n^r) = binom(n, r) $
]

#proof[
  L'emsemble des parties de $X$ de cardinalité $r$ contient $binom(abs(x), r)$ éléments.
]

#reminder[
  Attention, il faut que l'hypergraphe soit simple dans la définition de r-uniforme ! Si on a égalité du rang et de l'anti-rang il faut que tout les éléments de $H$ soient deux à deux différents (qu'il n'y ait pas d'arêtes dupliquées comme toutes les arêtes ont le même cardinal).
]

L'hypergraphe ci-dessous est 3-uniforme par exemple, ses deux arêtes (verte et rouge) sont toutes deux de cardinal 3.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (0, 1),
    (1, 1),
  ),
  edges: (
    (0, 1, 2),
    (0, 1, 3),
  ),
  weights: (1, 0.8),
)

En revanche, il n'est pas 3-complet, car il y a $binom(4, 3) = 4$ arêtes de cardinalité 3 qu'on peut contruire. L'hypergraphe ci-dessous est lui 3-complet.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (0, 1),
    (1, 1),
  ),
  edges: (
    (0, 1, 2),
    (0, 1, 3),
    (0, 3, 2),
    (1, 3, 2),
  ),
  weights: (1, 0.8, 0.6, 0.4),
  opacity: 0%,
)

Ces hypergraphes deviennent par contre rapidement illisible...

#proposition[
  Tout graphe r-complet est r-uniforme.
]

#proof[
  Dans tout graphe r-complet, $H$ est l'ensemble des parties de $X$ de cardinalité $r$, donc toutes ses arêtes sont de cardinal $r$ et en particulier
  $ r(H)= s(H) $
  Il s'agit donc de montrer qu'il est simple. Soit $i, j in bracket.l.double 1, abs(H) bracket.r.double$ tel que
  $ E_i subset.eq E_j $
  Toutes les arêtes sont de cardinal $r$ donc par égalité des cardinaux (ce sont des ensembles finis)
  $ E_i = E_j $
  Comme $H$ parcourt l'ensemble des parties de $X$ à $r$ éléments, chaque partie est placée une unique fois dans $H$, donc $i = j$ et $(X, H)$ est bien simple donc r-uniforme.
]

== Hypergraphes partiels et sous-hypergraphes

Pour un hypergraphe $(X, H)$ considéré, on peut lui retirer des sommets ou des arêtes. On définit un hypergraphe partiel issu d'un hypergraphe auquel on a a retiré des arêtes, puis un sous-hypergraphe (d'un hypergraphe auquel on a retiré des sommets).

#definition(title: "Hypergraphe partiel")[
  /*Soit $H = (E_1, E_2, ..., E_p)$ un hypergraphe sur $X$. On appelle hypergraphe partiel de $H$ engendré par un ensemble $J subset.eq { 1,2, ..., p }$ la famille
  $ H_J = (E_j | j in J) $*/
  L'hypergraphe partiel de $H = (X, cal(E))$ engendré par une famille $cal(F) subset cal(E)$ est l'hypergraphe $(X_cal(F), cal(F))$ où $ X_cal(F) = union.big_(E_i in cal(F)) E_i $
]

#definition(title: "Sous-hypergraphe")[
  /*Soit $H = (E_1, E_2, ..., E_p)$ un hypergraphe sur $X$. On appelle sous-hypergraphe de $H$ induit par un ensemble $A subset.eq X$ la famille
  $ H_A = (E_j | E_j subset.eq A " pour " 1 <= j <= p) $*/
  Le sous-hypergraphe de $H = (X,cal(E))$ engendré par un ensemble $A subset X$ est l'hypergraphe $H_A = (A, cal(E)_A)$ où $ cal(E)_A = { E_i inter A | E_i in cal(E) "avec" E_i inter A != emptyset } $
]

Nous avons _in fine_ les quelques propositions suivantes.

#proposition[
  Tout sous-hypergraphe de $H$ hypergraphe simple est simple.
]

#proof[
  La propriété est vraie sur ${1, 2, ..., abs(H)}$ donc en particulier sur $J subset.eq {1, 2, ..., abs(H)}$
]

Attention, cette propriété n'est pas vraie pour un hypergraphe partiel ! Si on retire le noeud $v_3$ le graphe ci-dessous n'est plus simple.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (2, 0),
    (2, 1),
  ),
  edges: (
    (0, 1, 2),
    (1, 2, 3),
  ),
  gap: 40pt,
)

#proposition[
  Tout sous-hypergraphe d'un hypergraphe uniforme reste uniforme.
]

#proof[
  Toutes les arêtes ont le même cardinal, ce qui reste vrai si on enlève une arête. S'il ne reste plus d'arête, alors la propriété reste également vraie.
]

#corollary[
  Tout sous-hypergraphe d'un hypergraphe r-uniforme est r-uniforme.
]

#proof[
  Conséquence logique des deux propositions précédentes.
]

== Propriétés sur les sommets

Tout comme dans les graphes, on peut définir le degré d'un sommet d'un hypergraphe avec la notion d'étoile centrée en un sommet.

#definition(title: "Degré")[
  Soit $x in X$, on appelle étoile centrée en $x$ l'hypergraphe partiel de $H$ formé des arêtes contenant $x$, qu'on note $H(x)$.

  Le degré du sommet $x$ est alors $ d_H (x) = abs(H(x)) $
]

Encore une fois, on retrouve une définition du degré proche de celle sur les graphes, il s'agit du nombre d'arêtes dont un des extrémités est $x$ (même si une hyperarête a en quelque sorte plusieurs extrémités). Toutefois, à la différence des graphes, on ne peut pas définir de degré sortant ou de degré entrant car les arêtes ne sont pas orientées. On peut en proposer une reformulation qui nous sera plus utile par la suite.

#lemma[
  Soit $H$ un hypergraphe sur $X$ et $x in X$. On a
  $ d_H (x) = sum_(E in H) bb(1)_E (x) $
]

#proof[
  On a d'après la définition
  $ H(x) = (E_i | x in E_i, 1 <= i <= abs(H)) $
  Donc le degré de $x$ dans $H$ vaut
  $ d_H (x) = sum_(E in H \ x in E) 1 $
  Or
  $ bb(1)_E (x) = cases(1 " si " x in E, 0 " sinon") $
  Et
  $
    d_H (x) & = sum_(E in H \ x in E) 1 + sum_(E in H \ x in.not E) 0 \
            & = sum_(E in H) bb(1)_H (x)
  $
]

#proposition[
  Soit $H$ un hypergraphe sur $X$, alors
  $ sum_(s in X) d(s) = sum_(E in H) abs(E) $
]

#proof[
  On utilise le lemme précédent.
  $
    sum_(s in X) d(s) & = sum_(s in X) sum_(E in H) bb(1)_E (s) " par le lemme"               \
                      & = sum_(E in H) sum_(x in X) bb(1)_E (x) " car les sommes sont finies" \
                      & = sum_(E in H) sum_(x in X inter E) 1                                 \
                      & = sum_(E in H)sum_(x in E) 1 " car " E subset.eq X                    \
                      & = sum_(E in H) abs(E) " par définition de " abs(E)
  $
]

#corollary[
  Avec $G = (V, E)$ un graphe, alors
  $ sum_(s in X) d(s) = 2 abs(E) $
]

#proof[
  Direct avec la proposition précédente.
  $
    sum_(s in X) d(s) & = sum_(v in E) abs(v) \
                      & = sum_(v in E) 2      \
                      & = 2 abs(E)
  $
]

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

On remarque d'ailleurs que ces limites peuvent être atteintes dans des cas particuliers, avec par exemple $H = K_(2n)^n$ (ou $H = K_(2n+1)^(n+1)$).

La seconde inégalité peut se comprendre de la manière suivante : étant donné un ensemble $X$, comment faire pour maximiser le nombre d'arêtes en gardant un hypergraphe simple ? Intuitivement, on peut procéder de deux manières différentes :
- rajouter toutes les arêtes possibles puis enlever celles qui empêchent le plus d'autres arêtes pour conserver la propriété de simplicité. On se rend alors compte qu'un hypergraphe complet avec un nombre intermédiaire d'arêtes est optimal
- rajouter des arêtes de même cardinal au fur et à mesure pour parcourir toutes les possibilités. On construit alors un hypergraphe complet, qui est optimal lorsque les arêtes ont un cardinal encore une fois "intermédiaire".

Par exemple, avec $K_4^2$ on obtient le graphe complet suivant.

#hypergraph(
  nodes: (
    (0, 0),
    (1, 0),
    (1, 1),
    (0, 1),
  ),
  edges: (
    (0, 1),
    (2, 3),
    (1, 2),
    (3, 0),
    (2, 0),
    (1, 3),
  ),
  weights: (1, 1, 0.8, 0.8, 0.6, 0.6),
  opacity: 20%,
)

Dans un graphe, cette propriété donne une majoration intéressante et assez intuitive du nombre d'arêtes.

#corollary[
  Soit $G = (V, E)$ un graphe sans boucle ni arêtes multiples, alors
  $ abs(E) <= binom(abs(V), 2) $
]

#proof[
  Soit $G = (V, E)$ graphe (vu comme un hypergraphe) sans boucle, pour tout $i in bracket.l.double 1, abs(E) bracket.r.double$,
  $ abs(E_i) = 2 $
  Par la première inégalité du théorème de Sperner
  $
    sum_(E in H) binom(abs(V), abs(E))^(-1) & = sum_(E in H) binom(abs(V), 2)^(-1) \
                                            & = abs(E) binom(abs(V), 2)^(-1) <= 1
  $
  Soit
  $ abs(E) <= binom(abs(V), 2) $
]

== Retour sur la terminologie

#definition("Adjacence")[
  Soit $(X, H)$ un hypergraphe
  - $x,y in X$ sont dit adjacents s'il existe une arête $E_i$ les contenant tout deux $ exists i, {x, y} subset.eq E_i $
  - $E_i, E_j in H$ sont dit adjacents si leur intersection est non nulle (autrement dit s'ils ont un sommet en commun) $ E_i inter E_j != emptyset $
]

Comme pour les graphes non orientés, la relations d'adjacence est réflexive et symétrique.

#lemma[
  Soit $H = (X, E_1, ..., E_m)$, alors
  $ abs(E_i union E_j) = abs(E_i) + abs(E_j) <==> E_i "et" E_j "non adjacentes" $
]

#proof[
  On a
  $
    & abs(E_i union E_j) = abs(E_i) + abs(E_j) - abs(E_i inter E_j) = abs(E_i) + abs(E_j) \
    & <==> abs(E_i inter E_j) = 0                                                         \
    & <==> E_i inter E_j = emptyset                                                       \
    & <==> not (E_i " et " E_j "adjacentes")
  $
]

#question[
  Et la généralisation pour un hypergraphe "éclaté" ?
]

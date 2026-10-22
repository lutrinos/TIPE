
// Configuration rubber (template)
#import "@preview/rubber-article:0.5.2": *
#show: article



// Configuration de theoretic
#import "@preview/theoretic:0.3.1"
//#import theoretic.presets.basic: *
#show ref: theoretic.show-ref

#let block-options = (
  block-args: (
    above: 2em,
    below: 2em,
  ),
)

#let definition = theoretic.theorem.with(
  supplement: "Définition",
  kind: "definition",
  number: none,
  options: block-options,
)

#let proof = theoretic.theorem.with(
  supplement: "Démonstration",
  kind: "proof",
  number: none,
  options: block-options,
)

#let theorem = theoretic.theorem.with(
  supplement: "Théorème",
  kind: "theorem",
  number: none,
  options: block-options,
)

// Configuration codly (coloration syntaxique) et lovelace (pseudocode)
#import "@preview/lovelace:0.3.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(
  radius: 0pt,
  zebra-fill: none,
  languages: codly-languages,
)

#let code(..args, body) = figure(
  kind: "algorithm",
  supplement: "Algorithme",
  caption: args.named().at("title"),

  pseudocode-list(
    booktabs: true,
    title: args.named().at("title"),
    line-numbering: none,
    indentation: 1.4em,
    line-gap: 0.8em,
    body,
  ),
)



#set text(lang: "fr")
#set par(first-line-indent: 0em)

#maketitle(
  title: "Calcul de requêtes acycliques conjonctives dans une base de données",
  authors: ("Nathan Tillier",),
  date: "31 mai 2026",
)

// Introduction
#abstract(title: "Introduction")[
  Les bases de données relationnelles permettent de structurer et d'interroger de grandes quantités de données. Cependant, le calcul de requêtes conjonctives se heurte à une barrière majeure : il s'agit d'un problème NP-complet.
  
  Toutefois, un certain nombre de requêtes, celles conjonctives acycliques, peuvent être évaluée en temps linéaire grâce à l'algorithme de Yannakakis. À travers l'implémentation d'un moteur de requête en Python et son application à un jeu de données réelles (le découpage administratif français en communes, départements et régions), nous nous intéresserons au fonctionnement de cet algorithme ainsi qu'aux résultats expérimentaux qu'il permet.
]

= Algèbre relationnelle

== Notations

Une relation $R$ sera notée comme suit :

$ "R"("attribut"_1: "domaine"_1, ..., "attribut"_n : "domaine"_n) $

Sa création correspond au code SQL ci-dessous
```sql
CREATE TABLE R(
    domaine_1 attribut_1,
    ...
    domaine_n attribut_n
)
```

#linebreak()
Par exemple,

```sql
CREATE TABLE commune (
    INT id PRIMARY KEY,
    INT departement,
    CHAR nom
)
```


#linebreak()
Une instance $I$ sur une relation $R$ est un ensemble fini de n-uplets (ou tuples) sur $R$, qu'on notera $R^I$. Une instance $I$ sur le schéma d'une base de données est l'union des instances des relations $R$ du schéma.

#linebreak()

On utilisera les opérations suivantes :
- $pi_V (R)$ la projection d'une relation $R$ sur un ensemble de variables $V$ : elle renvoie la table contenant les tuples distincts de $R$ dont on n'a conservé que les attributs présents dans $V$
- $R join S$ la jointure de $R$ et $S$ : il s'agit des combinaisons de tuples de $R$ et $S$ ayant un attribut commun.

== Requêtes conjonctives

#definition("Requête conjonctive")[
  On considère des requêtes conjonctives sous la forme

  $ q(x_1, ..., x_n) :- R_1 (arrow(y_1)), ..., R_p (arrow(y_p)) $

  Où chaque $y_i$ est un tuple de variables de même arité que $R_i$, et où chaque $x_j$ apparaît dans un $y_i$ au moins. On appellera la partie avant les deux points l'en-tête de la requête et celle après le corps de la requête, chaque expression $R_i (arrow(y_i))$ sera nommée atome.
]


On montre ensuite quelques résultats sur les requêtes conjonctives.

/*
#theorem("Calculabilité des requêtes conjonctives")[
  Étant donné une requête conjonctive $q$ et une instance $I$, l'évaluation de $q$ sur $I$ est calculable.
]

#proof[
  On se munit d'une requête $q$ et d'une instance $I$ de taille $n$ (nombre de tuples de $I$).

  Avec $p$ le nombre d'atomes de $q$, on teste les au plus $n^p$ combinaisons d'assignations possibles pour chaque atome à partir d'éléments de $I$. Pour chaque combinaison, la vérification de la satisfiabilité de $q$ peut être réalisée par un double parcours de la requête (pour chaque variable, on vérifie que toutes ses occurrences prennent la même valeur) : $q$ est donc calculable.
]
*/

#theorem("NP-complétude")[
  L'évaluation d'une requête conjonctive est un problème NP-complet.
]

#proof[
  1. Montrons la NP-difficulté par réduction de 3-SAT.
  Avec $phi$ constituée des variables $x_1, ..., x_k$, on pose pour tout $i$ : $x_i ' equiv not x_i$. \ On construit ensuite
  $ I = { "Clause"(0,0, 1), ..., "Clause"(1, 1, 1) } union { "Negation"(0, 1), "Negation"(1, 0) } $
  de sorte que les tuples de $"Clause"$ représentent les combinaisons de valeurs satisfaisant une clause (au moins un littéral à vrai) et ceux de $"Negation"$ forcent la cohérence entre une variable et sa négation.

  On pose
  $
    q(x_1, ..., x_k) :- { "Clause"(x_i, x_j, x_k) " ; pour tout " (i or j or k) " dans " phi }, { "Negation"(x_i, x_i ') ; forall i in [| 1, k |]) }
  $

  On remarque qu'il existe une valuation satisfaisant $phi$ si et seulement si le résultat de la requête $q(I)$ est non vide.

  2. Montrons l'appartenance à NP.
  Étant donné une requête $q$ et une instance $I$, on prend comme certificat l'ensemble des assignations des variables $x_i$ satisfaisant la requête (de taille polynomiale en $|q|$ et $|"OUT"|$). Le vérificateur va ensuite vérifier que chaque atome de $q$ existe dans $I$ pour chaque assignation (polynomial en $|q|$, $|I|$ et $|"OUT"|$).

  \
  On conclut que l'évaluation d'une requête conjonctive est NP-complète.
]

On s'intéressera donc par la suite à une classe plus restreinte des requêtes conjonctives : celles acycliques.

== Requêtes acycliques conjonctives

Intuitivement, une requête acyclique conjonctive est acyclique si les variables communes entre différents atomes "n'introduisent pas de boucle".

La requête suivante est par exemple cyclique.

```sql
SELECT c.nom, d.nom, r.nom
FROM commune AS c
JOIN departement AS d ON c.departement = d.id
JOIN region AS r ON d.region = r.id AND c.region = r.id
```

#linebreak()
Car on a la dépendance

$ "commune" -> "commune.departement" -> "departement" -> "departement.region" -> "region" -> "region.id" -> "commune" $

#figure(
  image("/documents/tipe/images/requete_cyclique.png", width: 200pt),
  caption: [Schéma représentant les dépendances d'une requête cyclique],
)

Formellement, on introduit l'hypergraphe associé à la requête, ayant pour sommets les variables de la requête, et pour arête les ensembles de variables présents dans chaque atome. \
Puis avec la réduction Graham-Yu-Ozsoyoglu (GYO), on peut construire un arbre de jointure associé à cet hypergraphe si et seulement si la requête est acyclique. @braultbaron2014

\
Cet arbre de jointure vérifie les points suivants :
- ses sommets sont les relations de la requête
- le sous-graphe induit par les relations contenant une même variable partagée est connexe

Sa construction est détaillée dans l'annexe, ainsi que l'algorithme permettant de l'obtenir.

= Calcul du résultat

== Implémentation de la base de données

La structure implémentant la logique d'une base de données est une classe `Table` possédant trois attributs (`name`, `rows` et `columns`).

\
Les champs `name` et `columns` servent à conserver respectivement les noms et attributs des tables, tandis que `rows` est une liste de tuples (immutables en Python) listant les éléments présents dans la table. Dans la mesure où l'on s'intéresse exclusivement à l'évaluation de requêtes, seulement deux méthodes importent : `Table.import_from` permettant de charger un fichier CSV valide, et `Table.project` réalisant une projection sur l'ensemble $V$ des attributs passés en argument.

\
La construction des requêtes se fait ensuite avec des classes intermédiaires, `Query`, `Head` et `Atom`. La définition d'une requête devient ainsi

\
\
```py
Query(
    Head("requête", nom_com, nom_cheflieu),
    Atom("commune", _, _, _, num_dep, _, _, _, _, _, nom_com, _, _),
    Atom("département", num_dep, _, num_cheflieu, _, _, _, nom_dep),
    Atom("commune", _, num_cheflieu, _, _, _, _, _, _, _, nom_cheflieu, _, _)
)
```
\

Où les variables utilisées sont des strings les identifiant de manière unique. Cette requête est équivalente en SQL à

\
\
```sql
SELECT c.nom, cheflieu.nom
FROM commune AS c
JOIN departement AS d ON c.departement = d.id
JOIN commune AS cheflieu ON d.cheflieu = cheflieu.id
```
\
Une classe `Instance` permet de rassembler les différentes tables (méthode `Instance.add_table`) et d'exécuter des requêtes dessus (méthode `Instance.query`).

== Exécution de requêtes

Si l'évaluation d'une requête conjonctive est NP-complète, Yannakakis a introduit en 1981 un algorithme éponyme évaluant une requête conjonctive acyclique en temps linéaire en les tailles de la requête, de l'instance et de la sortie. @yannakakis1981 @lecture2019 @waterloo

#code(title: "Yannakakis")[
  - *Entrée :* une requête conjonctive $q$, une instance $I$
  - *Sortie :* $q(I)$
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


Cet algorithme élague le plus tôt possible les tuples pendants (_dangling tuples_ en anglais), c'est-à-dire les tuples n'intervenant pas dans le résultat de la requête.

#figure(
  image("images/yannakakis_exemple.png", width: 250pt),
  caption: [Arbre de jointure avant les passes],
)

Supposons que l'arbre de jointure soit de la forme ci-dessus. La première passe _bottom-up_ part des feuilles jusqu'à la racine en éliminant les tuples des parents n'ayant pas d'attribut correspondant dans un de ses enfants. Par exemple le département $80$ n'apparaît pas dans la table $"commune"$.

#figure(
  image("images/yannakakis_exemple_2.png", width: 250pt),
  caption: [Arbre de jointure après la passe _bottom_up_],
)

La seconde passe _top-down_ se fait de la racine vers les feuilles en éliminant cette fois des tuples pendants des enfants. Ici, les communes de département $69$ et la région d'identifiant $104$ sont éliminées du résultat.

#figure(
  image("images/yannakakis_exemple_3.png", width: 250pt),
  caption: [Arbre de jointure après les deux passes],
)

Ces deux passages s'implémentent sous la forme de fonctions récursives `bottom_up` et `top_down`, toutes deux utilisant une fonction auxiliaire `semi_join` réalisant une semi-jointure entre les tables $R$ et $S$, notée $R times.l S$. Celle-ci contient les tuples de $R$ pouvant être joints avec au moins un élément de $S$. \

$ R times.l S = pi_("vars"(R)) (R join S) $

La construction des résultats se fait enfin avec un dernier parcours de la racine vers les feuilles, en réalisant des jointures successives avant de projeter le résultat sur les variables de l'en-tête de la requête. \
Une fonction `query` orchestre les étapes successives :
- construction de l'arbre de jointure (réduction GYO)
- passage _bottom-up_
- passage _top-down_
- construction des résultats

#theorem("Correction de l'algorithme de Yannakakis")[
  L'algorithme de Yannakakis évalue une requête conjonctive acyclique $q$ en temps polynomial en la taille de $q$, de l'instance $I$ et de la sortie $"OUT"$.
]

#proof[\
  - *Correction*. Dans l'arbre de jointure, si une variable $x$ apparaît dans un nœud, mais pas dans son père, elle ne va apparaître dans le résultat d'aucun des ancêtres ou enfants de ce nœud. Les tuples éliminés ne sont donc pas utiles dans la construction du résultat.

  - *Complexité*.
    - Afin d'obtenir la complexité souhaitée, on montre qu'aucun résultat intermédiaire ne peut être plus grand qu'un polynôme en la taille de l'entrée et de la sortie. On considère un nœud $R_i$ avec pour enfants $S_1, ..., S_n$ dans un arbre de jointure correspondant à une requête.
    - Ce nœud $R_i$ (nœud dans l'arbre de jointure) sera remplacé par un nœud $R_i^J = pi_(Y union Z) (T)$ où $Y = "vars"(R_i)$ et $Z = "head"(q) without Y$ et $T = R_i join S_1 join ... join S_n$
    - Puisque $Y$ et $Z$ sont disjoints, $pi_(Y union.sq Z)(T) subset pi_Y (T) times pi_Z (T)$. On remarque que $pi_Y (T)$ est de taille bornée par celle de $R_i$, et que $pi_Z (T)$ l'est par la taille de la sortie (car l'exploration se fait dans l'ordre postfixe, donc on a déjà réduit les _dangling tuples_ des enfants $S_1$, ..., $S_n$.
]



== Résultats expérimentaux

Voici un exemple de requête qui permet d'obtenir le nom des communes, départements et régions.
\
\
```sql
SELECT commune.nom, departement.nom, region.nom FROM commune
JOIN departement ON departement.numero = commune.departement
JOIN region ON region.numero = commune.region
```
\
Le temps d'exécution de cette requête est de 0.17 secondes, ce qui est de premier abord assez lent. \
Toutefois, on remarque que les deux derniers parcours de l'arbre de jointure se font de la racine aux feuilles : on peut en réalité construire le résultat lors de la passe _top-down_ directement, ce qui permet de passer à 0.08 secondes pour cette même requête.

De manière générale, cette version "double parcours" réunissant seconde passe et construction du résultat est jusqu'à deux fois plus rapide, ce qui est un gain significatif.

\
On peut ensuite observer expérimentalement l'évolution du temps d'exécution selon la taille de l'instance $I$, de la sortie $"OUT"$ et du nombre de jointures dans la requête. Pour cela, j'ai exécuté trois requêtes réalisant respectivement une, deux et trois jointures sur quatre tables, auxquelles je rajoute au fur et à mesure des éléments tirés aléatoirement dans un intervalle pour augmenter la taille de l'instance et du résultat simultanément. \
Chaque temps mesuré est la moyenne de cinq mesures successives, avec une incertitude estimée à partir d'elles.

\
On observe bien une dépendance linéaire en $|I| + |"OUT"|$, avec une régression linéaire extrêmement proche des points expérimentaux, ce qui est bien ce qui était attendu. En revanche, pour $I$ contenant quatre millions de tuples (quatre tables d'un million d'éléments chacun), une requête avec trois jointures augmente le temps d'exécution d'une demi-seconde par rapport à une seule jointure, soit de 25% : les requêtes complexes risquent d'avoir une constante très élevée.

#figure(
  image("images/stats_join_count_bis.png", width: 400pt),
  caption: [Temps d'exécution en fonction de $|I| + |"OUT"|$],
)

Finalement, le temps d'exécution reste très lent comparé à l'implémentation `sqlite3` : il y a un facteur trois entre ces temps pour une instance avec deux millions d'éléments.

#figure(
  grid(
    columns: 2,
    gutter: 2mm,
    image("images/stats_2.png", width: 200pt), image("images/stats_5_tris.png", width: 200pt),
  ),
  caption: [Temps d'exécution de trois requêtes avec mon implémentation (à gauche) et celle de `sqlite3` (droite)],
)

Ce constat est probablement dû à différents facteurs :
- l'implémentation de `sqlite3` est en C, ce qui permet une gestion plus fine de la mémoire
- `sqlite3` n'utilise _a priori_ pas le même algorithme pour les différentes requêtes, selon le plan d'exécution choisi. C'est ce qui est sans doute à l'origine des coefficients directeurs très proches entre les trois requêtes
- mon implémentation utilise des `set` pour réaliser les semi-jointures, afin d'identifier les attributs partagés. Dans la pratique, certaines structures bien plus légères sont utilisées, comme les filtres de Bloom, qui garantissent l'absence de faux négatif
- dès qu'il y a de nombreuses jointures, certains choix d'arbres de jointures et de racines sont plus judicieux pour éliminer le plus tôt possible les tuples pendants.

= Conclusion

Ce TIPE a permis de mettre en évidence l'efficacité de l'algorithme de Yannakakis pour le traitement des requêtes conjonctives acycliques. Contrairement à l'approche naïve par produit cartésien, cet algorithme garantit une complexité proportionnelle à la taille des données d'entrée et de sortie, évitant ainsi l'explosion combinatoire des résultats intermédiaires grâce aux passes de réduction.

Si l'implémentation en Python a montré ses limites face à des outils comme SQLite, les tests expérimentaux ont confirmé la linéarité théorique. L'optimisation consistant à fusionner la seconde passe et la construction du résultat a permis un gain de performance de 30% à 50%, illustrant l'importance des choix d'implémentation.

Pour aller plus loin, une réécriture dans un langage plus bas niveau permettrait d'obtenir de meilleures performances. De plus, la réalisation d'une sélection après les jointures ainsi que la généralisation de cet algorithme aux requêtes cycliques, en construisant par exemple un ordre sur les atomes avec un filtre de Bloom, offriraient un point de départ intéressant pour traiter n'importe quelle requête SQL.


#bibliography("bibliography.bib", title: "Références")


#pagebreak()

= Annexe

== Hypergraphe

La définition d'une requête conjonctive acyclique nécessite l'introduction d'hypergraphe associé à une requête. On utilisera par la suite la définition donnée par Claude Berge @berge1970.

#definition("Hypergraphe")[
  Étant donné $X$ ensemble fini, un hypergraphe sur $X$ est une famille $H = (E_1, ..., E_p)$ de parties de $X$ vérifiant les points suivants

  - $ forall i in [|1, p|], E_i != emptyset $
  - $ union.big_(i=1)^p E_i = X $
]

#figure(
  image("/documents/tipe/images/hypergraphe.png", width: 200pt),
  caption: [Exemple d'hypergraphe],
)

#definition("Arbre de jointure")[
  Soit $H$ un hypergraphe sur $X$, et $T$ un graphe ayant pour sommet les arêtes de $H$.
  $T$ est un arbre de jointure si
  - $T$ est un arbre
  - pour tout sommet $v$ de $H$, le sous-graphe de $T$ engendré par l'ensemble des arêtes de $H$ contenant $v$ est connexe


  Un tel hypergraphe est dit $alpha$-acyclique.
]

#figure(
  grid(
    columns: 2,
    gutter: 2mm,
    image("images/hypergraphe.png", width: 150pt), image("images/hypergraph-jointure.png", width: 100pt),
  ),
  caption: [Hypergraphe et un arbre de jointure associé],
)

== Acyclicité

Un hypergraphe est dit $alpha$-acyclique si et seulement s'il peut être réduit à l'hypergraphe vide par l'algorithme GYO.

#code(title: "Graham-Yu-Ozsoyoglu")[
  - *Entrée :* hypergraphe $H$
  - *Sortie :* booléen indiquant si $H$ est acyclique
  - $$
  - *Tant que* $H$ possède un sommet isolé ou une oreille *faire*
    - *Si* $v$ est un sommet isolé (appartient à une seule arête $E$) *alors*
      - retirer $v$ de $E$ et de $X$
    - *Si* $E$ est une oreille (incluse dans une autre arête $F$) *alors*
      - retirer $E$ de $H$
  - *Fin*
  - $$
  - *Renvoyer* Vrai si $H$ est vide, Faux sinon
  #h(1fr)
]


#theorem("Équivalence de l'acyclicité")[
  Soit $H$ un hypergraphe. Les propriétés suivantes sont équivalentes :
  1. $H$ est $alpha$-acyclique (réductible à vide par l'algorithme GYO).
  2. $H$ possède un arbre de jointure
]

#proof[
  - *$1 arrow.double 2$* : On procède par récurrence sur le nombre d'arêtes $n$. 
    - Pour $n=1$, l'arbre trivial à un seul nœud est un arbre de jointure. 
    - Supposons la propriété vraie pour $n-1$.
        - Si $H$ est réductible, il existe une oreille $E$ incluse dans une arête $F$ de $H without \{E\}$. Par hypothèse de récurrence, $H without \{E\}$ possède un arbre de jointure $T'$.
        - En ajoutant le nœud $E$ et l'arête $(E, F)$ dans $T'$, on obtient un arbre $T$. 
        - Vérifions la connexité : pour toute variable $x in E$, par définition de l'oreille, on a $x in F$. Si $x$ appartient à une autre arête $G$ de $H$, comme l'ensemble des nœuds contenant $x$ dans $T'$ est connexe et $T'$ contient $F$ et $G$, et que $E$ est relié à $F$, $E$ est également relié à $G$. L'ensemble des nœuds de $T$ contenant $x$ dans $T$ est donc connexe.

  - *$2 arrow.double 1$ (Existence d'une oreille)* :
    - Si $H$ possède un arbre de jointure $T$, considérons une feuille $E$ de $T$ et $F$ son unique voisin. Par la propriété de connexité, toute variable $x$ de $E$ présente dans une autre arête $G$ doit être présente sur le chemin unique entre $E$ et $G$ dans l'arbre. Ce chemin passe nécessairement par $F$. Ainsi, $(E inter union.big_(G != E) G) subset F$. $E$ est donc une oreille éliminable par GYO.
    - Par itération, l'hypergraphe est entièrement réductible.
]


La validité de cet algorithme repose sur deux propriétés critiques :
1. *Terminaison* : À chaque étape, on retire soit un sommet, soit une arête. Comme l'hypergraphe est fini, l'algorithme s'arrête en au plus $|X| + |H|$ étapes.
2. *Influence de l'ordre* : L'ordre dans lequel on retire les oreilles ou les sommets isolés n'influence pas le résultat final. Si un hypergraphe est réductible, n'importe quelle séquence de réductions valides mènera à l'hypergraphe vide.


== Construction de l'arbre de jointure
L'arbre de jointure se construit au cours de la réduction GYO :
1. Chaque atome de la requête devient un nœud de l'arbre.
2. Lorsqu'une arête $E$ est supprimée, car elle est incluse dans une arête $F$, on ajoute une arête entre les nœuds correspondant à $E$ et $F$ dans l'arbre.
3. Si plusieurs arêtes sont candidates pour $F$, n'importe laquelle convient pour maintenir la connexité des variables communes.

Cette structure garantit la propriété de connexité : pour toute variable $x$, l'ensemble des nœuds contenant $x$ forme un sous-graphe connexe (un arbre), ce qui est la condition nécessaire pour que les passes de semi-jointures propagent correctement les contraintes.


#include "rapport_code.typ";
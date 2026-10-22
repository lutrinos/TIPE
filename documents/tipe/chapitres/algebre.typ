#import "/customization/great-theorems-customized.typ": *
#import "/customization/graph.typ": *

= Algèbre relationnelle

Tout d'abord, quelques rappels sur l'algèbre relationnelle, qui est une formalisation mathématique des opérations réalisables sur une base de données.

== Relations, schémas et instances

Le schéma d'une base de données est un ensemble de relations  $R$, $S$, $T$. Les relations sont en quelques sorte les briques élémentaires des bases de données.

#definition(title: "Relation")[
	Une relation est un objet suivant un schéma de la forme
	$ "rel"("a1": "dom1", ..., "an" : "domn") $
	On appelle
	- $"rel"$ nom de la relation
	- $"a1", ..., "an"$ les noms des attributs
	- $"dom1", ..., "domn"$ les domaines des attributs
]

Par exemple, ce qui suit peut définir une relation
$ "commune"("code" : "entier", "département" : "entier", "nom" : "texte") $

On appelle arité d'une relation le nombre d'attributs ($n$ dans la définition ci-dessus). On remarque au passage qu'il y a deux manière de voir les couples $"attribut" times "domaine"$ : sous la forme d'un $n$-uplet où les valeurs sont numérotées, ou bien sous la forme d'un dictionnaire, où chaque attribut est accessible à partir de son nom.

On note $bold("dom")(A)$ le domaine de $A$.

#definition(title: "Instance")[
	Un _n-uplet_ sur une relation $R$ est une valeur possible d'un élément de la relation, de la forme $R(a_1, ..., a_n)$ (une occurence de $R$).

	Une instance $I$ sur la relation $R$ est un ensemble fini de n-uplets sur $R$, qu'on note $R^I$.

	Une instance $I$ sur le schéma d'une base de données est l'union des instances des relations $R$ du schéma.
]

Par exemple, si on prend les relations
$ "commune"("nom" : "texte", "département" : "entier") $
$ "département"("numéro" : "entier", "nom" : "texte", "région" : "texte") $
Alors un schéma de base de données $bold(R)$ possible est ${ "commune", "département" }$.

Une instance $I$ sur $bold(R)$ sera donc un ensemble de relations $"commune"$  ou $"département"$ :

$ I = {
	"commune"("Brest",  29),
	"commune"("Paris", 75), \
	"département"(29, "Finistère", "Bretagne"),
	"département"(75, "Paris", "Île-de-France") } $

On rappelle brièvement ce que sont une projection et une sélection.

#definition(title: "Projection")[
	Si $R$ est une relation et $H = (A_1, ..., A_n)$ des attributs de $R$, on appelle projection de $R$ sur $H$ et on note  $pi_H R$ la relaiton obtenue à partir de $R$ en ne gardant que les attributs $A_1, ..., A_n$ et en supprimant les doublons.
]

Quand on réalise une projection, on perd (temporairement) de l'information en enlevant des attributs de la relation, ce qui est parfois utile quand certaines informations ne nous intéressent pas.

#definition(title: "Sélection")[
	Soient $R$ une relation et $E$ une expression logique portant sur les attributs de $R$. On appelle sélection de $R$ selon $E$ (qu'on note $sigma_(E) R$) la relation obtenue à partir de $R$ en ne gardant que les n-uplets de $R$  satisfaisant l'expression logique $E$.
]

Dans la suite, on ne s'autorisera que des expressions logiques avec des égalités, l'algorithme décrit fonctionnant dans ce cadre précis.

==  Requêtes conjonctives

Les requêtes conjonctives permettent de formaliser la recherche de n-uplets vérifiant certaines relations sur un schéma de données $bold(R)$.

#definition(title: "Requête conjonctive")[
	On note les requêtes conjonctives sous la forme
	$ q(x_1, ..., x_n) :- R_1(arrow(y_1)),...,R_p (arrow(y_p)) $

	La première partie désigne $q(x_1, ..., x_n)$ l'en-tête de la requête, et la seconde $R_1(arrow(y_1)),...,R_p (arrow(y_p))$ est le corps cette même requête. On appelle $bold("var")(q)$ l'ensemble des variables de la requête, et chacune des expressions $R_i (arrow(y_i))$ est appelé clause atomique ou atome.
]

Cette expression doit toutefois vérifier quelques conditions :
- chaque n-uplet $arrow(y_i)$ doit avoir la même taille que l'arité de la relation correspondante (pour que ce soit bien définit)
- chaque variable de l'en-tête doit être présente dans un moins l'un des $arrow(y_i)$.

À première vue cette expression est rébarbative, mais elle est en fait assez logique (ouf !) :
- la notation $arrow(y_i)$ reprend l'idée qu'un élément sur une relation peut être vu comme un n-uplets, autrement dit comme un vecteur de la base de données.
- les variables $x_i$ constituant le vecteur $arrow(x)$ de l'en-tête représentent les champs qu'on va sélectionner. C'est la projection de la sélection opérée sur $bold(R)$ à partir du corps de la requête.
- le corps de la requête quant à lui permet de quantifier la requête effectuée sur l'instance $I$ de la base de données.

Reprenons l'instance $I$ définie ci-dessus comme exemple.

$ I = {
	"commune"("Brest",  29),
	"commune"("Paris", 75), \
	"département"(29, "Finistère", "Bretagne"),
	"département"(75, "Paris", "Île-de-France") } $

À partir des relations

$ "commune"("nom" : "texte", "département" : "entier") $
$ "département"("numéro" : "entier", "nom" : "texte", "région" : "texte") $

On considère la requête (conjonctive) suivante
$ q(x, y, z) :- "commune"(x, u), "département"(u, y, z) $

Cette requête paraît obscure, mais il ne faut pas oublier que ce sont des variables muettes ! On peut donc la réécrire sous la forme

$ q(c, d, r) :- "commune"(c, u), "département"(u, d, r)  $

Ou (ce qui est encore plus clair)

$ q("com", "dep", "reg") :- "commune"("com", "id"), "département"("id", "dep", "reg") $

On est en fait en train de récupérer les noms des villes de l'instance $I$, associés à leur nom de département et nom de région ! On vérifie d'ailleurs au passage que cette vérifie bien les criètères donnés précédemment :
- les n-uplets ont la bonne taille et  la bon typage
- chaque variable est présente dans au moins un des vecteurs donnés en entrée aux relations.

Il n'est pas trop difficile de trouver de tête le résultat de la requête, on introduit tout de même la notion de valuation pour expliciter la procédé par lequel on souhaite obtenir toutes les n-uplets vérifiant la requête.

#definition(title: "Valuation")[
	Une valuation $v$ sur un ensemble de variables $V$ est une application de $V$ dans le domaine $bold("dom")$ de $bold(R)$.
]

(Dans la pratique, il faudra que le typage soit correct, bien que cela ne pose pas problème du point de vue théorique#footnote[Je crois ?]).

Dans la continuité de l'exemple précédent, une valuation possible est
$ v(x) = cases("\"Brest\" si " x = "com", "\"Finistère\" si " x = "dep", "\"Bretagne\" si " x = "reg", 29 " si " x = "id") $

On étend la notation de  manière intuitive aux tuples :
$ v((x, y)) =  (v(x), v(y)) $
Et aux n-uplets de manière générale
$ v((x_1, ..., x_n)) = (v(x_1), ..., v(x_n)) $

On est alors en mesure de définir le résultat d'une  requête conjonctive sur une instance $I$ :
$ q(I) = { v(arrow(x)) | v " valuation sur " bold("var")(q) " vérifiant pour tout " i, v(arrow(y_i)) in  R_i^I } $

De manière générale, toutes les requêtes contenant des sélections avec égalité, des projections et des jointures sont des requêtes conjonctives : c'est donc un des concepts fondamentaux des recherches de résultats dans des bases de données !

Quelques définitions complémentaires, qui pourront s'avérer utiles.

#definition(title: "Monotonie")[
	Une requête $q$ est monotones si n'importe quelles instances $I subset.eq J$, $q(I) subset.eq q(J)$.
]

En bref, rajouter des n-uplets dans l'instance ne diminuera jamais le nombre de résultats renvoyés par la requête.

#proposition[
	Toute requête conjonctive est monotone.
]

#proof[
	Soit $t in q(I)$.

	Il existe alors une valuation $v$ et un n-uplet $x$ de $"val"(R)$ telle que $t = v(arrow(x))$ et pour tout $R_i$ relation du schéma, $v(arrow(y_i)) in R_i^I$.

	Comme $I subset.eq J$, $v(arrow(y_i)) in R_i^J$ et donc $t in q(J)$.
]

#proposition[
	Toute requête conjonctive est satisfiable.
]

#remark[
	Il est au passage intéressant de noter que :
	- savoir si une requête conjonctive est inclue dans un autre
	- savoir si deux requêtes conjonctives sont équivalentes
	- évaluer une requête conjonctive
	- simplifier une requête conjonctive
	#align(right)[...sont des problèmes NP-complets.#footnote[D'ailleurs, certains autre problèmes liés sont non décidables dans toutes les algèbres relationnelles, et le premier point, si on s'autorise des comparaison différentes de l'égalité ($>$ ou $!=$) sont bien plus que NP-complet (leur classe de complexité est $Pi_2^p$)]]
]

Ce qui justifie le fait de s'intéresser au cas particulier des requêtes acycliques !

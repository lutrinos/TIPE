#import "@preview/rubber-article:0.3.1": *

#show: article.with(
  lang:"fr",
  eq-numbering:none,
  text-size:10pt,
  page-numbering: "1",
  page-numbering-align: center,
  heading-numbering: "1.1",
)

#maketitle(
  title: "Réalisation d'un correcteur linguistique",
  authors: ("Nathan T.",),
  date: datetime.today().display("[day padding:none]. [month repr:long] [year]"),
)

#outline(
  depth: 2
)

#pagebreak()

= Introduction

Construire un correcteur syntaxique et grammatical flexible. On utilisera deux approches distinctes : une algorithmique et une basée sur un réseau de neurones.

== Définitions

Tout d'abord, il est nécessaire de définir ce que l'on souhaite réaliser, et cela passe partiellement par la définition précise de ce qu'on appelle syntaxe, grammaire et orthographe.

Nous utiliserons systématiquement comme source le CNRTL @cnrtl, ou  _Centre national de ressources textuelles et lexicales_ comme dictionnaire.

*La syntaxe*

Selon le CNRTL#footnote[https://www.cnrtl.fr/definition/syntaxe] , la syntaxe est la _partie de la grammaire traditionnelle qui étudie les relations entre les mots constituant une proposition ou une phrase, leurs combinaisons, et les règles qui président à ces relations, à ces combinaisons_.

== Objectifs et critères
Afin de mieux cerner les objectifs de ce TIPE et d'évaluer les différents modèles et solutions proposés, nous utiliserons différents critères, listés ci-dessous par ordre d'importance.


La *pertinence des corrections*. Il est hautement souhaitable de limiter autant que possible les corrections ou bien incorrectes ou redondantes. Il s'agit donc dans un premier temps de détecter le moins de de faux positifs possibles.

La *détection d'un maximum d'erreur*. Repérer hypothétiquement toutes les erreurs, et traiter le plus de cas différents pour avoir une couverture le plus général possible de la langue. Cet objectif ne doit en revanche en aucun cas contrevenir au premier critère et réduire la pertinence des corrections.


La *suggestion de reformulations*. Un phrase peut-être grammaticalement et syntaxiquement correcte quand bien-même elle est alambiquée, interminable voire incompréhensible. Ce critère s'appliquera exclusivement au modèle neuronal proposé.

#pagebreak()
= Approche algorithmique
Lorem.

#pagebreak()
= Utilisation d'un réseau de neurones
Ipsum.

#pagebreak()
= Conclusion

#pagebreak()
= Annexe
Quelques références intéressantes pour éclaircir ou approfondir certains points.
- La faute de l'orthographe @la-faute-de-l-orthographe

#pagebreak()
#bibliography("main.yml", title: "Bibliographie")
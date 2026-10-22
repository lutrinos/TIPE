#import "../customization/great-theorems-customized.typ": *
#set heading(numbering: none) // Heading numbering


= Annexe
#counter(heading).update(1)

//#set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

== Notes


*Rang*
On a noté $r(H)$ le rang d'un hypergraphe, mais on peut également définir le rang d'un hypergraphe de la manière suivante.

#definition(title: "Rang")[
  Dans un hypergraphe $H$, on appelle rang la fonction $r(S)$ qui fait correspondre àtout sous-ensemble $S$ de $X$ le nombre entier positif
  $ r(S) = max_i abs(S inter E_i) $
]

On a alors $r(X)$ qui correspond à la définition initiale du rang de l'hypergraphe.

== Autres thèmes
- Droite définie sur un hypergraphe
- Trou d'un hypergraphe (avec la parité / imparité)
- Famille de Sperner
- Graphe k-représentatif

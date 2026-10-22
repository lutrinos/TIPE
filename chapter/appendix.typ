#import "../customization/great-theorems-customized.typ": *
#set heading(numbering: none) // Heading numbering


= Annexe
#counter(heading).update(1)

//#set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

Essentiellement des notes, définitions et résultats moins importants, apportant une manière différente de voir les choses ou bien ne s'inscrivant pas au sein d'un chapitre bien défini. Ce n'est pas essentiel dans un premier temps, et les preuves sont donc sujettes à caution...

== Notes

On a noté $r(H)$ le rang d'un hypergraphe, mais on peut également définir le rang d'un hypergraphe de la manière suivante.

#definition(title: "Rang")[
  Dans un hypergraphe $H$, on appelle rang la fonction $r(S)$ qui fait correspondre àtout sous-ensemble $S$ de $X$ le nombre entier positif
  $ r(S) = max_i abs(S inter E_i) $
]

On a alors $r(X)$ qui correspond à la définition initiale du rang de l'hypergraphe, et une propriété portant sur l'invariance du rang de tout sous-hypergraphe considéré au sein de son hypergraphe "parent".

#proposition[
  Soit $H=(X, ee)$ un hypergraphe, et $H_A = (A, ee_A)$ un sous-hypergraphe engendré par un ensemble $A subset X$.
  $ forall S subset A, r_A (S) = r(S) $
]

#proof[
  Pour tout $i$, comme $S subset A$ et $E_i subset A$,
  $ abs(S inter E_i) = abs((S inter E_i) inter A) = abs(S inter (E_i inter A)) = r_A (S) $
  Ce qui donne l'égalité du maximum.
]

== Autres thèmes
- Droite définie sur un hypergraphe
- Trou d'un hypergraphe (avec la parité / imparité)
- Famille de Sperner
- Graphe k-représentatif

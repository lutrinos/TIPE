
= Tétra

== Chronologie

Présentation de quinze minutes : c'est très court. Il faudra donc s'en tenir à l'essentiel concernant les aspects théoriques. En revanche, bien mettre l'emphase sur les expérimentations avec les bases de données des communes, départements et régions !

Dans l'idéal, il faudra suivre cette chronologie:
- Introduction (2 minutes)
  - Graphe et acyclicité
  - Hypergraphes
  - Fil rouge : la base de données
- Aspect théorique (4 minutes)
  - Algèbre relationnelle
  - Requête conjonctive
  - Arbre de jointure
- Explication des algorithmes (4 minutes)
  - Réduction GYO
  - Algorithme de Yannakakis
- Résultats expérimentaux (3 minutes)
  - Implémentation finale
  - Implémentation naïve
  - Comparaison des performances
- Conclusion (2 minutes)

Le but va être de présenter l'implémentation de manière linéaire, en expliquant simultanément pourquoi ça fontionne, et comment je le fais fonctionner.

C'est _très_ court.


== Résultats expérimentaux
- comparer l'approche naïve (produits cartésiens et compagnie) avec celle de l'algorithme en fonction de la taille de la base de données et de certains paramètres
- l'exécuter sur les villes et départements de France

== Code en C

Prompt : "You are given some code in python, which is a basic database implementation, with the Yannakakis algorithm to perform requests on the database.
Create a replication of this code in C and stick as much as possible to the current code. Don't add any feature to the current code, and keep the same time complexity of the python data structures, such as set or list."

Modèle: Claude Haiku 4.5

== Conclusion
- insister sur le fait que c'est NP-difficile dans le cas général
- mettre les améliorations en perspective : existe-t-il des variantes plus efficaces dans certains cas particuliers différents ? Il y a-t-il des moyens d'utiliser cette approche pour des requêtes "presque" $alpha$-acyclique ?

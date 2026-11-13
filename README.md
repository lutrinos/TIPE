# Calcul de requêtes dans une base de données

Ce dépôt de code contient les différents documents que j'ai rédigé pour mon TIPE (session 2026) aux épreuves de l'ENS et des concours Mines-Ponts et Centrale, ainsi que le code que j'ai écrit à cette occasion.

Le but était d'étudier l'algorithme de Yannakakis qui permet de calculer des jointures (sous certaines conditions), dans l'optique de proposer une implémentation partielle de base de données, avec comme cas de figure les communes, départements et régions françaises.

Les fichiers sont disposés sans structure hiérarchique claire, puisqu'ils contiennent pour la plupart les même informations mais formulées et adaptées aux exigences des différentes épreuves (nombre de mots, nombre de pages, annexes éventuelles...), et ont été rédigés au fur et à mesure.

Les différents documents sont les suivants :
- le rapport pour l'épreuve de l'ENS : [pdf](/documents/tipe/rapport.pdf) et [source](/documents/tipe/rapport.typ). C'est le dernier document que j'ai rédigé, sans doute le plus complet.
- un document introduisant les objets et algorithmes que j'utilise, avec quelques intuitions sur leurs fonctionnements : [pdf](/documents/tipe/tipe.pdf) et [source](/documents/tipe/tipe.typ). Il était destiné à moi-même au départ (et pour le plaisir d'avoir une belle présentation en Typst aussi !), donc il n'est pas dans ce qu'on pourrait appeler une version finale, mais c'est sans doute celui le plus facile à lire.
- le rapport (nommé MCOT) pour l'épreuve du tétra-concours (Mines-Ponts et Centrale): [pdf](/documents/tipe/mcot.pdf) et [source](/documents/tipe/mcot.typ) (voir la [version officielle](/documents/tipe/mcot_officiel.pdf))
- la présentation utilisée lors des oraux : [pdf](/documents/tipe/presentation.pdf) et [source](/documents/tipe/presentation.md) ainsi que quelques [notes associées](/documents/tipe/notes.pdf), donc la source est [ici](/documents/tipe/notes.typ) (et la première version de la présentation, plus complète mais trop longue : [pdf](/documents/tipe/old-presentation.pdf) et [source](/documents/tipe/old-presentation.md))

Le code est situé dans le répertoire `/code` (quelle imagination !).

Les répertoires `/code/brouillon` et `/code/c-rewrite` contiennent du code généré par GPT-5 à partir de mon implémentation quelques jours avant les oraux, afin de tester si un port "direct" de mon code en C permettait d'améliorer les performances : ce sont les seuls endroits de ce dépôt de code avec du contenu généré par IA (et le seul moment où j'ai utilisé l'IA dans mon TIPE).

Le dossier `/code/data` contient les données géographiques françaises utilisées pour les exemples et les phases de test, téléchargé depuis [data.gouv.fr](https://www.data.gouv.fr/).

# Réalisation d'un correcteur linguistique

C'est le premier sujet que je souhaitais aborder pour mon TIPE, mais il me paraissait manquer de profondeur théorique.

Les documents et le code que j'ai implémenté sont situés dans le répertoire `/legacy`. Ce document ([pdf](/documents/legacy/docs/main.pdf), [source](/documents/legacy/docs/main.typ)) résume ce que j'ai réalisé sur ce sujet, durant les vacances entre les deux années de classe préparatoire.

Le but était d'étudier différentes approches de correction grammaticale et orthographique, en partant d'approches algorithmiques avant d'étudier d'autres moyens utilisant des réseaux de neurones.

Je me suis concentré sur la première approche seulement, en implémentant de manière efficace une trie (dans un fichier, sous un format conçu spécifiquement pour mon usage) de tous les mots listés dans le wiktionnaire à la date du 20 avril 2025. Grâce à la distance de Damerau-Levenshtein couplée à l'utilisation d'une telle trie, j'étais capable de vérifier tous les mots de _L'Avare_ de Molière en 0.3s (en Python).

Cela m'a également permis de réaliser quelques statistiques :
- ce dictionnaire contenait à cette date 1859114 mots
- il y a 2129931 noeuds avec un seul enfant dans la trie sur 4034131 noeuds (ce qui a donné lieu à quelques optimisations)
- les mots font en moyenne 11.4 caractères
- chaque noeud a en moyenne 2.2 enfants
- le mot le plus long fait 85 caractères, il s’agit du mot maori `Taumatawhakatangihangakoauauotama%
teaturipukakapikimaungahoronukupokaiwhenuakitanatahu`, qui signifie « Le sommet où Tamatea,
l’homme aux gros genoux, qui dévalait, avalait et grimpait des montagnes, le marcheur invétéré,
joua de sa flûte à un être cher » désignant une colline en Nouvelle-Zélande
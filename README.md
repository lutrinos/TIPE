# TIPE

# Documents
- [Document principal](./docs/main.pdf)
- [Avancées](./CHANGELOG.md)

# Annexe
- [La faute de l'orthographe](https://www.youtube.com/watch?v=5YO7Vg1ByA8)


## Protocole de stockage 
----------------------------------------------------------------------------------------------------------
    flag        |       n           |       offset      |       clés  (char | offset)
    1 octet     |       1 octet     |       4 octets    |       3*n octets
----------------------------------------------------------------------------------------------------------

Avec
- flag:
    - bit 0 : si ce mot existe
    - bit 1 : si 1 ou 2 bytes sont nécessaires pour stocker l'offset des  clés
- offset: offset de base des clés
- n: nombre de clés
- clés: clés du noeud


TODO:
- prononciation
- homophones
- type de mot (il y en a 103)
- mots dérivés / liés
- registre (familier, ...)
- genre (masculin, féminin)


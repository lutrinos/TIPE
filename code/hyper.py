from typing import List

class Arete:
    cardinal: int
    field: int
    indice: int

    """
    Arête d'un hypergraphe.
    - sommets : bitfield des éléments des sommets
    - cardinal : nombre d'éléments dans sommets
    """
    def __init__(self):
        self.cardinal = 0
        self.field = 0
        self.indice = -1
    
    @property
    def sommets(self):
        sommets = []
        field = self.field

        i = 0
        while field != 0:
            if field & 1 == 1:
                sommets.append(i)
            i += 1
            field >>= 1

        return sommets

    def copier(self):
        a = Arete()
        a.field = self.field
        a.cardinal = self.cardinal
        a.indice = self.indice
        return a

    def augmenter(self, *sommets: int):
        for s in sommets:
            if not self.contient(s):
                self.field |= 1 << s
                self.cardinal += 1

    def reduire(self, sommet: int):
        if self.contient(sommet):
            self.field &= ~(1 << sommet)
            self.cardinal -= 1
    
    def dans(self, a):
        return (self.field | a.field) == a.field

    def contient(self, sommet: int):
        return self.field & (1 << sommet) != 0

    def __repr__(self):
        return f"Arete(sommets={self.sommets}, indice={self.indice})"


class Hyper:
    aretes: List[Arete]
    ordre: int

    """
    Hypergraphe.
    - ordre : nombre de sommets (numérotés 0..ordre-1)
    - aretes : liste d'objets Arete
    """
    def __init__(self, ordre: int):
        self.ordre = int(ordre)
        self.aretes = []

    @property
    def nb_aretes(self):
        return len(self.aretes)
    
    def decompte(self, sommet: int):
        return sum((1 if a.contient(sommet) else 0) for a in self.aretes)

    def est_valide(self):
        """
        Vérifie que chaque arête a cardinal > 0 et que chaque sommet de 0..ordre-1
        apparaît dans au moins une arête.
        """
        if any(a.cardinal == 0 for a in self.aretes):
            return False

        couvert = 0
        for a in self.aretes:
            couvert |= a.field
        
        while couvert != 0:
            if couvert & 1 == 0:
                return False
            couvert = couvert >> 1

        return True
    
    def retirer_sommet(self, sommet: int):
        for a in self.aretes:
            a.reduire(sommet)

    def copier(self):
        h = Hyper(self.ordre)
        h.aretes = [a.copier() for a in self.aretes]
        return h

    def est_acyclique(self):
        h = self.copier()

        restant = set(range(h.ordre))
        sommets_compte = [h.decompte(s) for s in range(h.ordre)]

        retirer = []
        while True:
            sortir = True

            # On enlève tous les sommets dans moins d'une arête
            retirer.clear()
            for s in restant:
                if sommets_compte[s] <= 1:
                    retirer.append(s)
                    sortir = False
            for s in retirer:
                restant.discard(s)
                h.retirer_sommet(s)
            
            # On enlève toutes les arêtes inclues dans une autre
            for indice, a in enumerate(h.aretes):
                if a.cardinal > 0:
                    for b in h.aretes:
                        if a.dans(b) and a.indice != b.indice:
                            for s in a.sommets:
                                sommets_compte[s] -= 1
                            h.enlever_arete(indice)
                            sortir = False
                            break
            
            # On continue éventuellement l'algorithme
            if sortir or len(restant) == 0:
                break

        return len(restant) == 0
    
    # Renvoie l'arbre si la requête est acyclique, None sinon
    def arbre_jointure(self):
        arbre = [[] for _ in range(self.nb_aretes)]

        h = self.copier()

        restant = set(range(h.ordre))
        sommets_compte = [h.decompte(s) for s in range(h.ordre)]

        retirer = []
        while True:
            sortir = True

            # On enlève tous les sommets dans moins d'une arête
            retirer.clear()
            for s in restant:
                if sommets_compte[s] <= 1:
                    retirer.append(s)
                    sortir = False
            for s in retirer:
                restant.discard(s)
                h.retirer_sommet(s)
            
            # On enlève toutes les arêtes inclues dans une autre
            for indice, a in enumerate(h.aretes):
                if a.cardinal > 0:
                    for b in h.aretes:
                        if a.dans(b) and a.indice != b.indice:
                            arbre[a.indice].append(b.indice)
                            arbre[b.indice].append(a.indice)
                            for s in a.sommets:
                                sommets_compte[s] -= 1
                            h.enlever_arete(indice)
                            sortir = False
                            break
            
            # On continue éventuellement l'algorithme
            if sortir or len(restant) == 0:
                break

        return arbre if len(restant) == 0 else None

    def ajouter_arete(self, *aretes: Arete):
        for a in aretes:
            a.indice = len(self.aretes)
            self.aretes.append(a)

    def enlever_arete(self, indice: int):
        del self.aretes[indice]

    def __repr__(self):
        return f"Hyper(ordre={self.ordre}, nb_aretes={self.nb_aretes}, aretes={self.aretes})"
    

"""
h = Hyper(3)

vert = Arete()
rouge = Arete()
jaune = Arete()

vert.augmenter(0, 1)
rouge.augmenter(1, 2)
jaune.augmenter(2, 0)

h.ajouter_arete(vert, rouge, jaune)

print(h.est_acyclique())
print(h.arbre_jointure())
"""
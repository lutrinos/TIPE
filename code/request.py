from typing import List

class Atom:
    name: str                   # Nom de la table de l'atome
    index: int                  # Indice de l'atome
    vars: set[str]              # Variables présentes dans l'atome
    record: dict[str, str]      # Annuaire variable-colonne

    original: tuple[str]

    def __init__(self, name, *vars):
        self.name = name
        self.vars = set(vars)
        self.record = dict()
        self.original = vars

        self.vars.discard('_')

    def __repr__(self):
        return f"{self.name}({ ', '.join(str(v) for v in self.original) })"

class Head:
    name: str        # Nom de la tête pour faire joli    
    vars: tuple[str]  # Variables présentes dans la tête

    def __init__(self, name: str, *vars):
        self.name = name
        self.vars = vars
    
    def __repr__(self):
        return f"{self.name}({ ', '.join(str(v) for v in self.vars) })"

class Query:
    atoms: tuple[Atom]      # Atomes de la requête
    head: Head              # Tête de la requête

    vars: set[str]           # Variables présentes dans la requête

    def __init__(self, head: Head, *atoms):
        self.head = head
        self.atoms = atoms
        self.vars = set()

        for i, atom in enumerate(self.atoms):
            atom.index = i
            self.vars = self.vars.union(atom.vars)
    
    def __repr__(self):
        return f"{self.head} :- {', '.join(str(a) for a in self.atoms)}"
from typing import List

class Atom:
    name: str                   # Nom de la table de l'atome
    index: int                  # Indice de l'atome
    variables: set[str]         # Variables présentes dans l'atome

    original: tuple[str]

    def __init__(self, name, *variables):
        self.name = name
        self.variables = set(variables)
        self.record = { v:i for i, v in enumerate(variables) }
        self.original = variables

        self.variables.discard('_')

    def __repr__(self):
        return f"{self.name}({ ', '.join(str(v) for v in self.original) })"

class Head:
    name: str               # Nom de la tête pour faire joli    
    variables: tuple[str]   # Variables présentes dans la tête

    def __init__(self, name: str, *variables):
        self.name = name
        self.variables = variables
    
    def __repr__(self):
        return f"{self.name}({ ', '.join(str(v) for v in self.variables) })"

class Query:
    atoms: tuple[Atom]      # Atomes de la requête
    head: Head              # Tête de la requête

    variables: set[str]     # Variables présentes dans la requête

    def __init__(self, head: Head, *atoms):
        self.head = head
        self.atoms = atoms
        self.variables = set()

        for i, atom in enumerate(self.atoms):
            atom.index = i
            self.variables = self.variables.union(atom.variables)
    
    def __repr__(self):
        return f"{self.head} :- {', '.join(str(a) for a in self.atoms)}"
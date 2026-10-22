from csv import reader
from typing import Dict, List, Self, Set

class Table:
    name: str  # Nom de la table
    rows: List[tuple]  # Lignes

    columns: List[str]  # En-tête

    def __init__(self, name):
        self.name = name
        self.rows = []
        self.columns = []

    @property
    def len(self):
        return len(self.rows)

    # Mise à jour du nom de colonne
    def rename(self, index: int, nname: str):
        self.columns[index] = nname

    # Importation d'un fichier csv
    def import_from(self, path: str):
        self.rows = []

        with open(path, mode="r") as file:
            csv = reader(file)

            self.columns = csv.__next__()
            self.rows.extend([tuple(line) for line in csv])
    
    def export_to(self, path: str):
        print("TO DO")

    # Projection et sélection
    def project(self, selection: List[bool], validate):
        switch = []

        for i, b in enumerate(selection):
            if b:
                switch.append(i)

        dedup = set()
        for row in self.rows:
            if validate(row):
                dedup.add(tuple(row[i] for i in switch))

        self.columns = [self.columns[i] for i in switch]
        self.rows = list(dedup)

    def __repr__(self):
        return f"Table(labels={self.columns}, rows_count={len(self.rows)})"

    def print(self):
        print("Labels ", self.columns)
        print(" - " + "\n - ".join(str(r) for r in self.rows))


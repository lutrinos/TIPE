import time
from collections import defaultdict
from csv import reader
from typing import Dict, List, Self, Set

from table import Table
from hyper import Arete, Hyper
from request import Atom, Head, Query

class JoinNode:
    atom: Atom              # Atome du noeud
    table: Table            # Table correspondant à l'atome

    record: Dict[str, int]  # Annuaire de la table du noeud
    variables: Set[str]          # Variables pertinentes du noeud
    
    children: List[Self]    # Enfants dans l'arbre de jointure
    root: bool    # Parent dans l'arbre de jointure

    def __init__(self, atom: Atom, table: Table):
        self.atom = atom
        self.table = Table(table.name)

        self.record = dict()
        self.variables = set()

        self.children = []
        self.root = False

        self.table.columns = table.columns.copy()
        self.table.rows = table.rows

        for i, v in enumerate(atom.original):
            if v != '_':
                self.variables.add(v)
                self.record[v] = i
                self.table.columns[i] = v
            else:
                self.table.columns[i] = '_'

    # Pour ajouter un enfant
    def push_child(self, child: Self):
        self.children.append(child)
    
    # Semi-jointure
    def semi_join(self, node: Self):
        intersection = list(self.variables.intersection(node.variables))
        
        index = set([
            tuple(row[node.record[v]] for v in intersection) for row in node.table.rows
        ])

        self.table.project(
            [v in self.variables for v in self.table.columns],
            lambda row: tuple(row[self.record[v]] for v in intersection) in index
        )

        # Mise à jour des colonnes
        for i, v in enumerate(self.table.columns):
            self.record[v] = i
    
    def patch_rows(self, row_a, row_b, selection: list[tuple[bool, int]]):
        return tuple(row_a[i] if a else row_b[i] for a, i in selection)
    
    # Jointure complète
    def full_join(self, node: Self, head: Head, strict):
        intersection = list(self.variables.intersection(node.variables))
        index  = defaultdict(list)

        # Construction de la sélection
        selection = []
        columns = []
        for v in head.variables if strict else self.variables.union(node.variables):
            if v in self.variables or v in node.variables:
                current = v in self.variables
                columns.append(v)
                selection.append(
                    (current, self.record[v] if current else node.record[v])
                )
            else:
                raise InterruptedError(v + " non présent lors de la jointure.")

        # Construction du résultat
        for row in node.table.rows:
            key = tuple(row[node.record[v]] for v in intersection)
            index[key].append(row)
        
        result = []
        for row in self.table.rows:
            key = tuple(row[self.record[v]] for v in intersection)

            if key in index:
                for row2 in index[key]:
                    result.append(self.patch_rows(row, row2, selection))
        
        self.table.rows = result
        self.table.columns = columns
        self.record = { v:i for i, v in enumerate(columns) }
        self.variables = set(head.variables) if strict else self.variables.union(node.variables)

    
    def compute(self, head: Head):
        for index, child in enumerate(self.children):
            child.compute(head)
            self.full_join(child, head, self.root and index == len(self.children) - 1)


class Instance:
    tables: dict[str, Table]  # Annuaire nom-table

    def __init__(self):
        self.tables = dict()

    def add_table(self, table: Table):
        self.tables[table.name] = table

    # Crée l'arbre de jointure d'une requête
    def join_dfs(self, tree, query: Query, seen, i):
        seen.add(i)
        jointure = JoinNode(query.atoms[i], self.tables[query.atoms[i].name])

        for j in tree[i]:
            if j not in seen:
                jointure.push_child(self.join_dfs(tree, query, seen, j))

        return jointure

    def jointure(self, query: Query):
        hyper = Hyper(len(query.variables))

        record = dict()
        #record_bis = dict()

        for i, v in enumerate(query.variables):
            record[v] = i
            #record_bis[i] = v

        for atom in query.atoms:
            arete = Arete()
            arete.augmenter(*[record[v] for v in atom.variables])
            hyper.ajouter_arete(arete)

        arbre = hyper.arbre_jointure()

        if not arbre:
            raise InterruptedError("Requête non cyclique.")

        #arbre_bis = dict()

        #for i, adj in enumerate(arbre):
        #    arbre_bis[record_bis[i]] = [record_bis[j] for j in adj]

        vus = set()
        return self.join_dfs(arbre, query, vus, 0)

    # Passage bottom -> up
    def bottom_up(self, query: Query, node: JoinNode):
        for child in node.children:
            self.bottom_up(query, child)

            variables = node.variables.intersection(child.variables)
            if len(variables) > 0:
                child.semi_join(node)

    # Passage top -> down
    def top_down(self, query: Query, node: JoinNode):
        for child in node.children:
            variables = node.variables.intersection(child.variables)

            if len(variables) > 0:
                node.semi_join(child)
            self.top_down(query, child)

    # Réalisation d'une requête
    def query(self, query: Query):
        # Vérification de la requête
        for atom in query.atoms:
            if atom.name not in self.tables:
                raise InterruptedError(atom.name + " non présent dans les tables.")
            if len(atom.original) != len(self.tables[atom.name].columns):
                raise InterruptedError(
                    "Nombre de colonnes non correspondant dans la table " + atom.name
                )

        # Création de l'arbre de jointure
        jointree = self.jointure(query)
        jointree.root = True

        # Premier passage
        self.bottom_up(query, jointree)

        # Deuxième passage
        # Suit directement l'algorithme de Yannakakis, mais il est possible de sauter cette étape
        self.top_down(query, jointree)

        # On réalise la jointure
        jointree.compute(query.head)

        return jointree.table


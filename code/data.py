from request import Query, Atom, Head
from hyper import Hyper, Arete
from typing import List, Self
from csv import reader
from collections import namedtuple, defaultdict
import time

class Table:
    name: str           # Nom de la table
    labels: list[str]   # En-tête
    rows: list          # Lignes
    id: int             # Identifiant

    def __init__(self, name):
        self.name = name
        self.rows = []
        self.labels = []
    
    @property
    def len(self):
        return len(self.rows)
    
    def import_file(self, path):
        self.rows = []

        with open(path, mode='r') as file:
            csv = reader(file)

            self.labels = csv.__next__()

            for line in csv:
                self.rows.append(tuple(line))
    
    # labels: [True si réutilisé sinon False]
    def project(self, selection: list[bool], validate, mutate=False):
        switch = []

        for i, b in enumerate(selection):
            if b:
                switch.append(i)

        dedup = set()
        for row in self.rows:
            if validate(row):
                dedup.add(tuple(row[i] for i in switch))
        
        if mutate:
            self.labels = [self.labels[i] for i in switch]
            self.rows = list(dedup)
            return self
        else:
            t = Table(self.name)
            t.labels = [self.labels[i] for i in switch]
            t.rows = list(dedup)
            return t
    
    def __repr__(self):
        return f"Table(labels={self.labels}, rows_count={len(self.rows)})"

    def print(self):
        print("Labels ", self.labels)
        print(' - ' + '\n - '.join(str(r) for r in self.rows))

class JoinNode:
    atom: Atom                    # Atome du noeud
    table: Table                    # Table correspondant à l'atome
    children: List[Self]             # type: ignore # Enfants dans l'arbre de jointure
    parent: Self or None           # type: ignore # Parent dans l'arbre de jointure

    def __init__(self, atom, table):
        self.atom = atom
        self.table = table
        self.children = []
        self.parent = None
    
    def ajouter(self, child: Self): # type: ignore
        child.parent = self
        self.children.append(child)

class Instance:
    tables: dict[str, Table]    # Annuaire nom-table

    def __init__(self):
        self.tables = dict()

    def add_table(self, table: Table):
        self.tables[table.name] = table
    
    def join_dfs(self, tree, query: Query, seen, i):
        seen.add(i)
        jointure = JoinNode(
            query.atoms[i],
            self.tables[query.atoms[i].name]
        )

        for j in tree[i]:
            if j not in seen:
                jointure.ajouter(self.join_dfs(tree, query, seen, j))
        
        return jointure
    
    def jointure(self, query: Query):
        hyper = Hyper(len(query.vars))

        record = dict()
        record_bis = dict()

        for i, v in enumerate(query.vars):
            record[v] = i
            record_bis[i] = v

        for atom in query.atoms:
            arete = Arete()
            arete.augmenter(*[record[v] for v in atom.vars])
            hyper.ajouter_arete(arete)
        
        arbre = hyper.arbre_jointure()

        if not arbre:
            raise InterruptedError("Requête non cyclique.")
        
        arbre_bis = dict()

        for i, adj in enumerate(arbre):
            arbre_bis[record_bis[i]] = [record_bis[j] for j in adj]
        
        vus = set()
        return self.join_dfs(arbre, query, vus, 0)

    def semi_join(self, node_a: JoinNode, node_b: JoinNode, vars: set[str]):
        values = set()
        ordered_vars = list(vars)

        for row in node_b.table.rows:
            values.add(tuple(row[node_b.atom.record[v]] for v in ordered_vars))
        
        
        node_a.table = node_a.table.project(
            [v in node_a.atom.vars for v in node_a.atom.original],
            lambda row: tuple(row[node_a.atom.record[v]] for v in ordered_vars) in values
        )

        arr = []
        for v in node_a.atom.original:
            if v != '_':
                node_a.atom.record[v] = len(arr)
                arr.append(v)
        node_a.atom.original = tuple(arr)
        node_a.atom.vars = set(v for v in arr)

    
    def bottom_up(self, query: Query, node: JoinNode):
        for child in node.children:
            self.bottom_up(query, child)

            vars = node.atom.vars.intersection(child.atom.vars)
            if len(vars) > 0:
                self.semi_join(child, node, vars)
    
    def top_down(self, query: Query, node: JoinNode):
        for child in node.children:
            vars = node.atom.vars.intersection(child.atom.vars)

            if len(vars) > 0:
                self.semi_join(node, child, vars)
            self.top_down(query, child)
    
    def patch_rows(self, row_a, row_b, selection: list[tuple[bool, int]]):
        return tuple(row_a[i] if a else row_b[i] for a, i in selection)

    def full_join(self, head: Head, res: List, res_child: List, node: JoinNode, child: JoinNode, strict=False):
        vars = list(node.atom.vars.intersection(child.atom.vars))
        index = defaultdict(list)

        selection = []
        original = []
        
        for v in (head.vars if strict else node.atom.vars.union(child.atom.vars)):
            if v in node.atom.vars or v in child.atom.vars:
                a = v in node.atom.vars
                original.append(v)
                selection.append(
                    (a, node.atom.record[v] if a else child.atom.record[v])
                )
            else:
                raise InterruptedError(v + " non présent lors de la jointure.")
        
        for row in res:
            key = tuple(row[node.atom.record[v]] for v in vars)
            index[key].append(row)
        
        result = []
        for row_child in res_child:
            key = tuple(row_child[child.atom.record[v]] for v in vars)

            if key in index:
                for row in index[key]:
                    result.append(self.patch_rows(row, row_child, selection))

        node.atom.vars = node.atom.vars.union(child.atom.vars)
        node.atom.original = tuple(original)
        node.atom.record = { v:i for i, v in enumerate(original) }

        return result
    

    def compute(self, head: Head, node: JoinNode, strict=False):
        result = node.table.rows

        for i, child in enumerate(node.children):
            child_result = self.compute(head, child)
            if len(child_result) > 0:
                result = self.full_join(head, result, child_result, node, child, strict and i == len(node.children) - 1)
        return result
    
    def query(self, query: Query):

        # Vérification et simplification de la requête
        for atom in query.atoms:
            if atom.name not in self.tables:
                raise InterruptedError(atom.name + " non présent dans les tables.")
            if len(atom.original) != len(self.tables[atom.name].labels):
                raise InterruptedError("Nombre de colonnes non correspondant dans la table " + atom.name)

        # Création de l'arbre de jointure
        jointree = self.jointure(query)

        # Premier passage
        self.bottom_up(query, jointree)

        # Deuxième passage
        self.top_down(query, jointree)

        # On fait le join
        return self.compute(query.head, jointree, strict=True)


"""
t = Table()
t.import_file("code/data/v_commune_2025.csv")
r = t.project([2, 3, 9], [None, None, lambda x: len(x) <= 2])
#r.print()
print(r)
print(t)
"""

i = Instance()

# "TYPECOM","COMMUNE","REGION","DEPARTEMENT","CTCD","ARRONDISEMENT","TNCC","NCC","NCCENR","LIBELLE","CAN","COMPARENT"
communes = Table("commune")
communes.import_file("code/data/v_commune_2025.csv")

# "DEP","REG","CHEFLIEU","TNCC","NCC","NCCENR","LIBELLE"
departements = Table("département")
departements.import_file("code/data/v_departement_2025.csv")

# "REG","CHEFLIEU","TNCC","NCC","NCCENR","LIBELLE"
regions = Table("région")
regions.import_file("code/data/v_region_2025.csv")

i.add_table(communes)
i.add_table(departements)
i.add_table(regions)

nom_com = "nom_com"
nom_dep = "nom_dep"
nom_reg = "nom_reg"
num_dep = "num_dep"
num_reg = "num_reg"

_ = '_'

r = Query(
    Head("requête", nom_com, nom_dep, nom_reg),
    Atom("commune", _, _, num_reg, num_dep, _, _, _, _, _, nom_com, _, _),
    Atom("département", num_dep, _, _, _, _, _, nom_dep),
    Atom("région", num_reg, _, _, _, _, nom_reg)
)

start = time.time()
res = i.query(r)
end = time.time()

print(f"{end - start:.4f} secondes")
print(res)
from request import Query, Atom, Head
from hyper import Hyper, Arete
from typing import List, Self
from csv import reader
from collections import namedtuple, defaultdict
import time

class Table:
    name: str           # Nom de la table
    labels: set         # En-tête
    rows: List          # Lignes
    id: int             # Identifiant

    original: list[str]

    def __init__(self, name):
        self.name = name
        self.rows = []
        self.labels = set()
        self.Tuple = namedtuple(name, [])
    
    @property
    def len(self):
        return len(self.rows)
    
    def import_file(self, path):
        self.rows = []

        with open(path, mode='r') as file:
            csv = reader(file)

            self.original = csv.__next__()
            self.labels = set(self.original)
            self.Tuple = namedtuple(self.name, self.original)

            for line in csv:
                self.rows.append(self.Tuple(*line))
    
    # labels: [("from", "to")]
    def project(self, labels: list[tuple[str, str]], validate, mutate=False):
        old_labels = [old for old, _ in labels]
        new_labels = [new for _, new in labels]

        self.Tuple = namedtuple(self.name, new_labels)

        dedup = set()
        for row in self.rows:
            if validate(row):
                dedup.add(self.Tuple(*[row.__getattribute__(i) for i in old_labels]))
        
        if mutate:
            self.labels = set(new_labels)
            self.rows = list(dedup)
            return self
        else:
            t = Table(self.name)
            t.labels = set(new_labels)
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

    def semi_join(self, query: Query, node_a: JoinNode, node_b: JoinNode, vars: set[str], update_labels=False):
        values = set()
        ordered_vars = list(vars)

        for row in node_b.table.rows:
            values.add(tuple(row.__getattribute__(v) for v in ordered_vars))
        
        if update_labels:
            node_a.table = node_a.table.project(
                [(node_a.atom.record[v], v) for v in vars.union(query.head.vars).intersection(node_a.atom.vars)],
                lambda row: tuple(row.__getattribute__(node_a.atom.record[v]) for v in ordered_vars) in values
            )
        else:
            node_a.table = node_a.table.project(
                [(v, v) for v in vars.union(query.head.vars).intersection(node_a.atom.vars)],
                lambda row: tuple(row.__getattribute__(v) for v in ordered_vars) in values
            )

    
    def bottom_up(self, query: Query, node: JoinNode, root=False):
        if root:
            node.table = node.table.project(
                [(node.atom.record[v], v) for v in node.atom.vars],
                lambda _: True
            )
        for child in node.children:
            self.bottom_up(query, child)

            vars = node.atom.vars.intersection(child.atom.vars)
            if len(vars) > 0:
                self.semi_join(query, child, node, vars, True)
    
    def top_down(self, query: Query, node: JoinNode):
        for child in node.children:
            vars = node.atom.vars.intersection(child.atom.vars)

            if len(vars) > 0:
                self.semi_join(query, node, child, vars)
            self.top_down(query, child)
    
    def full_join(self, res_a: List, res_b: List, var_a: set[str], var_b: set[str], Tuple):
        vars = list(var_a.intersection(var_b))
        index = defaultdict(list)
        
        for row in res_a:
            key = tuple(row.__getattribute__(v) for v in vars)
            index[key].append(row)
        
        result = []
        for row in res_b:
            key = tuple(row.__getattribute__(v) for v in vars)

            if key in index:
                for row2 in index[key]:
                    t = Tuple()
                    # for f in Tuple._fields:
                    #     if row.__hasattr__():
                    #         break
                    #     t.__setattr__(f, row.__getattribute__(f) or row2.__getattribute__(f))
                    # for v a.append(row2.__getattribute__())
                    # data = list(row)
                    # data.extend(list(row2))
                    # result.append(Tuple(*[row.__getattribute__(v) if v in var_b else row2.__getattribute__(v) for v in Tuple._fields]))

        return result

    def compute(self, node: JoinNode, Tuple: type[tuple]):
        result = node.table.rows

        for child in node.children:
            child_result = self.compute(child, Tuple)
            #vars = node.atom.vars.intersection(child.atom.vars)
            result = self.full_join(result, child_result, node.atom.vars, child.atom.vars, Tuple)
        
        return result
    
    def query(self, query: Query):

        # Vérification et simplification de la requête
        for atom in query.atoms:
            if atom.name not in self.tables:
                raise InterruptedError(atom.name + " non présent dans les tables.")
            if len(atom.original) != len(self.tables[atom.name].labels):
                raise InterruptedError("Nombre de colonnes non correspondant dans la table " + atom.name)
            
            for i, v in enumerate(atom.original):
                if v != '_':
                    atom.record[v] = self.tables[atom.name].original[i]

        # Création de l'arbre de jointure
        jointree = self.jointure(query)

        # Création du type réponse
        Tuple = namedtuple(query.head.name, query.head.vars, defaults=(None,) * len(query.head.vars))

        # Premier passage
        self.bottom_up(query, jointree, True)

        # Deuxième passage
        self.top_down(query, jointree)

        # On fait le join
        return self.compute(jointree, Tuple)


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
    Atom("région", _, _, _, _, _, nom_reg)
)

start = time.time()
res = i.query(r)
end = time.time()

print(f"{end - start:.4f} secondes")
print(res)
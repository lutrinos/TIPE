from main import Instance, Table, Query, Head, Atom
import time

i = Instance()

# "TYPECOM","COMMUNE","REGION","DEPARTEMENT","CTCD","ARRONDISEMENT","TNCC","NCC","NCCENR","LIBELLE","CAN","COMPARENT"
communes = Table("commune")
communes.import_from("code/data/v_commune_2025.csv")

# "DEP","REG","CHEFLIEU","TNCC","NCC","NCCENR","LIBELLE"
departements = Table("département")
departements.import_from("code/data/v_departement_2025.csv")

# "REG","CHEFLIEU","TNCC","NCC","NCCENR","LIBELLE"
regions = Table("région")
regions.import_from("code/data/v_region_2025.csv")

i.add_table(communes)
i.add_table(departements)
i.add_table(regions)

nom_com = "nom_com"

nom_dep = "nom_dep"
num_dep = "num_dep"

nom_cheflieu = "nom_chef"
num_cheflieu = "num_chef"


_ = "_"

r = Query(
    Head("requête", nom_com, nom_cheflieu),
    Atom("commune", _, _, _, num_dep, _, _, _, _, _, nom_com, _, _),
    Atom("département", num_dep, _, num_cheflieu, _, _, _, nom_dep),
    Atom("commune", _, num_cheflieu, _, _, _, _, _, _, _, nom_cheflieu, _, _)
)

"""
n = 1
start = time.time()
for _ in range(n):
    i.query(r)
end = time.time()
print(f"Temps moyen : {(end-start)/n :.4f}")
"""

start = time.time()
res = i.query(r)
end = time.time()
res.print()
print(f"{end - start:.4f} secondes")

from main import Instance, Table, Query, Head, Atom
import time
from random import randint
from math import floor, ceil, inf, pow, sqrt

import numpy as np
import matplotlib.pyplot as plt

i = Instance()

a = Table("a")
b = Table("b")
c = Table("c")
d = Table("d")

a.import_from("code/join_benchmark.csv")
b.import_from("code/join_benchmark.csv")
c.import_from("code/join_benchmark.csv")
d.import_from("code/join_benchmark.csv")

i.add_table(a)
i.add_table(b)
i.add_table(c)
i.add_table(d)

_ = "_"
v1 = "v1"
v2 = "v2"
v3 = "v3"

# Requêtes
r1 = Query(
    Head("r1", v1),
    Atom("a", v1, _, _),
    Atom("b", v1, _, _)
)

r2 = Query(
    Head("r1", v1, v2),
    Atom("a", v1, _, _),
    Atom("b", v1, v2, _),
    Atom("c", _, v2, _)
)

r3 = Query(
    Head("r1", v1, v2, v3),
    Atom("a", v1, _, _),
    Atom("b", v1, v2, _),
    Atom("c", v3, v2, _),
    Atom("d", v3, _, _)
)

density = 0.8 # Pour x1, x2 : pour chaque valeur, pourcentage moyen d'éléments ayant la même valeur
boundaries = list(range(100000, 1000000, 50000)) # Bornes supérieures de la base de données

def fill_up_to(n: int):
    start = len(a.rows)

    # génération avec borne par densité
    gd = lambda: randint(floor(start / density), floor(n / density) - 1)

    # génération avec borne fixée
    gf = lambda: randint(1, ceil(boundaries[-1] / 10))

    while len(a.rows) < n:
        a.rows.append((gd(), gd(), gf()))
        b.rows.append((gd(), gd(), gf()))
        c.rows.append((gd(), gd(), gf()))
        d.rows.append((gd(), gd(), gf()))

def stats(q: Query):
    duration = 0
    size = 0
    values = []

    n = 3

    for _ in range(n):
        start = time.time()
        size = len(i.query(q).rows)
        end = time.time()

        values.append(end - start)
        duration += (end - start) / n
    
    # racine de l'erreur quadratique moyenne (incertitude type)
    return (size, duration, sqrt(sum(pow(x-duration, 2) for x in values) / n))

# Obtention des valeurs
s1 = []
s2 = []
s3 = []

for boundary in boundaries:
    fill_up_to(boundary)

    print(f"- Stats for {boundary}")
    s1.append(stats(r1))
    s2.append(stats(r2))
    s3.append(stats(r3))

# Tracé
fig, ax = plt.subplots()

def getx(a):
    return [i[0] for i in a]

def gety(a):
    return [i[1] for i in a]

def geterror(a):
    return [i[2] for i in a]

def scatter(s, c, n):
    x = getx(s)
    y = gety(s)

    #b, a = np.polyfit(x, y, deg=1)

    ax.scatter(x, y, c=c, marker="+", label=f"{n} join")
    #ax.plot(x, [a+b*v for v in x], c=c)
    ax.errorbar(x, y, yerr=geterror(s), c=c)

scatter(s1, "red", 1)
scatter(s2, "blue", 2)
scatter(s3, "green", 3)

ax.set_xlabel("Taille de la base de données")
ax.set_ylabel("Temps de calcul (s)")

plt.grid()
plt.legend(loc="upper right")
plt.show()
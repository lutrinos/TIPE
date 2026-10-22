from main import Instance, Table, Query, Head, Atom
import time
import random

import sqlite3
import matplotlib.pyplot as plt

i = Instance()

reference = Table("reference")
jointure = Table("jointure")

i.add_table(reference)
i.add_table(jointure)

reference.import_from("code/test_1.csv")
jointure.import_from("code/test_1.csv")

un = "a"
deux = "b"

_ = "_"

r0 = Query(
    Head("q", un),
    Atom("reference", un, _),
    Atom("jointure", un, _)
)

r1 = Query(
    Head("q", deux),
    Atom("reference", _, deux),
    Atom("jointure", _, deux)
)

r2 = Query(
    Head("q", un, deux),
    Atom("reference", un, deux),
    Atom("jointure", un, deux)
)

def random_data(index: int):
    return (random.randint(0, 500_000), random.randint(0, index))

def process_single(q: Query):
    start = time.time()
    res = i.query(q)
    end = time.time()

    return (end - start, len(res.rows))


def process(q: Query):
    data = []

    for _ in range(12):
        start = time.time()
        i.query(q)
        end = time.time()
        data.append(end - start)
    
    maximum = max(data)
    minimum = min(data)

    data.remove(maximum)
    data.remove(minimum)

    return data


steps = list(range(100_000, 1_000_000, 10_000))

# plt.style.use('_mpl-gallery-nogrid')

x = []
y = []
colors = []

db  = sqlite3.connect(":memory:")
c = db.cursor()

c.execute("CREATE TABLE reference (un INT, deux INT)")
c.execute("CREATE TABLE jointure (un INT, deux INT)")


def process_single_sql(q: str):
    start = time.time()
    res = c.execute(q).fetchall()
    end = time.time()

    return (end - start, len(res))

length = 0
for step in steps:

    print("Step :", step)

    while length < step:
        a, b = random_data(length)
        p, q = random_data(length)

        c.execute(f"INSERT INTO reference VALUES({a}, {b})")
        c.execute(f"INSERT INTO jointure VALUES({p}, {q})")

        reference.rows.append((a, b))
        jointure.rows.append((a, b))
        length += 1
    
    #t0, n0 = process_single(r0)
    #t1, n1 = process_single(r1)
    #t2, n2 = process_single(r2)

    t0, n0 = process_single_sql("SELECT reference.un, reference.deux FROM reference JOIN jointure ON reference.un = jointure.un")
    t1, n1 = process_single_sql("SELECT reference.un, reference.deux FROM reference JOIN jointure ON reference.deux = jointure.deux")
    t2, n2 = process_single_sql("SELECT reference.un, reference.deux FROM reference INNER JOIN jointure ON reference.un = jointure.un AND reference.deux = jointure.deux")

    #t0, n0 = process_single(r0)
    #t1, n1 = process_single_sql("SELECT reference.un FROM reference JOIN jointure ON reference.un = jointure.un")

    #print(n0, n1)
    #print(length, reference.len, c.execute("SELECT COUNT(*) FROM reference").fetchall()[0])

    x.extend([
        2*length + 0.5*n0,
        2*length + 0.5*n1,
        2*length + 0.5*n2
    ])

    y.extend([
        t0,
        t1,
        t2
    ])

    colors.extend([
        'blue',
        'red',
        'green'
    ])

c.close()

plt.scatter(x, y, c=colors, marker='+')
plt.show()
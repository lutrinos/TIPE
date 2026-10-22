from main import Instance, Table, Query, Head, Atom
import time
import random

import matplotlib.pyplot as plt

i = Instance()

reference = Table("reference")
jointure = Table("jointure")

i.add_table(reference)
i.add_table(jointure)

reference.import_from("code/test_1.csv")
jointure.import_from("code/test_1.csv")

results = [
    [],
    [],
    []
]

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
    return (random.randint(0, 10_000), random.randint(0, index))

def process_single(q: Query):
    start = time.time()
    res = i.query(q)
    end = time.time()

    return (end - start, res.len)

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
"""
steps = [
    10_000,
    20_000,
    30_000,
    40_000,
    50_000,
    60_000,
    70_000,
    80_000,
    90_000,
    100_000,
]"""

steps = list(range(10, 100_000, 100))

plt.style.use('_mpl-gallery-nogrid')
x = []
y = []

for step in steps:

    print("Step :", step)

    while reference.len < step:
        reference.rows.append(random_data(reference.len))
        jointure.rows.append(random_data(jointure.len))
    
    t0, n0 = process_single(r0)
    t1, n1 = process_single(r1)
    t2, n2 = process_single(r2)

    results[0].append(data0)
    results[1].append(data1)
    results[2].append(data2)

print(results)
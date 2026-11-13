from main import Instance, Table, Query, Head, Atom
from yannakakis import YannakakisDB, QueryTimings
import time
import random
import ctypes
from pathlib import Path

import matplotlib.pyplot as plt

# Python implementation instance
i = Instance()

# C implementation instance (if library exists)
try:
    c_lib_path = Path(__file__).parent / "libyannakakis.so"
    if c_lib_path.exists():
        c_lib = ctypes.CDLL(str(c_lib_path))
        c_available = True
        print("✓ C implementation available")
    else:
        c_available = False
        print("✗ C implementation not found")
except:
    c_available = False
    print("✗ Could not load C implementation")

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
    return (random.randint(0, 50_000), random.randint(0, index))

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

def process_c(query_str: str, db: YannakakisDB):
    """Process query using C implementation"""
    if not c_available:
        return None

    data = []

    for _ in range(12):
        _, _, timings = db.query_with_timings(query_str)
        data.append(timings.total_time / 1000)  # Convert ms to seconds

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

steps = list(range(10_000, 100_000, 10_000))

# Initialize C implementation if available
c_db = None
if c_available:
    c_db = YannakakisDB()
    print("Initializing C database...")

# Data storage for both implementations
x_python = []
y_python = []
colors_python = []

x_c = []
y_c = []
colors_c = []

# Statistics storage
stats_python = {'q0': [], 'q1': [], 'q2': []}
stats_c = {'q0': [], 'q1': [], 'q2': []}

for step in steps:

    print(f"Step: {step}", end="")

    while reference.len < step:
        reference.rows.append(random_data(reference.len))
        jointure.rows.append(random_data(jointure.len))

    # Update C database if available
    if c_available:
        c_db.add_table("reference", ["a", "b"], reference.rows)
        c_db.add_table("jointure", ["a", "b"], jointure.rows)

    # Python implementation
    t0, n0 = process_single(r0)
    t1, n1 = process_single(r1)
    t2, n2 = process_single(r2)

    x_python.extend([
        reference.len + jointure.len + n0,
        reference.len + jointure.len + n1,
        reference.len + jointure.len + n2
    ])

    y_python.extend([t0, t1, t2])
    colors_python.extend(['blue', 'red', 'green'])

    # Store Python stats
    stats_python['q0'].append(t0)
    stats_python['q1'].append(t1)
    stats_python['q2'].append(t2)

    # C implementation
    if c_available:
        c_q0_times = process_c("q(a) :- reference(a, _), jointure(a, _)", c_db)
        c_q1_times = process_c("q(b) :- reference(_, b), jointure(_, b)", c_db)
        c_q2_times = process_c("q(a, b) :- reference(a, b), jointure(a, b)", c_db)

        if c_q0_times and c_q1_times and c_q2_times:
            c_t0 = sum(c_q0_times) / len(c_q0_times)
            c_t1 = sum(c_q1_times) / len(c_q1_times)
            c_t2 = sum(c_q2_times) / len(c_q2_times)

            x_c.extend([
                reference.len + jointure.len + n0,
                reference.len + jointure.len + n1,
                reference.len + jointure.len + n2
            ])

            y_c.extend([c_t0, c_t1, c_t2])
            colors_c.extend(['blue', 'red', 'green'])

            # Store C stats
            stats_c['q0'].append(c_t0)
            stats_c['q1'].append(c_t1)
            stats_c['q2'].append(c_t2)

            print(" ✓")
        else:
            print(" (C unavailable)")
    else:
        print()


# Create comparison plots
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Yannakakis: Python vs C', fontsize=16, fontweight='bold')

# Plot 1: Python scatter plot
ax = axes[0, 0]
ax.scatter(x_python, y_python, c=colors_python, marker='+', s=100, alpha=0.6, label='Python')
ax.set_xlabel('Taille totale (données + résultat)')
ax.set_ylabel('Temps (secondes)')
ax.set_title('Python')
ax.grid(True, alpha=0.3)
ax.legend()

# Plot 2: C scatter plot (if available)
ax = axes[0, 1]
if c_available and x_c:
    ax.scatter(x_c, y_c, c=colors_c, marker='x', s=100, alpha=0.6, label='C')
    ax.set_xlabel('Taille totale (données + résultat)')
    ax.set_ylabel('Temps (secondes)')
    ax.set_title('C')
    ax.grid(True, alpha=0.3)
    ax.legend()
else:
    ax.text(0.5, 0.5, 'C Implementation Not Available', ha='center', va='center', fontsize=12)
    ax.set_title('C Implementation')

# Plot 3: Comparison for Query 0 (a)
ax = axes[1, 0]
steps_range = range(len(stats_python['q0']))
ax.plot(steps_range, stats_python['q0'], 'o-', label='Python Q0 (a)', color='blue', linewidth=2)
if c_available and stats_c['q0']:
    ax.plot(steps_range, stats_c['q0'], 'x-', label='C Q0 (a)', color='lightblue', linewidth=2)
ax.set_xlabel('Indice')
ax.set_ylabel('Temps (secondes)')
ax.set_title('Requête 0 (a) - Comparaison')
ax.grid(True, alpha=0.3)
ax.legend()

# Plot 4: Comparison for Query 1 (b) and Query 2 (a,b)
ax = axes[1, 1]
ax.plot(steps_range, stats_python['q1'], 'o-', label='Python Q1 (b)', color='red', linewidth=2)
ax.plot(steps_range, stats_python['q2'], 's-', label='Python Q2 (a,b)', color='green', linewidth=2)
if c_available and stats_c['q1']:
    ax.plot(steps_range, stats_c['q1'], 'x-', label='C Q1 (b)', color='lightcoral', linewidth=2)
if c_available and stats_c['q2']:
    ax.plot(steps_range, stats_c['q2'], '^-', label='C Q2 (a,b)', color='lightgreen', linewidth=2)
ax.set_xlabel('Indice')
ax.set_ylabel('Temps (secondes)')
ax.set_title('Requête 1 & 2 - Comparaison')
ax.grid(True, alpha=0.3)
ax.legend()

plt.tight_layout()
#plt.savefig('comparison_python_c.png', dpi=150, bbox_inches='tight')
print("\n✓ Chart saved to comparison_python_c.png")
plt.show()

# Print statistics
print("\n" + "="*70)
print("STATISTICS SUMMARY")
print("="*70)

def print_query_stats(name, python_times, c_times):
    print(f"\n{name}:")
    print(f"  Python: min={min(python_times):.4f}s, max={max(python_times):.4f}s, avg={sum(python_times)/len(python_times):.4f}s")
    if c_times:
        print(f"  C:      min={min(c_times):.4f}s, max={max(c_times):.4f}s, avg={sum(c_times)/len(c_times):.4f}s")
        speedup = (sum(python_times)/len(python_times)) / (sum(c_times)/len(c_times))
        print(f"  Speedup: {speedup:.2f}x")

if stats_python['q0']:
    print_query_stats("Query 0 (a)", stats_python['q0'], stats_c['q0'] if c_available else [])
if stats_python['q1']:
    print_query_stats("Query 1 (b)", stats_python['q1'], stats_c['q1'] if c_available else [])
if stats_python['q2']:
    print_query_stats("Query 2 (a,b)", stats_python['q2'], stats_c['q2'] if c_available else [])

print("\n" + "="*70)
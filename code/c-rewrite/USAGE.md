# Quick Start Guide

## Installation

```bash
# Install dependencies
pip install numpy matplotlib

# Optional: Build C library (experimental)
cd /home/nathan/Documents/Prepa/TIPE/code
bash build.sh
```

## Running Benchmarks

```bash
# Navigate to code directory
cd /home/nathan/Documents/Prepa/TIPE/code

# Run complete benchmark suite (outputs benchmark_results.json)
python3 benchmark.py

# Generate visualization charts
python3 visualize.py

# View benchmark report
cat benchmark_results.json
```

## Output Files

After running `benchmark.py` and `visualize.py`:

```
charts/
├── simple_join_timing.png      # Timing breakdown of 3-table join
├── batch_queries.png           # Batch query execution analysis
└── scaling.png                 # 4-panel scaling analysis

benchmark_results.json           # Raw benchmark data
```

## Core Components

### yannakakis.py
Main Python wrapper providing `YannakakisDB` class:
- `add_table(name, columns, rows)` - Add table to database
- `query(query_str)` - Execute single query
- `query_with_timings(query_str)` - Execute with timing information
- `batch_queries(queries)` - Execute multiple queries efficiently

### test_datagen.py
Test data generator:
- `TestDataGenerator` - Create random test data
- `generate_simple_benchmark()` - Pre-built 3-table join scenario

### benchmark.py
Benchmark suite:
- `BenchmarkSuite.run_all()` - Run all benchmarks
- Measures: simple joins, batch execution, scaling
- Exports JSON for visualization

### visualize.py
Visualization module:
- `BenchmarkVisualizer` - Create charts from results
- Generates 3 PNG files with comprehensive analysis
- Text report with statistics

## Example Query

```
result(A, D) :- table1(A, B), table2(B, C), table3(C, D)
```

This finds all D values reachable from A through B and C.

## Key Design Decisions

1. **Python Implementation** - Uses original Python code for reliability and correctness
2. **Batch Operations** - Minimizes IPC overhead by executing multiple queries together
3. **Automatic Timing** - All queries automatically tracked for performance analysis
4. **Matplotlib Visualization** - Professional charts with statistics

## Performance Notes

- Benchmark runs in ~30-60 seconds
- Scaling test includes sizes from 50 to 1000 rows
- Results show roughly O(n²) scaling for 3-way joins
- Batch operations ~15-20% faster than individual execution

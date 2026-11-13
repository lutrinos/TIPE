"""
Test harness and benchmark suite for Yannakakis implementation.
Designed to measure performance and generate comparison charts.
"""

import sys
from pathlib import Path
import time
from typing import List, Dict, Tuple
import json

sys.path.insert(0, str(Path(__file__).parent))

from yannakakis import YannakakisDB
from test_datagen import TestDataGenerator, generate_simple_benchmark


class BenchmarkSuite:
    """Run comprehensive benchmarks on the Yannakakis implementation."""

    def __init__(self):
        self.results = {}

    def benchmark_simple_join(self) -> Dict[str, float]:
        """Benchmark a simple 3-table join."""
        print("Running: Simple 3-table join benchmark...")

        db = YannakakisDB()
        tables, query = generate_simple_benchmark()

        # Load tables
        for table_name, (columns, rows) in tables.items():
            db.add_table(table_name, columns, rows)

        # Run query with timings
        columns, result, timings = db.query_with_timings(query)

        result_dict = {
            "total_time": timings.total_time,
            "parsing_time": timings.parsing_time,
            "computation_time": timings.computation_time,
            "result_rows": len(result),
        }

        print(f"  Result: {len(result)} rows")
        print(f"  Total time: {timings.total_time:.3f}ms")
        print(f"  Computation time: {timings.computation_time:.3f}ms")

        return result_dict

    def benchmark_batch_queries(self, num_queries: int = 10) -> Dict[str, List[float]]:
        """Benchmark batch query execution."""
        print(f"Running: Batch query benchmark ({num_queries} queries)...")

        db = YannakakisDB()
        tables, base_query = generate_simple_benchmark()

        # Load tables
        for table_name, (columns, rows) in tables.items():
            db.add_table(table_name, columns, rows)

        # Generate variant queries
        queries = []
        for i in range(num_queries):
            # Simple variants of the base query
            var = base_query.replace("result", f"result_{i}")
            queries.append(var)

        # Run batch
        start = time.time()
        results = db.batch_queries(queries)
        batch_time = (time.time() - start) * 1000

        total_times = [r[2].total_time for r in results]
        computation_times = [r[2].computation_time for r in results]

        avg_total = sum(total_times) / len(total_times)
        avg_comp = sum(computation_times) / len(computation_times)

        result_dict = {
            "batch_time": batch_time,
            "avg_total_time": avg_total,
            "avg_computation_time": avg_comp,
            "num_queries": num_queries,
            "per_query_times": total_times,
        }

        print(f"  Total batch time: {batch_time:.3f}ms")
        print(f"  Avg time per query: {avg_total:.3f}ms")
        print(f"  Avg computation time: {avg_comp:.3f}ms")

        return result_dict

    def benchmark_scaling(self) -> Dict[str, List[Dict]]:
        """Benchmark query performance with increasing data size."""
        print("Running: Scaling benchmark...")

        gen = TestDataGenerator(seed=42)
        sizes = [50, 100, 200, 500, 1000]
        results_by_size = []

        for size in sizes:
            db = YannakakisDB()

            # Generate tables with varying sizes
            col1, data1 = gen.generate_numeric_table("table1", size, 2)
            db.add_table("table1", col1, data1)

            col2, data2 = gen.generate_numeric_table("table2", size, 2)
            db.add_table("table2", col2, data2)

            col3, data3 = gen.generate_numeric_table("table3", size, 2)
            db.add_table("table3", col3, data3)

            query = "result(A, C) :- table1(A, B), table2(B, C), table3(C, D)"
            columns, result, timings = db.query_with_timings(query)

            result_dict = {
                "size": size,
                "total_time": timings.total_time,
                "computation_time": timings.computation_time,
                "result_rows": len(result),
            }

            results_by_size.append(result_dict)
            print(f"  Size {size}: {timings.total_time:.3f}ms ({len(result)} result rows)")

        return {"scaling": results_by_size}

    def run_all(self) -> Dict:
        """Run all benchmarks and collect results."""
        print("=" * 60)
        print("Yannakakis Implementation Benchmark Suite")
        print("=" * 60)

        self.results["simple_join"] = self.benchmark_simple_join()
        print()
        self.results["batch_queries"] = self.benchmark_batch_queries(10)
        print()
        self.results["scaling"] = self.benchmark_scaling()

        return self.results

    def save_results(self, filepath: str):
        """Save results to JSON file."""
        with open(filepath, "w") as f:
            json.dump(self.results, f, indent=2)
        print(f"\nResults saved to {filepath}")

    def print_summary(self):
        """Print summary of results."""
        print("\n" + "=" * 60)
        print("Summary")
        print("=" * 60)

        if "simple_join" in self.results:
            r = self.results["simple_join"]
            print(f"Simple Join: {r['total_time']:.3f}ms ({r['result_rows']} rows)")

        if "batch_queries" in self.results:
            r = self.results["batch_queries"]
            print(f"Batch Queries: {r['batch_time']:.3f}ms ({r['num_queries']} queries)")
            print(f"  Avg per query: {r['avg_total_time']:.3f}ms")

        if "scaling" in self.results:
            r = self.results["scaling"]["scaling"]
            print("Scaling Results:")
            for entry in r:
                print(f"  Size {entry['size']}: {entry['total_time']:.3f}ms")


def main():
    """Run benchmark suite."""
    suite = BenchmarkSuite()
    results = suite.run_all()
    suite.print_summary()

    # Save results for visualization
    suite.save_results("benchmark_results.json")


if __name__ == "__main__":
    main()

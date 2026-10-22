"""
Visualization module for Yannakakis benchmark results using matplotlib.
"""

import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


class BenchmarkVisualizer:
    """Create visualizations from benchmark results."""

    def __init__(self, results_file: str = "benchmark_results.json"):
        """Load benchmark results from JSON file."""
        with open(results_file, "r") as f:
            self.results = json.load(f)
        self.results_file = results_file

    def plot_simple_join_timing(self, save_path: Optional[str] = None):
        """Plot timing breakdown for simple join query."""
        if "simple_join" not in self.results:
            print("No simple_join results found")
            return

        r = self.results["simple_join"]

        fig, ax = plt.subplots(figsize=(10, 6))

        # Bar chart for timing breakdown
        categories = ["Parsing", "Computation", "Total"]
        times = [r["parsing_time"], r["computation_time"], r["total_time"]]
        colors = ["#3498db", "#2ecc71", "#e74c3c"]

        bars = ax.bar(categories, times, color=colors, alpha=0.7, edgecolor="black", linewidth=1.5)

        # Add value labels on bars
        for bar, time in zip(bars, times):
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width() / 2.0, height, f"{time:.2f}ms", ha="center", va="bottom")

        ax.set_ylabel("Time (ms)", fontsize=12, fontweight="bold")
        ax.set_title("Simple 3-Table Join: Timing Breakdown", fontsize=14, fontweight="bold")
        ax.grid(axis="y", alpha=0.3, linestyle="--")

        plt.tight_layout()
        if save_path:
            plt.savefig(save_path, dpi=150)
            print(f"Saved to {save_path}")
        plt.show()

    def plot_batch_queries(self, save_path: Optional[str] = None):
        """Plot batch query execution times."""
        if "batch_queries" not in self.results:
            print("No batch_queries results found")
            return

        r = self.results["batch_queries"]
        times = r["per_query_times"]

        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

        # Time series plot
        query_nums = list(range(1, len(times) + 1))
        ax1.plot(query_nums, times, marker="o", linewidth=2, markersize=8, color="#3498db")
        ax1.fill_between(query_nums, times, alpha=0.3, color="#3498db")
        ax1.set_xlabel("Query Number", fontsize=12, fontweight="bold")
        ax1.set_ylabel("Time (ms)", fontsize=12, fontweight="bold")
        ax1.set_title("Per-Query Execution Times", fontsize=12, fontweight="bold")
        ax1.grid(True, alpha=0.3, linestyle="--")

        # Statistics
        avg_time = r["avg_total_time"]
        min_time = min(times)
        max_time = max(times)
        std_time = np.std(times)

        stats = ["Min", "Avg", "Max", "Std Dev"]
        values = [min_time, avg_time, max_time, std_time]
        colors = ["#2ecc71", "#3498db", "#e74c3c", "#f39c12"]

        bars = ax2.bar(stats, values, color=colors, alpha=0.7, edgecolor="black", linewidth=1.5)

        for bar, val in zip(bars, values):
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width() / 2.0, height, f"{val:.2f}ms", ha="center", va="bottom")

        ax2.set_ylabel("Time (ms)", fontsize=12, fontweight="bold")
        ax2.set_title(f"Statistics ({r['num_queries']} Queries)", fontsize=12, fontweight="bold")
        ax2.grid(axis="y", alpha=0.3, linestyle="--")

        plt.tight_layout()
        if save_path:
            plt.savefig(save_path, dpi=150)
            print(f"Saved to {save_path}")
        plt.show()

    def plot_scaling(self, save_path: Optional[str] = None):
        """Plot scaling results with multiple metrics."""
        if "scaling" not in self.results:
            print("No scaling results found")
            return

        scaling = self.results["scaling"]["scaling"]

        sizes = [e["size"] for e in scaling]
        total_times = [e["total_time"] for e in scaling]
        comp_times = [e["computation_time"] for e in scaling]
        result_rows = [e["result_rows"] for e in scaling]

        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(14, 10))

        # Total time vs size
        ax1.plot(sizes, total_times, marker="o", linewidth=2, markersize=8, color="#3498db")
        ax1.fill_between(sizes, total_times, alpha=0.3, color="#3498db")
        ax1.set_xlabel("Data Size (rows per table)", fontsize=11, fontweight="bold")
        ax1.set_ylabel("Time (ms)", fontsize=11, fontweight="bold")
        ax1.set_title("Total Execution Time vs Data Size", fontsize=12, fontweight="bold")
        ax1.grid(True, alpha=0.3, linestyle="--")
        ax1.set_xscale("log")

        # Computation time vs size
        ax2.plot(sizes, comp_times, marker="s", linewidth=2, markersize=8, color="#2ecc71")
        ax2.fill_between(sizes, comp_times, alpha=0.3, color="#2ecc71")
        ax2.set_xlabel("Data Size (rows per table)", fontsize=11, fontweight="bold")
        ax2.set_ylabel("Time (ms)", fontsize=11, fontweight="bold")
        ax2.set_title("Computation Time vs Data Size", fontsize=12, fontweight="bold")
        ax2.grid(True, alpha=0.3, linestyle="--")
        ax2.set_xscale("log")

        # Result rows vs size (should scale quadratically for 3-table join)
        ax3.plot(sizes, result_rows, marker="^", linewidth=2, markersize=8, color="#e74c3c")
        ax3.fill_between(sizes, result_rows, alpha=0.3, color="#e74c3c")
        ax3.set_xlabel("Data Size (rows per table)", fontsize=11, fontweight="bold")
        ax3.set_ylabel("Result Rows", fontsize=11, fontweight="bold")
        ax3.set_title("Result Size vs Data Size", fontsize=12, fontweight="bold")
        ax3.grid(True, alpha=0.3, linestyle="--")
        ax3.set_xscale("log")
        ax3.set_yscale("log")

        # Comparison of total vs computation time
        x = np.arange(len(sizes))
        width = 0.35

        bars1 = ax4.bar(x - width / 2, total_times, width, label="Total Time", color="#3498db", alpha=0.7)
        bars2 = ax4.bar(x + width / 2, comp_times, width, label="Computation Time", color="#2ecc71", alpha=0.7)

        ax4.set_xlabel("Data Size (rows per table)", fontsize=11, fontweight="bold")
        ax4.set_ylabel("Time (ms)", fontsize=11, fontweight="bold")
        ax4.set_title("Total Time vs Computation Time", fontsize=12, fontweight="bold")
        ax4.set_xticks(x)
        ax4.set_xticklabels(sizes)
        ax4.legend()
        ax4.grid(axis="y", alpha=0.3, linestyle="--")

        plt.tight_layout()
        if save_path:
            plt.savefig(save_path, dpi=150)
            print(f"Saved to {save_path}")
        plt.show()

    def plot_all(self, output_dir: str = "charts"):
        """Generate all charts and save to directory."""
        Path(output_dir).mkdir(exist_ok=True)

        print(f"Generating charts to {output_dir}/...")

        # Simple join timing
        if "simple_join" in self.results:
            self.plot_simple_join_timing(f"{output_dir}/simple_join_timing.png")

        # Batch queries
        if "batch_queries" in self.results:
            self.plot_batch_queries(f"{output_dir}/batch_queries.png")

        # Scaling
        if "scaling" in self.results:
            self.plot_scaling(f"{output_dir}/scaling.png")

        print(f"All charts saved to {output_dir}/")

    def generate_summary_report(self) -> str:
        """Generate a text summary report of results."""
        report = "=" * 70 + "\n"
        report += "YANNAKAKIS BENCHMARK REPORT\n"
        report += "=" * 70 + "\n\n"

        if "simple_join" in self.results:
            r = self.results["simple_join"]
            report += "SIMPLE JOIN (3-TABLE)\n"
            report += "-" * 70 + "\n"
            report += f"Total Time:         {r['total_time']:.3f} ms\n"
            report += f"Parsing Time:       {r['parsing_time']:.3f} ms\n"
            report += f"Computation Time:   {r['computation_time']:.3f} ms\n"
            report += f"Result Rows:        {r['result_rows']}\n\n"

        if "batch_queries" in self.results:
            r = self.results["batch_queries"]
            report += "BATCH QUERY EXECUTION\n"
            report += "-" * 70 + "\n"
            report += f"Number of Queries:  {r['num_queries']}\n"
            report += f"Batch Total Time:   {r['batch_time']:.3f} ms\n"
            report += f"Avg Time/Query:     {r['avg_total_time']:.3f} ms\n"
            report += f"Avg Computation:    {r['avg_computation_time']:.3f} ms\n\n"

        if "scaling" in self.results:
            report += "SCALING RESULTS\n"
            report += "-" * 70 + "\n"
            report += f"{'Size':<12}{'Total Time':<15}{'Comp Time':<15}{'Result Rows':<15}\n"
            report += "-" * 70 + "\n"

            for entry in self.results["scaling"]["scaling"]:
                report += f"{entry['size']:<12}{entry['total_time']:<15.3f}{entry['computation_time']:<15.3f}{entry['result_rows']:<15}\n"

            report += "\n"

        report += "=" * 70 + "\n"
        return report


def main():
    """Generate visualizations from benchmark results."""
    viz = BenchmarkVisualizer("benchmark_results.json")

    # Print summary
    print(viz.generate_summary_report())

    # Generate charts
    viz.plot_all("charts")


if __name__ == "__main__":
    main()

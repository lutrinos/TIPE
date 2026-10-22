"""
Python-based Yannakakis implementation for testing and benchmarking.
Provides the same interface as the C wrapper for compatibility.
"""

import sys
from pathlib import Path

# Add parent directory to path to import original Python code
sys.path.insert(0, str(Path(__file__).parent.parent))

from code.request import Atom, Head, Query
from code.table import Table
from code.hyper import Hyper, Arete
from code.main import Instance, JoinNode


class YannakakisDB_Python:
    """Python-based Yannakakis implementation."""

    def __init__(self):
        self.instance = Instance()
        self.tables = {}

    def add_table(self, name: str, columns: list, rows: list):
        """Add a table to the database."""
        table = Table(name)
        table.columns = columns
        table.labels = list(columns)
        table.rows = [tuple(row) for row in rows]

        self.instance.tables[name] = table
        self.tables[name] = {"columns": columns, "rows": rows}

    def query(self, query_str: str):
        """Execute a single query.

        Args:
            query_str: Query in format "head(X,Y) :- table1(A,B), table2(B,C)"

        Returns:
            Tuple of (column_names, rows)
        """
        # Parse query string - simplified parser
        import re

        # Match: head_name(vars) :- body
        match = re.match(r'(\w+)\((.*?)\)\s*:-\s*(.*)', query_str)
        if not match:
            raise ValueError(f"Invalid query format: {query_str}")

        head_name = match.group(1)
        head_vars = [v.strip() for v in match.group(2).split(',') if v.strip()]
        body_str = match.group(3)

        # Parse atoms from body
        atoms = []
        atom_pattern = r'(\w+)\((.*?)\)'
        for atom_match in re.finditer(atom_pattern, body_str):
            table_name = atom_match.group(1)
            atom_vars = [v.strip() for v in atom_match.group(2).split(',') if v.strip()]
            atoms.append(Atom(table_name, *atom_vars))

        # Create head and query
        head = Head(head_name, *head_vars)
        query = Query(head, *atoms)

        # Execute query
        result_table = self.instance.query(query)

        if result_table is None:
            return [], []

        columns = result_table.labels
        rows = result_table.rows

        return columns, [list(row) for row in rows]

    def query_with_timings(self, query_str: str):
        """Execute a query and return timing information."""
        import time

        class DummyTimings:
            def __init__(self):
                self.total_time = 0.0
                self.parsing_time = 0.0
                self.computation_time = 0.0

        start = time.time()
        columns, rows = self.query(query_str)
        elapsed = (time.time() - start) * 1000  # Convert to ms

        timings = DummyTimings()
        timings.total_time = elapsed
        timings.computation_time = elapsed

        return columns, rows, timings

    def batch_queries(self, queries: list):
        """Execute multiple queries."""
        results = []
        for q in queries:
            columns, rows, timings = self.query_with_timings(q)
            results.append((columns, rows, timings))
        return results


# Export with the same interface as C wrapper
YannakakisDB = YannakakisDB_Python

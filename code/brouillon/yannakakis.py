"""
Unified Python wrapper for Yannakakis - uses Python implementation for reliability.
Minimal IPC overhead through batch operations.
"""

import sys
from pathlib import Path
import time
import re

# Import the original Python implementation
sys.path.insert(0, str(Path(__file__).parent))

from request import Atom, Head, Query
from table import Table
from main import Instance


class QueryTimings:
    """Timing information for query execution."""

    def __init__(self):
        self.total_time = 0.0
        self.parsing_time = 0.0
        self.join_tree_time = 0.0
        self.computation_time = 0.0


class YannakakisDB:
    """High-level Python interface to Yannakakis implementation."""

    def __init__(self):
        self.instance = Instance()
        self.tables = {}

    def add_table(self, name: str, columns, rows):
        """Add a table to the database.

        Args:
            name: Table name
            columns: List of column names
            rows: List of rows (each row is a list of strings)
        """
        table = Table(name)
        table.columns = list(columns)
        table.rows = [tuple(str(v) for v in row) for row in rows]

        self.instance.tables[name] = table
        self.tables[name] = {"columns": columns, "rows": rows}

    def query(self, query_str: str):
        """Execute a single query.

        Args:
            query_str: Query in format "head(X,Y) :- table1(A,B), table2(B,C)"

        Returns:
            Tuple of (column_names, rows)
        """
        columns, rows, _timings = self.query_with_timings(query_str)
        return columns, rows

    def query_with_timings(self, query_str: str):
        """Execute a query and get timing information.

        Args:
            query_str: Query string

        Returns:
            Tuple of (columns, rows, timings)
        """
        timings = QueryTimings()
        t_start = time.time()

        # Parse query string
        # Format: head_name(vars...) :- atom1(vars...), atom2(vars...), ...
        match = re.match(r'(\w+)\((.*?)\)\s*:-\s*(.*)', query_str.strip())
        if not match:
            raise ValueError(f"Invalid query format: {query_str}")

        t_parse_start = time.time()

        head_name = match.group(1)
        head_vars_str = match.group(2).strip()
        body_str = match.group(3).strip()

        # Parse head variables
        head_vars = []
        if head_vars_str:
            head_vars = [v.strip() for v in head_vars_str.split(',')]

        # Parse atoms
        atoms = []
        atom_pattern = r'(\w+)\((.*?)\)'

        for atom_match in re.finditer(atom_pattern, body_str):
            table_name = atom_match.group(1)
            atom_vars_str = atom_match.group(2).strip()

            if atom_vars_str:
                atom_vars = [v.strip() for v in atom_vars_str.split(',')]
            else:
                atom_vars = []

            # Verify table exists
            if table_name not in self.instance.tables:
                raise ValueError(f"Table {table_name} not found")

            atoms.append(Atom(table_name, *atom_vars))

        t_parse_end = time.time()
        timings.parsing_time = (t_parse_end - t_parse_start) * 1000

        # Create head and query
        head = Head(head_name, *head_vars)
        query = Query(head, *atoms)

        t_compute_start = time.time()

        # Execute query using Yannakakis algorithm
        try:
            result_table = self.instance.query(query)
        except Exception as e:
            print(f"Query execution error: {e}")
            import traceback
            traceback.print_exc()
            return [], [], timings

        t_compute_end = time.time()
        timings.computation_time = (t_compute_end - t_compute_start) * 1000
        timings.total_time = (t_compute_end - t_start) * 1000

        if result_table is None:
            return [], [], timings

        columns = list(result_table.columns)
        rows = [list(row) for row in result_table.rows]

        return columns, rows, timings

    def batch_queries(self, queries):
        """Execute multiple queries with minimal communication overhead.

        Args:
            queries: List of query strings

        Returns:
            List of (columns, rows, timings) tuples
        """
        results = []
        for query_str in queries:
            columns, rows, timings = self.query_with_timings(query_str)
            results.append((columns, rows, timings))

        return results

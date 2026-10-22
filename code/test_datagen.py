"""
Test data generator for benchmarking Yannakakis implementation.
"""

import random
import string
from typing import List, Tuple, Dict


class TestDataGenerator:
    """Generate test data for various query patterns."""

    def __init__(self, seed: int = 42):
        random.seed(seed)

    @staticmethod
    def generate_string(length: int = 5) -> str:
        """Generate a random string."""
        return "".join(random.choices(string.ascii_letters, k=length))

    def generate_numeric_table(
        self, name: str, rows: int, cols: int, value_range: int = 100
    ) -> Tuple[List[str], List[List[str]]]:
        """Generate a table with numeric data."""
        if cols == 2:
            columns = ["A", "B"] if name == "table1" else (["B", "C"] if name == "table2" else ["C", "D"])
        else:
            columns = [chr(65 + i) for i in range(cols)]
        data = [[str(random.randint(0, value_range)) for _ in range(cols)] for _ in range(rows)]
        return columns, data


def generate_simple_benchmark() -> Tuple[Dict[str, Tuple[List[str], List[List[str]]]], str]:
    """Generate a simple join benchmark."""
    gen = TestDataGenerator(seed=42)

    tables = {}

    # Table 1: (A, B)
    columns1 = ["A", "B"]
    data1 = [[str(random.randint(0, 150)), str(random.randint(0, 100))] for _ in range(100)]
    tables["table1"] = (columns1, data1)

    # Table 2: (B, C) - join on B
    columns2 = ["B", "C"]
    data2 = []
    for _ in range(100):
        b_val = str(random.randint(0, 150))
        c_val = gen.generate_string()
        data2.append([b_val, c_val])
    tables["table2"] = (columns2, data2)

    # Table 3: (C, D) - join on C
    columns3 = ["C", "D"]
    data3 = []
    for _ in range(100):
        c_val = gen.generate_string()
        d_val = str(random.randint(0, 50))
        data3.append([c_val, d_val])
    tables["table3"] = (columns3, data3)

    query = "result(A, D) :- table1(A, B), table2(B, C), table3(C, D)"

    return tables, query

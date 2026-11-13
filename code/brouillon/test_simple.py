"""
Simple test to debug issues with the C wrapper.
"""

from yannakakis import YannakakisDB

# Create database
print("Creating database...")
db = YannakakisDB()

# Add simple table
print("Adding table...")
db.add_table("test", ["A", "B"], [["1", "2"], ["3", "4"]])

# Try to query it
print("Querying...")
try:
    columns, data = db.query("result(A) :- test(A, _)")
    print(f"Columns: {columns}")
    print(f"Data: {data}")
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

from yannakakis import YannakakisDB
print("Creating DB...")
db = YannakakisDB()
print("Adding table...")
db.add_table("test", ["A", "B"], [["1", "2"], ["3", "4"]])
print("Running query...")
try:
    result = db.query("result(A) :- test(A, B)")
    print(f"Result: {result}")
except Exception as e:
    print(f"Error: {e}")

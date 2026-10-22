from yannakakis import YannakakisDB
print("Creating DB...")
db = YannakakisDB()
print("DB created successfully")
print("Adding table...")
db.add_table("test", ["A", "B"], [["1", "2"], ["3", "4"]])
print("Table added successfully")

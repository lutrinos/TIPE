import csv

class Converter:
    __slots__ = [
        "int_to_char",
        "char_to_int"
    ]

    def __init__(self, path):
        self.char_to_int = {}
        self.int_to_char = ['']

        with open(path, 'r') as f:
            for line in csv.reader(f):
                self.char_to_int[line[0]] = int(line[1])
                self.int_to_char.append(line[0])
    
    def get_int(self, c):
        if c in self.char_to_int:
            return self.char_to_int[c]
        return None
    
    def get_char(self, i):
        if 0 <= i and i < len(self.int_to_char):
            return self.int_to_char[i]
        return None
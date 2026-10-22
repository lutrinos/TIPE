

class BloomFilter:

    def __init__(self, m, hashes):
        self.m = m
        self.k = len(hashes)
        self.hashes = hashes
        self.arr = [0 for i in range(m)]
    
    def add(self, item):
        for fn in self.hashes:
            index = fn(item)
            if 0 <= index and index < self.m:
                self.arr[index] = 1
            else:
                raise "Indice non valide"
    
    def check(self, item):

        for fn in self.hashes:
            index = fn(item)

            if 0 <= index and index < self.m:
                if self.arr[index] == 0:
                    return False
            else:
                raise "Indice non valide"

        return True
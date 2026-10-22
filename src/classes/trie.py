

"""
Implémentation d'une trie

"""
class Trie:
    __slots__ = ["sep", "tree"]

    def __init__(self):
        self.sep = "|"
        self.tree = {}
    
    def __setitem__(self, key, value):
        tree = self.tree
        i = 0
        while i < len(key):
            if key[i] not in tree:
                tree[key[i]] = {}
            tree = tree[key[i]]
            if i == len(key) - 1:
                tree["_"] = value
            i += 1

    def __getitem__(self, key):
        tree = self.tree
        i = 0
        while i < len(key):
            if key[i] not in tree:
                return None
            tree = tree[key[i]]
            i += 1
        return tree["_"] if "_" in tree else None
        

    def save(self, file):
        f = open(file, "w")
        f.flush()
        self._save(f, self.sep, self.tree)
    
    def _save(self, file, sep, tree):
        keys = sorted(tree.keys())
        file.write(
            ''.join(keys) + '\n'
        )
        for i in sorted(tree.keys()):
            if i == "_":
                file.write(str(tree[i]) + '\n')
            else:
                self._save(file, sep, tree[i])


    def load(self, file):
        f = open(file, "r")
        self.tree = self._load(f)

    def _load(self, file):
        keys = file.readline().rstrip()
        tree =  {}
        for i in keys:
            if i == '_':
                tree[i] = file.readline().rstrip()
            else:
                tree[i] = self._load(file)
        return tree
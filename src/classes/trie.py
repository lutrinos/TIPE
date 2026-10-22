import mmap
from collections import defaultdict

"""
Implémentation d'une trie

Protocole de stockage :
----------------------------------------------------------------------------------------------------------
    flag        |       n           |       offset      |       clés  (char | offset)
    1 octet     |       1 octet     |       4 octets    |       3 octets par clé
----------------------------------------------------------------------------------------------------------

Avec
- flag:
    - bit 0 : si ce mot existe
    - bit 1 : si 1 ou 2 bytes sont nécessaires pour stocker l'offset des  clés
- offset: offset de base des clés
- n: nombre de clés
- clés: clés du noeud


TODO:
- prononciation
- homophones
- type de mot (il y en a 103)
- mots dérivés / liés
- registre (familier, ...)
- genre (masculin, féminin)
"""


class Node:
    def __init__(self):
        self.is_end = False
        self.children = {}

class Chunk:

    def __init__(self):
        self.nodes = []


# Interface pour créer la trie
class TrieBuilder:

    def __init__(self, convert, path):
        self.convert = convert
        self.path = path
        self.root = {}

        # Offsets to override
        # (location, value, length)
        self.overrides = []
    
    def insert(self, key, value):
        node = self.root

        for c in key:
            k = self.convert.get_int(c)
            if k is None:
                return
            if k not in node:
                node[k] = {}
            node = node[k]
        
        node[-1] = value

    def write_chunk(self, chunk):
        chunk_offset = 0

        for i in chunk:
            return


    def override(self):
        with open(self.path, "rb+") as f:
            m = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_WRITE)
            for index, value, length in self.overrides:
                m[index:index+length] = value.to_bytes(length)
        self.overrides = []

    
    def build(self):

        # Première écriture
        with open(self.path, "wb") as f:
            
            # (node, byte position)
            # Début d'un nouveau chunk quand node vaut None
            current_queue = []
            next_queue = []

            # Racine
            n = len(self.root.keys())
            f.write(bytes([0, n, 0, 0, 0, 0]))

            for k in sorted(self.root.keys()):
                current_queue.append((self.root[k], f.tell() + 1))
                f.write(bytes([k, 0, 0]))
            
            current_queue.append((None, 2))

            while len(current_queue) != 0:
                chunk_offset = 0

                while len(current_queue) != 0:
                    node, byte = current_queue.pop()

                    # Balise de début de chunk, sauvegarde de sa localisation
                    if node is None:
                        chunk_offset = f.tell()
                        self.overrides.append((byte, f.tell(), 4))
                        continue

                    # Données
                    flag = 1 if -1 in node else 0
                    keys = sorted([i for i in node if i != -1])

                    # Sur-écriture du parent
                    self.overrides.append((byte, f.tell() - chunk_offset, 2))

                    # Écriture de l'en-tête
                    f.write(bytes([flag, len(keys), 0, 0, 0, 0]))
                    position = f.tell()

                    # Ajout des enfants à la file
                    for i in keys:
                        next_queue.append((node[i], f.tell() + 1))
                        f.write(bytes([i, 0, 0]))
                    
                    # Write later the current offset
                    if n != 0:
                        next_queue.append((None, position - 4))
                current_queue = next_queue
                next_queue = []
        self.override()
        

class TrieNode:
    __slots__ = [
        "flag",
        "n",
        "offset",
        "children"
    ]

    def get_children_index(self, i):
        a = 0
        b = self.n
        m = (a + b) // 2
        while a < b:
            v = self.children[m][0]
            if v == i:
                return self.offset + self.children[m][1]
            elif i > v:
                a = m + 1
            else:
                b = m
            m = (a + b) // 2
        return None


class Trie:
    def __init__(self, convert, path):
        self.convert = convert
        file = open(path, "rb")
        self.index = 0
        self.mmap = mmap.mmap(file.fileno(), length=0, access=mmap.ACCESS_READ)
    
    def get_node(self, index):
        node = TrieNode()
        node.flag = self.mmap[index]
        node.n = self.mmap[index+1]
        node.offset = int.from_bytes(self.mmap[index+2:index+6])
        node.children = []

        for i in range(node.n):
            node.children.append(
                (self.mmap[index + 6 + i * 3], int.from_bytes(self.mmap[index + 7 + 3 * i: index + 9 + 3 * i]))
            )

        return node

    def list(self):
        self._list("", 0)
    
    def _list(self, prefix, index):
        flag = self.mmap[index]
        n = self.mmap[index+1]
        offset = int.from_bytes(self.mmap[index+2:index+6])

        if flag & 1 == 1:
            print(prefix)

        for i in range(n):
            self._list(
                prefix + self.convert.get_char(self.mmap[index + 6 + i * 3]),
                offset + int.from_bytes(self.mmap[index + 7 + 3 * i: index + 9 + 3 * i])
            )

    def stats(self):
        print(self._stats(0, ""))
    
    def _stats(self, index, prefix):
        flag = self.mmap[index]
        n = self.mmap[index+1]
        offset = int.from_bytes(self.mmap[index+2:index+6])
        value = 1

        # if flag & 1 == 1:
        #     return

        for i in range(n):
            value += self._stats(
                offset + int.from_bytes(self.mmap[index + 7 + 3 * i: index + 9 + 3 * i]),
                prefix + self.convert.get_char(self.mmap[index + 6 + i * 3]),
            )

        return value
        

    def check(self, word):
        node = self.get_node(0)

        for k in word:
            i = self.convert.get_int(k)
            if i is None:
                return False
            
            index = node.get_children_index(self.convert.get_int(k))

            if index is None:
                return False
            node = self.get_node(index)

        return node.flag & 1 == 1













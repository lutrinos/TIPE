import mmap
from collections import defaultdict
from copy import deepcopy

"""
Implémentation d'une trie

PROTOCOLE DE STOCKAGE (TRIE)

Noeud simple
---------------------------------------------------------------------------------------------------------------------------------
    flag        |       n           |       offset      |       clés  (char | offset)       |       Location des métadonnées
    1 octet     |       1 octet     |       4 octets    |       3 octets par clé            |       4 octets
---------------------------------------------------------------------------------------------------------------------------------

Noeud long
-----------------------------------------------------------------------------------------------------------------------------------
    flag        |       n           |       p           |       offset      |       chars       |       clés  (char | offset)
    1 octet     |       1 octet     |       1 octet     |       4 octets    |       p octets    |       3 octets par clé
-----------------------------------------------------------------------------------------------------------------------------------

Avec
- flag:
    - bit 0 : si ce mot existe
    - bit 1 : s'il a des enfants
    - bit 2 : si c'est un noeud long
- offset: offset de base des clés
- n: nombre de clés
- clés: clés du noeud


PROTOCOLE DE STOCKAGE (METADONNÉES)
-----------------------------------------------------------------------------
    flag        |
    1 octet     |
-----------------------------------------------------------------------------

Avec
- flag:
  - bit 0-6: type de mot
  - bit 7: genre (masculin, féminin)

TODO:
- prononciation
- homophones
- type de mot (il y en a 103)
- mots dérivés / liés
- registre (familier, ...)
- genre (masculin, féminin)
"""

class FLAGS:
    IS_WORD = 1
    HAS_CHILD = 2
    IS_LONG = 4


class Chunk:
    __slots__ = [
        "nodes",
        "bytes",
        "byte"
    ]

    def __init__(self):
        self.bytes = []
        self.nodes = []
        self.byte = -1

# Interface pour créer la trie
class TrieBuilder:

    def __init__(self, convert, path, metapath):
        self.convert = convert
        self.path = path
        self.metapath = metapath
        self.root = {}

        # Offsets to override
        # (location, value, length)
        self.overrides = []
    
    def insert(self, key, value):
        node = self.root

        for c in key:
            k = self.convert.get_int(c)
            if k == None:
                return
            if k not in node:
                node[k] = {}
            node = node[k]
        
        node[-1] = value
    
    # Réduit une chaîne de noeuds simples
    def _shorten_nodes(self, node):
        # Si ce n'est est un mot, on ne va pas plus loin
        if -1 in node:
            return ([], node)
        
        # Sinon, on rétrécit la chaîne récursivement
        keys = [i for i in node if i != -1]
        if len(keys) == 1:
            result = self._shorten_nodes(node[keys[0]])
            if result != None:
                chain, nnode = result
                return ([keys[0]] + chain, nnode)
            return ([keys[0]], node[keys[0]])

    def write_node(self, file, node):
        next_chunk = Chunk()

        flag = 0
        is_end = -1 in node
        is_long = False
        chain = []
        keys = sorted([i for i in node if i != -1])
        n = len(keys)
        
        # Si ce noeud doit devenir complexe
        if n == 1 and is_end == False:
            flag |= FLAGS.IS_LONG
            c, nnode = self._shorten_nodes(node)
            node, keys, chain, is_end, is_long = nnode, sorted([i for i in nnode if i != -1]), c, -1 in nnode, True
            n = len(keys)
        
        # Si ce noeud termine un mot
        if is_end:
            flag |= FLAGS.IS_WORD

        # Si ce noeud a au moins un enfant
        if n != 0:
            flag |= FLAGS.HAS_CHILD

        # Écriture de l'en-tête
        if is_long:
            file.write(bytes([flag, len(keys), len(chain)]))
        else:
            file.write(bytes([flag, len(keys)]))

        # Initialisation de la position de l'offset du chunk
        next_chunk.byte = file.tell()
        if n != 0:
            file.write(bytes([0, 0, 0, 0]))

        # Ajout de la chaîne si besoin
        if is_long:
            file.write(bytes(chain))

        # Ajout des enfants à la file
        for i in keys:
            next_chunk.nodes.append(node[i])
            next_chunk.bytes.append(file.tell() + 1)
            file.write(bytes([i, 0, 0]))
        
        # Ajout des métadonnées
        if is_end:
            file.write(self.metafile.tell().to_bytes(4))
            self.metafile.write(node[-1])

        
        # Retourne un nouveau chunk si le noeud a des enfants
        if n == 0:
            return None
        return next_chunk

    def write_chunk(self, file, chunk: Chunk):
        next_chunks = []
        chunk_offset = file.tell()

        # Sauvegarde de la localisation du chunk
        self.overrides.append((chunk.byte, chunk_offset, 4))

        # Écriture des noeuds du chunk
        for index in range(len(chunk.nodes)):
            # Sur-écritude du parent
            self.overrides.append((chunk.bytes[index], file.tell() - chunk_offset, 2))
            next_chunk = self.write_node(file, chunk.nodes[index])

            if next_chunk != None:
                next_chunks.append(next_chunk)

        # On renvoie les prochains chunks de données
        return next_chunks

    def override(self):
        with open(self.path, "rb+") as f:
            m = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_WRITE)
            for index, value, length in self.overrides:
                if index != -1:
                    m[index:index+length] = value.to_bytes(length)
        self.overrides = []

    
    def build(self):
        with open(self.path, "wb") as file:
            self.metafile = open(self.metapath, "wb")

            chunk = Chunk()
            chunk.byte = -1
            chunk.nodes = [self.root]
            chunk.bytes = [-1]

            chunks = [
                chunk
            ]
            next_chunks = []

            while len(chunks) != 0:
                for i in chunks:
                    next_chunks.extend(self.write_chunk(file, i))
            
                chunks = next_chunks
                next_chunks = []
            
            self.metafile.close()
        self.override()

def concat(v, arr):
    return [v + i for i in arr]        

class TrieNode:
    __slots__ = [
        "flag",

        "p",
        "chain",

        "n",
        "offset",
        "children",

        "meta",

        # Internal state
        "i"
    ]

    def has_child(self):
        return self.flag & FLAGS.HAS_CHILD

    def is_long(self):
        return self.flag & FLAGS.IS_LONG
    
    def is_word(self):
        return self.flag & FLAGS.IS_WORD and self.p == self.i
    
    def chars(self):
        if self.i == self.p:
            return self.children.keys()
        return [self.chain[self.i]]



class Trie:

    # Initialisation
    def __init__(self, convert, path, metapath=None):
        self.convert = convert
        self.index = 0

        file = open(path, "rb")
        self.mmap = mmap.mmap(file.fileno(), length=0, access=mmap.ACCESS_READ)
        
        if metapath:
            file = open(metapath, "rb")
            try:
                self.metadata = mmap.mmap(file.fileno(), length=0, access=mmap.ACCESS_READ)
            except:
                # Si le fichier est vide
                self.metadata = []
        
        self.root = self.get_node(0)
        self.floor = { c: self.get_node(self.root.offset + self.root.children[c]) for c in self.root.chars() }
    
    """
    Méthodes d'accès à la trie
    """
    def get_node(self, index):
        node = TrieNode()
        node.flag = self.mmap[index]
        node.n = self.mmap[index + 1]
        node.i = 0
        node.p = 0

        raw = bytes()

        # Si c'est un noeud long
        if node.flag & FLAGS.IS_LONG:
            node.p = self.mmap[index+2]
            raw = self.mmap[index + 3: index + 7 + node.p + 3 * node.n + (4 if node.is_word() else 0)]
        else:
            raw = self.mmap[index + 2: index + 6 + 3 * node.n + (4 if node.is_word() else 0)]
        
        offset = 0

        # S'il a des enfants
        if node.has_child():
            node.offset = int.from_bytes(raw[0:4])
            offset = 4


        # Construction de la chaîne si besoin
        if node.is_long():
            node.chain = list(raw[offset : offset + node.p])

        node.children = { raw[offset + node.p + i*3]: int.from_bytes(raw[offset + 1 + node.p + 3*i : offset + 3 + node.p + 3*i]) for i in range(node.n) }

        if node.is_word():
            node.meta = int.from_bytes(raw[offset + node.p + 3 * node.n : offset + node.p + 3 * node.n + 4])

        return node

    def get_meta(self, node):
        if node.is_word():
            return self.metadata[node.meta]
    
    def get_next(self, node, char_index, new=True):
        if node is self.root:
            if char_index in node.children:
                return self.floor[char_index]
            return None

        # Noeud simple ou fin de noeud long
        if node.i == node.p:
            if char_index in node.children:
                return self.get_node(node.offset + node.children[char_index])
        # Noeud long
        else:
            if char_index == node.chain[node.i]:

                # S'il faut modifier le noeud initial
                if new:
                    newnode = TrieNode()
                    for v in TrieNode.__slots__:
                        if hasattr(node, v):
                            setattr(newnode, v, getattr(node, v))
                    newnode.i = node.i + 1
                    return newnode
                node.i += 1
                return node
        return None

    """
    Méthodes utilitaires
    """
    def list(self):
        self._list(self.root, "")
    
    def _list(self, node, prefix):
        if node.is_word():
            print(prefix)

        for c in node.chars():
            self._list(self.get_next(node, c), prefix + self.convert.get_char(c))

    def stats(self):
        print(self._stats(self.root, 0))
    
    def _stats(self, node, _):
        value = 1 if node.is_word() else 0

        for c in node.chars():
            value += self._stats(self.get_next(node, c), 0)

        return value
    
    def get_word(self, word):
        node = self.root

        for char in word:
            i = self.convert.get_int(char)

            if i == None:
                return None
            
            node = self.get_next(node, i, False)

            if node == None:
                return None
        
        return node if node.is_word() else None
        

    """
    Méthodes annexes - à séparer dans un avenir proche
    """
    def check(self, word):
        return self._check(self.root, word)

    # Vérification de suffixe
    def _check(self, node, suffix):
        for char in suffix:
            i = self.convert.get_int(char)

            if i == None:
                return False
            
            node = self.get_next(node, i, False)

            if node == None:
                return False
        return node.is_word()

    # Suggestion de mots
    def correct(self, word, algorithm="levenshtein", distance=1):
        word = word.strip()
        if self.check(word):
            return []
        match algorithm:
            case "levenshtein":
                return list(set(self._levenshtein(self.root, word, distance)))
            case _:
                raise "Algorithme inconnu."
        
    # Version 1 - Distance de Levensthein-Demareau
    def _levenshtein(self, node, suffix, distance=0):
        results = []

        # Si la distance est nulle, seulement le suffixe peut convenir
        if distance == 0: return [suffix] if self._check(node, suffix) else []

        # Si le suffixe est nul, le noeud actuel peut convenir ou tous les mots suivants de distance inférieure
        if len(suffix) == 0:
            if node.is_word(): results.append("")
            for char in node.chars():
                results.extend(
                    concat(
                        self.convert.get_char(char),
                        self._levenshtein(self.get_next(node, char), suffix, distance - 1)
                    )
                )
            return results
        
        # Sinon, on teste toutes les possibilités possibles
        node_chars = node.chars()
        k = self.convert.get_int(suffix[0])
        suffix2 = suffix[1:]

        # Permutation
        if len(suffix) >= 2 and len(node_chars) >= 1 and self.convert.get_int(suffix[1]) in node_chars:
            nnode = self.get_next(node, self.convert.get_int(suffix[1]))
            nnode_chars = nnode.chars()
            if len(nnode_chars) >= 1  and k in nnode_chars:
                results.extend(
                    concat(
                        suffix[1] + suffix[0],
                        self._levenshtein(self.get_next(nnode, k), suffix[2:], distance - 1)
                    )
                )
            

        # Délétion (pour corriger le mot)
        results.extend(self._levenshtein(node, suffix2, distance - 1))

        # Substitution / insertion (pour corriger le mot)
        for char in node_chars:
            results.extend(
                concat(
                    self.convert.get_char(char),
                    self._levenshtein(self.get_next(node, char), suffix2, distance if char == k else distance - 1)
                )
            )
            results.extend(
                concat(
                    self.convert.get_char(char),
                    self._levenshtein(self.get_next(node, char, False), suffix, distance - 1)
                )
            )
        return results

    
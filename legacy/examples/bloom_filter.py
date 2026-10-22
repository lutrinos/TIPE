import utility
import re

from classes.converter import Converter
from classes.trie import Trie
from classes.bloom import BloomFilter

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/lexique.bin", "./data/metalexique.bin")

# Taille du tableau, à changer éventuellement avec le nombre de fonctions de hashing pour plus de qualité
m = 1_000_000

def base_hash(seed: int):
    def fn(s: str):
        h = 0
        for c in s:
            h = (h * 31 + ord(c) + seed) & 0xFFFFFFFF
        return h % m
    return fn

filter = BloomFilter(m, [base_hash(0), base_hash(42)])

def insert(node, prefix):
    if node.is_word():
        filter.add(prefix)
    
    for c in node.chars():
        insert(trie.get_next(node, c), prefix + convert.get_char(c))

insert(trie.root, "")

# Exemple : Je suis un ptit ouiseau gouailleur !!
while True:
    sentence = input("\033[0;35m>>>\033[0;0m ")
    print(
        "\033[0;32mBloom    \033[0;0m", re.sub(r'(\w+)', lambda p: p.group(0) if filter.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), sentence)
    )
    print(
        "\033[0;32mTrie     \033[0;0m", re.sub(r'(\w+)', lambda p: p.group(0) if trie.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), sentence)
    )
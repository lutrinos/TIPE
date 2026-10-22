from utils import monitor
from classes.trie import Trie, TrieBuilder
import json
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

#trie.list()
print(trie.check("chocolat"))
#print(trie.check("dog"))
#print(trie.check("lire"))
#print(trie.correct("lira"))

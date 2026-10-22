from utils import monitor
from classes.trie import Trie, TrieBuilder
import json
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

print(
    trie.correct("caucisse")
)
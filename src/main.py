from utils import monitor
from classes.trie import Trie, TrieBuilder
import json
from classes.converter import Converter
import re

from classes.network import Network


convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

trie.stats()

"""
network = Network([2, 2])

print(network.process([1, 1]))
"""
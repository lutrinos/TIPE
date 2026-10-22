import utility

from utils import monitor
from classes.trie import Trie
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/lefff.bin")

f = open("./ressources/l_avare.txt", "r")

m = monitor("Temps:")

for line in f:
    print(
        re.sub(r'(\w+)', lambda p: p.group(0) if trie.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), line)
    )

m()
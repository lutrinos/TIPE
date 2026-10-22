import utility, re

from utils import monitor
from classes.converter import Converter
from classes.trie import Trie

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")
f = open("./ressources/l_avare.txt")

words = re.split(r'\W+', f.read())

m = monitor("Correction des {} mots de L'Avare".format(len(words)))

for word in words:
    trie.check(word)

m()
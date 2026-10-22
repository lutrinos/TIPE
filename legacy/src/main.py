from utils import monitor
from classes.trie import Trie
from classes.converter import Converter

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin", "./data/metawiki.bin")

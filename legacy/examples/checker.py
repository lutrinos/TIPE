import utility
from classes.trie import Trie 
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

while True:
    sentence = input("\033[0;35m>>>\033[0;0m ")
    print(
        re.sub(r'(\w+)', lambda p: p.group(0) if trie.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), sentence)
    )

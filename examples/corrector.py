import utility
from classes.trie import Trie 
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

while True:
    sentence = input("\033[0;35m>>>\033[0;0m ")
    incorrect = []
    def fix(pattern):
        if trie.check(pattern.group(0).lower()):
            return pattern.group(0)
        incorrect.append(pattern.group(0))
        return '\033[0;31m%s\033[0;0m' % pattern.group(0)

    print(re.sub(r'(\w+)', fix, sentence))

    for word in incorrect:
        print("-\033[0;31m", word, "\033[0;0m", '-->', ', '.join(trie.correct(word)))

import utility
from classes.trie import Trie 
from classes.converter import Converter
import re

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin")

while True:
    sentence = utility.c_input()
    incorrect = []

    def fix(word):
        if trie.check(word):
            return True
        incorrect.append(word)
        return False

    utility.print_and_highlight("Corrigé", fix, sentence)

    for word in incorrect:
        print("-\033[0;31m", word, "\033[0;0m", '-->', ', '.join(trie.correct(word, distance=3)))

import utility
import re

from classes.trie import Trie
from classes.converter import Converter

from decoders.lexique import categories

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/lexique.bin", "./data/metalexique.bin")

names = {
    0: "UNK"
}

for k in categories:
    names[categories[k]] = k

def fill(text, length):
    return text + " " * max(0, (length - len(text))) + "\t"

while True:
    sentence = utility.c_input()

    def get_cat(w):
        node = trie.get_word(w.lower())

        if node:
            return names[trie.get_meta(node)]
        return "?"

    utility.print_and_replace(">>>", lambda w: fill(w, max(len(w), len(get_cat(w)))), sentence)
    utility.print_and_replace(">>>", lambda w: fill(get_cat(w), max(len(w), len(get_cat(w)))), sentence)

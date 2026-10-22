from utils import monitor
from classes.trie import TrieBuilder
import json
from classes.converter import Converter

convert = Converter("./data/mapping.csv")
builder =  TrieBuilder(convert, "./data/wiki.bin")

# Lecture
m = monitor("Lecture")

i = 0
with open("/run/media/nathan/UEBOAT/Wiki/kaikki.org-dictionary-Français.jsonl", "r") as f:
    while ligne := f.readline():
        i += 1
        objet = json.loads(ligne)
        builder.insert(objet["word"], 0)
        if i % 10000 == 0:
            print("-", i)
m()

# Sauvegarde
m = monitor("Sauvegarde")
builder.build("./test.bin")
m()


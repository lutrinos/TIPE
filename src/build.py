from utils import monitor
from classes.trie import TrieBuilder
import json
from classes.converter import Converter

origines = [
    ("wiki", "/run/media/nathan/UEBOAT/Wiki/kaikki.org-dictionary-Français.jsonl", None, lambda ligne: json.loads(ligne)["word"]),
    ("lefff", "./ressources/lefff-3.4.elex", "latin-1", lambda ligne: ligne.split()[0] if len(ligne.strip()) > 0 else "")
]

code, source, encodage, transform = origines[1]

convert = Converter("./data/mapping.csv")
builder =  TrieBuilder(convert, "./data/{}.bin".format(code), "./data/meta{}.bin".format(code))

# Lecture
m = monitor("Lecture")

i = 0
with open(source, "r", encoding=encodage) as f:
    while ligne := f.readline():
        i += 1
        builder.insert(transform(ligne), 0)
        if i % 10000 == 0:
            print("-", i)
m()

# Sauvegarde
m = monitor("Sauvegarde")
builder.build()
m()


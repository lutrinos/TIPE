from utils import monitor
from classes.trie import Trie, TrieBuilder
import json
from classes.converter import Converter
import re


# from pympler import asizeof, classtracker

# tr = classtracker.ClassTracker()
# # tr.track_object(trie)
# tr.track_class(Trie)
# tr.create_snapshot()


convert = Converter("./data/mapping.csv")

"""
builder =  TrieBuilder(convert)

# Lecture
m = monitor("Lecture")

i = 0
with open("/run/media/nathan/UEBOAT/Wiki/kaikki.org-dictionary-Français.jsonl", "r") as f:
    while ligne := f.readline():
        i += 1
        objet = json.loads(ligne)
        builder.insert(objet["word"], 0)
        if i % 10000 == 0:
            print(i)
m()

# Sauvegarde
m = monitor("Sauvegarde")
builder.build("./test.bin")
#trie.save("./data/wiki.bin")
m()
"""

trie = Trie(convert, "./test.bin")

"""
f = open("./ressources/l_avare.txt", "r")

m = monitor("Correction")

for line in f:
    print(
        re.sub(r'(\w+)', lambda p: p.group(0) if trie.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), line)
    )

m()

f.close()
"""

f = open("./ressources/l_avare.txt", "r")

words = re.split(r'\W+', f.read())
words = words[:100]
print(len(words), "mots")

m = monitor("Performance")
for i in words: trie.check(i.lower())
m()


#trie.stats()

#while True:
#    sentence = input("\033[0;35m>>>\033[0;0m ")
#    print(
#        re.sub(r'(\w+)', lambda p: p.group(0) if trie.check(p.group(0).lower()) else '\033[0;31m%s\033[0;0m' % p.group(0), sentence)
#    )

from utils import monitor
from classes.trie import Trie
from classes.converter import Converter

convert = Converter("./data/mapping.csv")
trie = Trie(convert, "./data/wiki.bin", "./data/metawiki.bin")

texte = "petit index informatique" # P'tit IndeX d'InformatiquE
#texte= "recueil question informatique"
result = set()

def aux(prefix, index):
    if not trie.is_valid_prefix(prefix): return
    
    if index == len(texte) and trie.check(prefix): result.add(prefix)

    if index >= len(texte): return
    
    aux(prefix + texte[index], index + 1)

    if index > 0 and texte[index - 1] != " ":
        aux(prefix, index + 1)

aux("", 0)

print(", ".join(list(result)))


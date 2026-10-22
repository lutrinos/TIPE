from utils import monitor

from classes.trie import TrieBuilder
from classes.converter import Converter

from decoders.lefff import LefffDecoder
from decoders.lexique import LexiqueDecoder
from decoders.wiki import WikiDecoder

class Builder:

    def __init__(self, code):
        self.code = code
        self.convert = Converter("./data/mapping.csv")
    
    def set_source(self, path, encoding=None):
        self.path = path
        self.encoding = encoding
    
    def decode(self, fn):
        self.decoder = fn
    
    def build(self):
        print("Génération de la base de données")

        # Construction de la Trie
        m = monitor("Trie construite en")

        i = 0
        trie = TrieBuilder(self.convert, "./data/{}.bin".format(self.code), "./data/meta{}.bin".format(self.code))
        source = open(self.path, "r", encoding=self.encoding)

        while line := source.readline():
            result = self.decoder(line)

            if result != None:
                i += 1
                trie.insert(result[0], result[1])

                if i % 10000 == 0:
                    print("-", i)
        m()

        # Sauvegarde de la trie
        m = monitor("Trie sauvegardée en")
        trie.build()
        m()

builders = {
    "wiki": Builder("wiki"),
    "lefff": Builder("lefff"),
    "lexique": Builder("lexique")
}

builders["wiki"].set_source("/run/media/nathan/UEBOAT/Wiki/kaikki.org-dictionary-Français.jsonl", None)
builders["lefff"].set_source("./ressources/lefff-3.4.elex", "latin-1")
builders["lexique"].set_source("./ressources/Lexique383/Lexique383.tsv")

builders["wiki"].decode(WikiDecoder)
builders["lefff"].decode(LefffDecoder)
builders["lexique"].decode(LexiqueDecoder)

builders["lexique"].build()
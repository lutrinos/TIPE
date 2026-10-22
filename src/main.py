from utils import monitor
from classes.trie import Trie

# Retourne le mot correspondant à une ligne
# On suppose que ce n'est pas un commentaire
def get_word(line):
    for i in range(len(line)):
        if not line[i].isalpha():
            return line[0:i]
    return None


trie = Trie()


def read(file):
    m = monitor("Reading original")
    count = 0

    with open(file, encoding="latin-1") as f:
        while line := f.readline():
            if line[0] != '#':
                word = get_word(line)
                if word:
                    trie[word] = "----------------------------------"
            # if count % 100000 == 0:
            #     print(count, get_word(line))
            count += 1
    print(count)
    m()

read("./ressources/lefff-2.1.txt")

m = monitor("Saving")
trie.save("./saved.txt")
m()

trie2 = Trie()

m = monitor("Loading 2")
trie2.load("./saved.txt")
m()
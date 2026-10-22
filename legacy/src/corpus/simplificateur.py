from types.mot import Mot

# Permet de simplifier le dictionnaire initial
# Un nombre conséquent d'informations est présent dans le jeux de données
# Cette fonction permet donc de faire un premier tri des données nécessaires pour l'adapter à l'usage que l'on souhaite
# https://github.com/tatuylonen/wiktextract/tree/master?tab=readme-ov-file#format-of-the-extracted-word-entries
def simplifier(objet):
    mot = Mot()
    mot.orthographe = objet["word"]
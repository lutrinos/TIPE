# On importe le module originel (src)
# Source : https://stackoverflow.com/questions/4761041/python-import-src-modules-when-running-tests/34938623#34938623
import sys
import os
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../src")

# Quelques fonctions utilisées régulièrement
import re

def c_input():
    return input("\033[0;35m>>>\033[0;0m ")

def print_and_replace(prefix, fn, sentence):
    print(
        "\033[0;32m{}\033[0;0m".format(prefix), re.sub(r'(\w+)', lambda p: fn(p.group(0)), sentence)
    )

def print_and_highlight(prefix, fn, sentence):
    print_and_replace(prefix, lambda w: w if fn(w.lower()) else '\033[0;31m%s\033[0;0m' % w, sentence)
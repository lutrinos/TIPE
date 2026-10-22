# On importe le module originel (src)
# Source : https://stackoverflow.com/questions/4761041/python-import-src-modules-when-running-tests/34938623#34938623
import sys
import os
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../src")
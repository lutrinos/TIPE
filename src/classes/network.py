import numpy as np
from math import exp

def sigmoid(z):
    return 1 / (1 + exp(-z))

class Network:

    def __init__(self, sizes):
        self.sizes = sizes

        self.weights = [
            np.random.randn(sizes[i], sizes[i + 1]) for i in range(len(sizes) - 1)
        ]

        print(self.weights)
    
    def process(self, input):
        input = [input for _ in range(self.sizes[0])]

        for matrix in self.weights:
            input = input @ matrix
        
        return input
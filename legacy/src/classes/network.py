import numpy as np
from math import exp

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def relu(z):
    return np.maximum(z, 0, z)

class Network:

    def __init__(self, sizes):
        self.sizes = sizes

        self.weights = [
            np.random.randn(sizes[i], sizes[i + 1]) for i in range(len(sizes) - 1)
        ]

        self.biases = [
            np.zeros((1, sizes[i])) for i in range(1, len(sizes))
        ]
    
    def forward_propagation(self, input):
        for weight, bias in zip(self.weights, self.biases):
            input = relu(np.dot(weight, input) + bias)
        return sigmoid(input)
    
    #def backward_propagation(self, )
    
    def compute_loss(self, a, b):
        return np.mean((a - b) ** 2)
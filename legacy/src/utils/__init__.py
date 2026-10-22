import time

def monitor(label):
    start = time.process_time()
    return lambda: print("{} : {:.4f} s".format(label, time.process_time() - start))

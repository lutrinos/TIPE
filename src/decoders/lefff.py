

def LefffDecoder(line):
    if not line.startswith('#'):
        return (line.split()[0], [])
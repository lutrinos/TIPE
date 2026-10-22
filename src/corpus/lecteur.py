
def balisage(source, cache, periode):
    i = 0
    sortie = open(cache, "w")

    sortie.flush()
    sortie.write(str(periode) + '\n')

    with open(source, "r") as f:
        while f.readline():
            if i % periode == 1:
                sortie.write(str(f.tell()) +'\n')
            i += 1

def extrait(source, balisage, debut, compte):
    cache = open(balisage, "r")
    periode = int(cache.readline())
    positions = [0] + [int(i) for i in cache.read().split()]
    arr = []
    with open(source) as f:
        i = debut // periode
        f.seek(positions[i])
        while ligne := f.readline():
            if i >= debut + compte:
                break
            if i >= debut:
                arr.append(ligne.strip())
            i += 1
    return arr

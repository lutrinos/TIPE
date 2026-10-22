
#ortho	phon	lemme	cgram	genre	nombre	freqlemfilms2	freqlemlivres	freqfilms2	freqlivres	infover	nbhomogr	nbhomoph	islem	nblettres	nbphons	cvcv	p_cvcv	voisorth	voisphon	puorth	puphon	syll	nbsyll	cv-cv	orthrenv	phonrenv	orthosyll	cgramortho	deflem	defobs	old20	pld20	morphoder	nbmorph
"""
ADJ Adjectif 
ADJ:dem Adjectif démonstratif 
ADJ:ind Adjectif indéfini 
ADJ:int Adjectif interrogatif 
ADJ:num Adjectif numérique 
ADJ:pos Adjectif possessif 
ADV Adverbe 
ART:def Article défini 
ART:inf Article indéfini 
AUX Auxiliaire 
CON Conjonction 
LIA Liaison euphonique (l') 
NOM Nom commun 
ONO Onomatopée 
PRE Préposition 
PRO:dem Pronom démonstratif 
PRO:ind Pronom indéfini 
PRO:int Pronom interrogatif 
PRO:per Pronom personnel 
PRO:pos Pronom possessif 
PRO:rel Pronom relatif 
VER Verbe
"""

categories = [
    "ADJ Adjectif",
    "ADJ:dem Adjectif démonstratif",
    "ADJ:ind Adjectif indéfini",
    "ADJ:int Adjectif interrogatif",
    "ADJ:num Adjectif numérique",
    "ADJ:pos Adjectif possessif",
    "ADV Adverbe",
    "ART:def Article défini",
    "ART:inf Article indéfini",
    "AUX Auxiliaire",
    "CON Conjonction",
    "LIA Liaison euphonique (l')",
    "NOM Nom commun",
    "ONO Onomatopée",
    "PRE Préposition",
    "PRO:dem Pronom démonstratif",
    "PRO:ind Pronom indéfini",
    "PRO:int Pronom interrogatif",
    "PRO:per Pronom personnel",
    "PRO:pos Pronom possessif",
    "PRO:rel Pronom relatif",
    "VER Verbe"
]

categories = [i.split()[0] for i in categories]

categories = {
    item:index + 1 for index, item in enumerate(categories)
}

def LexiqueDecoder(line,  index):
    if index == 0:
        return None
    
    items = line.split('\t')
    cat = items[3]

    if cat not in categories:
        return (items[0], bytes([0]))

    return (items[0], bytes([categories[items[3]]]))
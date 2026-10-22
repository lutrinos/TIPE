/**
 * Tout a été codé et commenté à la main ;)
 */

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

/**
 * Structure : arete
 * -
 * Arête d'un hypergraphe
 * 
 * cardinal : cardinal de l'arête
 * sommets : tableau des sommets de l'arête
 */
typedef struct arete {
    int cardinal;
    int* sommets;
} arete;

/**
 * Structure : hypergraphe
 * -
 * Hypergraphe
 * 
 * ordre : ordre de l'hypergraphe (nombre de sommets)
 * nb_aretes : nombre d'arêtes
 * aretes :  tableau des pointeurs des arêtes
 */
typedef struct hyper {
    int ordre;
    int nb_aretes;
    arete** aretes;
} hyper;

/**
 * Fonction : creer_arete
 * -
 * Crée une arête et renvoie le pointeur
 * 
 * cardinal : le cardinal de l'arête
 */
arete* creer_arete(int cardinal) {
    arete* a = malloc(sizeof(arete));
    
    a->cardinal = cardinal;
    a->sommets = calloc(cardinal, sizeof(int));

    return a;
}

/**
 * Fonction : liberer_arete
 * -
 * Libère une arête de la mémoire.
 * 
 * a : arête à libérer
 */
void liberer_arete(arete* a) {
    free(a->sommets);
    free(a);
}

/**
 * Fonction : copier_arete
 * -
 * Copie une arête.
 * 
 * a : arête à copier
 */
arete* copier_arete(arete* a) {
    arete* b = creer_arete(a->cardinal);

    for (int i = 0; i < a->cardinal; i++) {
        b->sommets[i] = a->sommets[i];
    }

    return b;
}

/**
 * Fonction : augmenter_arete
 * -
 * Ajoute un sommet à une arête. On fait l'hypothèse que le sommet n'est pas encore présent dans le tableau.
 * 
 * a : arête à laquelle un sommet doit être ajouté
 * sommet : numéro du sommet à ajouter
 */
void augmenter_arete(arete* a, int sommet) {
    a->cardinal++;
    a->sommets = realloc(a->sommets, a->cardinal * sizeof(int));
    a->sommets[a->cardinal - 1] = sommet;
}

/**
 * Fonction : reduire_arete
 * -
 * Enlève un sommet d'une arête. On fait l'hypothèse que le sommet n'apparait qu'une fois dans le tableau.
 * 
 * a : arête dont il faut enlever un sommet
 * sommet : sommet à retirer de l'arête
 */
void reduire_arete(arete* a, int sommet) {
    for (int i = 0; i < a->cardinal; i++) {
        if (a->sommets[i] == sommet) {

            for (; i < a->cardinal - 1; i++) a->sommets[i] = a->sommets[i + 1];
            a->cardinal--;
            a->sommets = realloc(a->sommets, a->cardinal);
            break;
        }
    }
}

/**
 * Fonction : dans_arete
 * -
 * Vérifie si un sommet est dans l'arete
 * 
 * arete : arête dont il est question
 * sommet : sommet dont on veut vérifier l'appartenance
 */
bool dans_arete(arete* a, int sommet) {
    for (int i = 0; i < a->cardinal; i++) {
        if (a->sommets[i] == sommet) {
            return true;
        }
    }
    return false;
}

/**
 * Fonction : creer_hyper
 * -
 * Crée un hypergraphe et renvoie le pointeur
 * 
 * ordre : ordre de l'hypergraphe (les sommets sont numérotés de 0 à (cardinal - 1))
 * strict : booléen indiquant si l'hypergraphe doit être valide, i.e. crée une arête pour chaque sommet
 */
hyper* creer_hyper(int ordre, bool strict) {
    hyper* h = malloc(sizeof(hyper));

    h->ordre = ordre;

    if (strict) {
        h->nb_aretes = ordre;
        h->aretes = malloc(ordre * sizeof(arete*));

        for (int i = 0; i < ordre; i++) {
            h->aretes[i] = creer_arete(1);
            h->aretes[i]->sommets[0] = i;
        }
    } else {
        h->nb_aretes = 0;
        h->aretes = malloc(0);
    }

    return h;
}

/**
 * Fonction : est_valide
 * -
 * Vérifie qu'une structure `hyper` est un hypergraphe valide
 * 
 * h : hypergraphe à vérifier
 */
bool est_valide(hyper* h) {
    bool* sommets = calloc(h->ordre, sizeof(bool));

    for (int i = 0; i < h->nb_aretes; i++) {

        if (h->aretes[i]->cardinal == 0) {
            free(sommets);
            return false;
        }

        for (int j = 0; j < h->aretes[i]->cardinal; j++) {
            sommets[h->aretes[i]->sommets[j]] = true;
        }
    }

    for (int i = 0; i < h->ordre; i++) {
        if (sommets[i] == false) {
            free(sommets);
            return false;
        }
    }

    free(sommets);
    return true;
}

/**
 * Fonction : ajouter_arete
 * -
 * Ajoute une arête à l'hypergraphe. On fait l'hypothèse qu'il ne contient pas de sommets étrangers à l'hypergraphe.
 * 
 * h : hypergraphe
 * a : arête
 */
void ajouter_arete(hyper* h, arete* a) {
    h->nb_aretes++;
    h->aretes = realloc(h->aretes, h->nb_aretes * sizeof(arete*));
    h->aretes[h->nb_aretes - 1] = a;
}

/**
 * Fonction : enlever_arete
 * -
 * Retire une arête à l'hypergraphe. On fait l'hypothèse que l'indice est correct.
 * 
 * h : hypergraphe
 * indice : indice de l'arête dans le tableau
 */
void enlever_arete(hyper* h, int indice) {
    h->nb_aretes--;
    liberer_arete(h->aretes[indice]);
    for (int i = indice; i < h->nb_aretes; i++) {
        h->aretes[i] = h->aretes[i + 1];
    }
    h->aretes = realloc(h->aretes, h->nb_aretes * sizeof(arete*));
}

/**
 * Fonction : afficher
 * -
 * Afficher les statistiques d'un hypergraphe.
 * 
 * h : hypergraphe
 * aretes : booléen indiquant s'il  faut afficher les sommets des arêtes
 */
void afficher(hyper* h, bool aretes) {
    printf("Ordre : %d / Nombre d'arêtes : %d\n", h->ordre, h->nb_aretes);

    if (!aretes) {
        return;
    }

    for (int i = 0; i < h->nb_aretes; i++) {
        printf(" - ");
        for (int j = 0; j < h->aretes[i]->cardinal - 1; j++) {
            printf("%d, ", h->aretes[i]->sommets[j]);
        }
        printf("%d\n", h->aretes[i]->sommets[h->aretes[i]->cardinal - 1]);
    }
}
#include "hyper.h"
#include <stdlib.h>
#include <string.h>

// ==================== Arete Implementation ====================

Arete* arete_create() {
    Arete *a = malloc(sizeof(Arete));
    a->field = 0;
    a->cardinal = 0;
    a->indice = -1;
    return a;
}

Arete* arete_copy(Arete *a) {
    Arete *copy = malloc(sizeof(Arete));
    copy->field = a->field;
    copy->cardinal = a->cardinal;
    copy->indice = a->indice;
    return copy;
}

void arete_free(Arete *a) {
    free(a);
}

void arete_augmenter(Arete *a, int *sommets, size_t count) {
    for (size_t i = 0; i < count; i++) {
        if (!arete_contains(a, sommets[i])) {
            a->field |= 1 << sommets[i];
            a->cardinal++;
        }
    }
}

void arete_reduire(Arete *a, int sommet) {
    if (arete_contains(a, sommet)) {
        a->field &= ~(1 << sommet);
        a->cardinal--;
    }
}

bool arete_contains(Arete *a, int sommet) {
    return (a->field & (1 << sommet)) != 0;
}

bool arete_dans(Arete *a, Arete *b) {
    return (a->field | b->field) == b->field;
}

int* arete_sommets(Arete *a, size_t *out_count) {
    int *sommets = malloc(a->cardinal * sizeof(int));
    int count = 0;
    unsigned int field = a->field;

    int i = 0;
    while (field != 0) {
        if (field & 1) {
            sommets[count++] = i;
        }
        i++;
        field >>= 1;
    }

    *out_count = count;
    return sommets;
}

// ==================== Hyper Implementation ====================

Hyper* hyper_create(int ordre) {
    Hyper *h = malloc(sizeof(Hyper));
    h->ordre = ordre;
    h->aretes = malloc(10 * sizeof(Arete*));
    h->aretes_count = 0;
    return h;
}

void hyper_free(Hyper *h) {
    for (size_t i = 0; i < h->aretes_count; i++) {
        arete_free(h->aretes[i]);
    }
    free(h->aretes);
    free(h);
}

void hyper_ajouter_arete(Hyper *h, Arete *a) {
    if (h->aretes_count >= 10) {
        h->aretes = realloc(h->aretes, (h->aretes_count + 10) * sizeof(Arete*));
    }
    a->indice = h->aretes_count;
    h->aretes[h->aretes_count] = a;
    h->aretes_count++;
}

void hyper_enlever_arete(Hyper *h, size_t indice) {
    if (indice < h->aretes_count) {
        arete_free(h->aretes[indice]);
        for (size_t i = indice; i < h->aretes_count - 1; i++) {
            h->aretes[i] = h->aretes[i + 1];
            h->aretes[i]->indice = i;
        }
        h->aretes_count--;
    }
}

int hyper_nb_aretes(Hyper *h) {
    return h->aretes_count;
}

int hyper_decompte(Hyper *h, int sommet) {
    int count = 0;
    for (size_t i = 0; i < h->aretes_count; i++) {
        if (arete_contains(h->aretes[i], sommet)) {
            count++;
        }
    }
    return count;
}

void hyper_retirer_sommet(Hyper *h, int sommet) {
    for (size_t i = 0; i < h->aretes_count; i++) {
        arete_reduire(h->aretes[i], sommet);
    }
}

Hyper* hyper_copy(Hyper *h) {
    Hyper *copy = hyper_create(h->ordre);
    for (size_t i = 0; i < h->aretes_count; i++) {
        Arete *a = arete_copy(h->aretes[i]);
        hyper_ajouter_arete(copy, a);
    }
    return copy;
}

bool hyper_est_valide(Hyper *h) {
    // Check if any edge has cardinal 0
    for (size_t i = 0; i < h->aretes_count; i++) {
        if (h->aretes[i]->cardinal == 0) return false;
    }

    // Check if all vertices 0..ordre-1 appear in at least one edge
    unsigned int couvert = 0;
    for (size_t i = 0; i < h->aretes_count; i++) {
        couvert |= h->aretes[i]->field;
    }

    while (couvert != 0) {
        if ((couvert & 1) == 0) return false;
        couvert >>= 1;
    }

    return true;
}

bool hyper_est_acyclique(Hyper *h) {
    Hyper *copy = hyper_copy(h);

    // Initialize remaining vertices
    bool *restant = malloc(h->ordre * sizeof(bool));
    for (int i = 0; i < h->ordre; i++) {
        restant[i] = true;
    }

    // Initialize vertex counts
    int *sommets_compte = malloc(h->ordre * sizeof(int));
    for (int i = 0; i < h->ordre; i++) {
        sommets_compte[i] = hyper_decompte(copy, i);
    }

    int *retirer = malloc(h->ordre * sizeof(int));

    while (true) {
        bool sortir = true;

        // Remove vertices in <= 1 edge
        int retirer_count = 0;
        for (int s = 0; s < h->ordre; s++) {
            if (restant[s] && sommets_compte[s] <= 1) {
                retirer[retirer_count++] = s;
                sortir = false;
            }
        }
        for (int i = 0; i < retirer_count; i++) {
            int s = retirer[i];
            restant[s] = false;
            hyper_retirer_sommet(copy, s);
        }

        // Remove edges contained in other edges
        for (size_t indice = 0; indice < copy->aretes_count; indice++) {
            if (copy->aretes[indice]->cardinal > 0) {
                for (size_t j = 0; j < copy->aretes_count; j++) {
                    Arete *a = copy->aretes[indice];
                    Arete *b = copy->aretes[j];
                    if (arete_dans(a, b) && a->indice != b->indice) {
                        size_t som_count = 0;
                        int *sommets = arete_sommets(a, &som_count);
                        for (size_t k = 0; k < som_count; k++) {
                            sommets_compte[sommets[k]]--;
                        }
                        free(sommets);
                        hyper_enlever_arete(copy, indice);
                        sortir = false;
                        break;
                    }
                }
            }
        }

        if (sortir || copy->aretes_count == 0) break;
    }

    bool acyclic = true;
    for (int i = 0; i < h->ordre; i++) {
        if (restant[i]) {
            acyclic = false;
            break;
        }
    }

    hyper_free(copy);
    free(restant);
    free(sommets_compte);
    free(retirer);

    return acyclic;
}

int** hyper_arbre_jointure(Hyper *h, size_t *out_rows) {
    // Initialize tree as adjacency list
    int **arbre = malloc(h->aretes_count * sizeof(int*));
    int *arbre_counts = malloc(h->aretes_count * sizeof(int));
    for (size_t i = 0; i < h->aretes_count; i++) {
        arbre[i] = malloc(h->aretes_count * sizeof(int));
        arbre_counts[i] = 0;
    }

    Hyper *copy = hyper_copy(h);

    // Initialize remaining vertices
    bool *restant = malloc(h->ordre * sizeof(bool));
    for (int i = 0; i < h->ordre; i++) {
        restant[i] = true;
    }

    // Initialize vertex counts
    int *sommets_compte = malloc(h->ordre * sizeof(int));
    for (int i = 0; i < h->ordre; i++) {
        sommets_compte[i] = hyper_decompte(copy, i);
    }

    int *retirer = malloc(h->ordre * sizeof(int));

    while (true) {
        bool sortir = true;

        // Remove vertices in <= 1 edge
        int retirer_count = 0;
        for (int s = 0; s < h->ordre; s++) {
            if (restant[s] && sommets_compte[s] <= 1) {
                retirer[retirer_count++] = s;
                sortir = false;
            }
        }
        for (int i = 0; i < retirer_count; i++) {
            int s = retirer[i];
            restant[s] = false;
            hyper_retirer_sommet(copy, s);
        }

        // Remove edges contained in other edges
        for (size_t indice = 0; indice < copy->aretes_count; indice++) {
            if (copy->aretes[indice]->cardinal > 0) {
                for (size_t j = 0; j < copy->aretes_count; j++) {
                    Arete *a = copy->aretes[indice];
                    Arete *b = copy->aretes[j];
                    if (arete_dans(a, b) && a->indice != b->indice) {
                        arbre[a->indice][arbre_counts[a->indice]++] = b->indice;
                        arbre[b->indice][arbre_counts[b->indice]++] = a->indice;
                        size_t som_count = 0;
                        int *sommets = arete_sommets(a, &som_count);
                        for (size_t k = 0; k < som_count; k++) {
                            sommets_compte[sommets[k]]--;
                        }
                        free(sommets);
                        hyper_enlever_arete(copy, indice);
                        sortir = false;
                        break;
                    }
                }
            }
        }

        if (sortir || copy->aretes_count == 0) break;
    }

    // Check if acyclic
    bool acyclic = true;
    for (int i = 0; i < h->ordre; i++) {
        if (restant[i]) {
            acyclic = false;
            break;
        }
    }

    hyper_free(copy);
    free(restant);
    free(sommets_compte);
    free(retirer);

    // Return tree or NULL
    if (acyclic) {
        *out_rows = h->aretes_count;
        // Resize arbre to exact size needed
        int **result = malloc(h->aretes_count * sizeof(int*));
        for (size_t i = 0; i < h->aretes_count; i++) {
            result[i] = malloc((arbre_counts[i] + 1) * sizeof(int));
            for (int j = 0; j < arbre_counts[i]; j++) {
                result[i][j] = arbre[i][j];
            }
            result[i][arbre_counts[i]] = -1; // Sentinel
            free(arbre[i]);
        }
        free(arbre);
        free(arbre_counts);
        return result;
    } else {
        // Free memory and return NULL
        for (size_t i = 0; i < h->aretes_count; i++) {
            free(arbre[i]);
        }
        free(arbre);
        free(arbre_counts);
        *out_rows = 0;
        return NULL;
    }
}

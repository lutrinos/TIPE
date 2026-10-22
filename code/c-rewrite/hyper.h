#ifndef HYPER_H
#define HYPER_H

#include <stddef.h>
#include <stdbool.h>

// Edge of a hypergraph
typedef struct {
    unsigned int field;       // Bitfield of vertices
    int cardinal;             // Number of vertices
    int indice;               // Index of edge
} Arete;

Arete* arete_create();
Arete* arete_copy(Arete *a);
void arete_free(Arete *a);
void arete_augmenter(Arete *a, int *sommets, size_t count);
void arete_reduire(Arete *a, int sommet);
bool arete_contains(Arete *a, int sommet);
bool arete_dans(Arete *a, Arete *b);
int* arete_sommets(Arete *a, size_t *out_count);

// Hypergraph
typedef struct {
    Arete **aretes;
    size_t aretes_count;
    int ordre;
} Hyper;

Hyper* hyper_create(int ordre);
void hyper_free(Hyper *h);
void hyper_ajouter_arete(Hyper *h, Arete *a);
void hyper_enlever_arete(Hyper *h, size_t indice);
int hyper_nb_aretes(Hyper *h);
int hyper_decompte(Hyper *h, int sommet);
void hyper_retirer_sommet(Hyper *h, int sommet);
Hyper* hyper_copy(Hyper *h);
bool hyper_est_valide(Hyper *h);
bool hyper_est_acyclique(Hyper *h);
int** hyper_arbre_jointure(Hyper *h, size_t *out_rows);

#endif

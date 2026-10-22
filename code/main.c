#include "hyper.c"

int main() {
    hyper* h = creer_hyper(10, true);

    printf("%d\n", est_valide(h));

    augmenter_arete(h->aretes[0], 2);
    reduire_arete(h->aretes[0], 2);
    arete* a = copier_arete(h->aretes[9]);
    
    enlever_arete(h, 9);
    ajouter_arete(h, a);

    afficher(h, true);
    
    return 0;
}
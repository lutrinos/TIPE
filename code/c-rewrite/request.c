#include "request.h"
#include <stdlib.h>
#include <string.h>

// ==================== StringSet Implementation ====================

StringSet* string_set_create() {
    StringSet *set = malloc(sizeof(StringSet));
    set->items = malloc(10 * sizeof(char*));
    set->count = 0;
    set->capacity = 10;
    return set;
}

static void string_set_resize(StringSet *set) {
    if (set->count >= set->capacity) {
        set->capacity *= 2;
        set->items = realloc(set->items, set->capacity * sizeof(char*));
    }
}

void string_set_add(StringSet *set, const char *str) {
    if (string_set_contains(set, str)) return;
    string_set_resize(set);
    set->items[set->count] = malloc(strlen(str) + 1);
    strcpy(set->items[set->count], str);
    set->count++;
}

bool string_set_contains(StringSet *set, const char *str) {
    for (size_t i = 0; i < set->count; i++) {
        if (strcmp(set->items[i], str) == 0) return true;
    }
    return false;
}

void string_set_free(StringSet *set) {
    for (size_t i = 0; i < set->count; i++) {
        free(set->items[i]);
    }
    free(set->items);
    free(set);
}

StringSet* string_set_copy(StringSet *set) {
    StringSet *copy = string_set_create();
    for (size_t i = 0; i < set->count; i++) {
        string_set_add(copy, set->items[i]);
    }
    return copy;
}

StringSet* string_set_intersection(StringSet *a, StringSet *b) {
    StringSet *result = string_set_create();
    for (size_t i = 0; i < a->count; i++) {
        if (string_set_contains(b, a->items[i])) {
            string_set_add(result, a->items[i]);
        }
    }
    return result;
}

StringSet* string_set_union(StringSet *a, StringSet *b) {
    StringSet *result = string_set_copy(a);
    for (size_t i = 0; i < b->count; i++) {
        string_set_add(result, b->items[i]);
    }
    return result;
}

void string_set_discard(StringSet *set, const char *str) {
    for (size_t i = 0; i < set->count; i++) {
        if (strcmp(set->items[i], str) == 0) {
            free(set->items[i]);
            for (size_t j = i; j < set->count - 1; j++) {
                set->items[j] = set->items[j + 1];
            }
            set->count--;
            return;
        }
    }
}

// ==================== Atom Implementation ====================

Atom* atom_create(const char *name, const char **variables, size_t count) {
    Atom *atom = malloc(sizeof(Atom));
    atom->name = malloc(strlen(name) + 1);
    strcpy(atom->name, name);

    atom->original = malloc(count * sizeof(char*));
    atom->original_count = count;
    for (size_t i = 0; i < count; i++) {
        atom->original[i] = malloc(strlen(variables[i]) + 1);
        strcpy(atom->original[i], variables[i]);
    }

    atom->variables = string_set_create();
    for (size_t i = 0; i < count; i++) {
        if (strcmp(variables[i], "_") != 0) {
            string_set_add(atom->variables, variables[i]);
        }
    }

    atom->index = -1;
    return atom;
}

void atom_free(Atom *atom) {
    free(atom->name);
    for (size_t i = 0; i < atom->original_count; i++) {
        free(atom->original[i]);
    }
    free(atom->original);
    string_set_free(atom->variables);
    free(atom);
}

// ==================== Head Implementation ====================

Head* head_create(const char *name, const char **variables, size_t count) {
    Head *head = malloc(sizeof(Head));
    head->name = malloc(strlen(name) + 1);
    strcpy(head->name, name);

    head->variables = malloc(count * sizeof(char*));
    head->variables_count = count;
    for (size_t i = 0; i < count; i++) {
        head->variables[i] = malloc(strlen(variables[i]) + 1);
        strcpy(head->variables[i], variables[i]);
    }

    return head;
}

void head_free(Head *head) {
    free(head->name);
    for (size_t i = 0; i < head->variables_count; i++) {
        free(head->variables[i]);
    }
    free(head->variables);
    free(head);
}

// ==================== Query Implementation ====================

Query* query_create(Head *head, Atom **atoms, size_t atoms_count) {
    Query *query = malloc(sizeof(Query));
    query->head = head;
    query->atoms = atoms;
    query->atoms_count = atoms_count;
    query->variables = string_set_create();

    for (size_t i = 0; i < atoms_count; i++) {
        atoms[i]->index = i;
        for (size_t j = 0; j < atoms[i]->variables->count; j++) {
            string_set_add(query->variables, atoms[i]->variables->items[j]);
        }
    }

    return query;
}

void query_free(Query *query) {
    // Note: head and atoms are freed separately by caller
    string_set_free(query->variables);
    free(query);
}

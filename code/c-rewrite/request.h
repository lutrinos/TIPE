#ifndef REQUEST_H
#define REQUEST_H

#include <stddef.h>
#include <stdbool.h>

// Hash set for strings to store variables
typedef struct {
    char **items;
    size_t count;
    size_t capacity;
} StringSet;

StringSet* string_set_create();
void string_set_add(StringSet *set, const char *str);
bool string_set_contains(StringSet *set, const char *str);
void string_set_free(StringSet *set);
StringSet* string_set_copy(StringSet *set);
StringSet* string_set_intersection(StringSet *a, StringSet *b);
StringSet* string_set_union(StringSet *a, StringSet *b);
void string_set_discard(StringSet *set, const char *str);

// Atom structure (table name with variables)
typedef struct {
    char *name;                    // Table name
    StringSet *variables;          // Variables in atom (excluding '_')
    char **original;               // Original variables including '_'
    size_t original_count;
    int index;                     // Index of atom in query
} Atom;

Atom* atom_create(const char *name, const char **variables, size_t count);
void atom_free(Atom *atom);

// Head structure
typedef struct {
    char *name;
    char **variables;
    size_t variables_count;
} Head;

Head* head_create(const char *name, const char **variables, size_t count);
void head_free(Head *head);

// Query structure
typedef struct {
    Head *head;
    Atom **atoms;
    size_t atoms_count;
    StringSet *variables;
} Query;

Query* query_create(Head *head, Atom **atoms, size_t atoms_count);
void query_free(Query *query);

#endif

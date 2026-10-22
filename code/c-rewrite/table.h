#ifndef TABLE_H
#define TABLE_H

#include <stddef.h>
#include <stdbool.h>

// Tuple is a list of strings
typedef struct {
    char **values;
    size_t count;
} Tuple;

Tuple* tuple_create(char **values, size_t count);
Tuple* tuple_create_from_indices(Tuple *source, int *indices, size_t count);
Tuple* tuple_copy(Tuple *tuple);
void tuple_free(Tuple *tuple);
int tuple_compare(Tuple *a, Tuple *b);

// Hash set for tuples
typedef struct {
    Tuple **items;
    size_t count;
    size_t capacity;
} TupleSet;

TupleSet* tuple_set_create();
void tuple_set_add(TupleSet *set, Tuple *tuple);
bool tuple_set_contains(TupleSet *set, Tuple *tuple);
void tuple_set_free(TupleSet *set);
Tuple** tuple_set_to_array(TupleSet *set, size_t *out_count);

// Table structure
typedef struct {
    char *name;
    Tuple **rows;
    size_t rows_count;
    char **columns;
    size_t columns_count;
} Table;

Table* table_create(const char *name);
void table_free(Table *table);
size_t table_len(Table *table);
void table_rename(Table *table, int index, const char *new_name);
void table_import_from_csv(Table *table, const char *path);
void table_project(Table *table, bool *selection, bool (*validate)(Tuple *));
void table_print(Table *table);

#endif

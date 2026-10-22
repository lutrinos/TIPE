#include "table.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// ==================== Tuple Implementation ====================

Tuple* tuple_create(char **values, size_t count) {
    Tuple *tuple = malloc(sizeof(Tuple));
    tuple->values = malloc(count * sizeof(char*));
    tuple->count = count;
    for (size_t i = 0; i < count; i++) {
        tuple->values[i] = malloc(strlen(values[i]) + 1);
        strcpy(tuple->values[i], values[i]);
    }
    return tuple;
}

Tuple* tuple_create_from_indices(Tuple *source, int *indices, size_t count) {
    Tuple *tuple = malloc(sizeof(Tuple));
    tuple->values = malloc(count * sizeof(char*));
    tuple->count = count;
    for (size_t i = 0; i < count; i++) {
        char *val = source->values[indices[i]];
        tuple->values[i] = malloc(strlen(val) + 1);
        strcpy(tuple->values[i], val);
    }
    return tuple;
}

Tuple* tuple_copy(Tuple *tuple) {
    return tuple_create(tuple->values, tuple->count);
}

void tuple_free(Tuple *tuple) {
    for (size_t i = 0; i < tuple->count; i++) {
        free(tuple->values[i]);
    }
    free(tuple->values);
    free(tuple);
}

int tuple_compare(Tuple *a, Tuple *b) {
    if (a->count != b->count) return a->count - b->count;
    for (size_t i = 0; i < a->count; i++) {
        int cmp = strcmp(a->values[i], b->values[i]);
        if (cmp != 0) return cmp;
    }
    return 0;
}

// ==================== TupleSet Implementation ====================

TupleSet* tuple_set_create() {
    TupleSet *set = malloc(sizeof(TupleSet));
    set->items = malloc(10 * sizeof(Tuple*));
    set->count = 0;
    set->capacity = 10;
    return set;
}

static void tuple_set_resize(TupleSet *set) {
    if (set->count >= set->capacity) {
        set->capacity *= 2;
        set->items = realloc(set->items, set->capacity * sizeof(Tuple*));
    }
}

void tuple_set_add(TupleSet *set, Tuple *tuple) {
    if (tuple_set_contains(set, tuple)) {
        tuple_free(tuple);
        return;
    }
    tuple_set_resize(set);
    set->items[set->count] = tuple;
    set->count++;
}

bool tuple_set_contains(TupleSet *set, Tuple *tuple) {
    for (size_t i = 0; i < set->count; i++) {
        if (tuple_compare(set->items[i], tuple) == 0) return true;
    }
    return false;
}

void tuple_set_free(TupleSet *set) {
    for (size_t i = 0; i < set->count; i++) {
        tuple_free(set->items[i]);
    }
    free(set->items);
    free(set);
}

Tuple** tuple_set_to_array(TupleSet *set, size_t *out_count) {
    Tuple **array = malloc(set->count * sizeof(Tuple*));
    for (size_t i = 0; i < set->count; i++) {
        array[i] = tuple_copy(set->items[i]);
    }
    *out_count = set->count;
    return array;
}

// ==================== Table Implementation ====================

Table* table_create(const char *name) {
    Table *table = malloc(sizeof(Table));
    table->name = malloc(strlen(name) + 1);
    strcpy(table->name, name);
    table->rows = NULL;
    table->rows_count = 0;
    table->columns = NULL;
    table->columns_count = 0;
    return table;
}

void table_free(Table *table) {
    free(table->name);
    for (size_t i = 0; i < table->rows_count; i++) {
        tuple_free(table->rows[i]);
    }
    free(table->rows);
    for (size_t i = 0; i < table->columns_count; i++) {
        free(table->columns[i]);
    }
    free(table->columns);
    free(table);
}

size_t table_len(Table *table) {
    return table->rows_count;
}

void table_rename(Table *table, int index, const char *new_name) {
    free(table->columns[index]);
    table->columns[index] = malloc(strlen(new_name) + 1);
    strcpy(table->columns[index], new_name);
}

void table_import_from_csv(Table *table, const char *path) {
    // TODO: Implement CSV import
}

void table_project(Table *table, bool *selection, bool (*validate)(Tuple *)) {
    // Find selected column indices
    int *switch_indices = malloc(table->columns_count * sizeof(int));
    int switch_count = 0;
    for (size_t i = 0; i < table->columns_count; i++) {
        if (selection[i]) {
            switch_indices[switch_count++] = i;
        }
    }

    // Deduplicate
    TupleSet *dedup = tuple_set_create();
    for (size_t i = 0; i < table->rows_count; i++) {
        if (validate(table->rows[i])) {
            Tuple *projected = tuple_create_from_indices(table->rows[i],
                                                         switch_indices,
                                                         switch_count);
            tuple_set_add(dedup, projected);
        }
    }

    // Update rows
    for (size_t i = 0; i < table->rows_count; i++) {
        tuple_free(table->rows[i]);
    }
    free(table->rows);
    table->rows = tuple_set_to_array(dedup, &table->rows_count);
    tuple_set_free(dedup);

    // Update columns
    char **new_columns = malloc(switch_count * sizeof(char*));
    for (int i = 0; i < switch_count; i++) {
        new_columns[i] = table->columns[switch_indices[i]];
    }
    free(table->columns);
    table->columns = new_columns;
    table->columns_count = switch_count;

    free(switch_indices);
}

void table_print(Table *table) {
    printf("Labels: ");
    for (size_t i = 0; i < table->columns_count; i++) {
        printf("%s ", table->columns[i]);
    }
    printf("\n");

    for (size_t i = 0; i < table->rows_count; i++) {
        printf(" - ");
        for (size_t j = 0; j < table->rows[i]->count; j++) {
            printf("%s ", table->rows[i]->values[j]);
        }
        printf("\n");
    }
}

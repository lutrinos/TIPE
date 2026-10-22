#include "main.h"
#include "hyper.h"
#include <stdlib.h>
#include <string.h>

// ==================== StringIntMap Implementation ====================

StringIntMap* string_int_map_create() {
    StringIntMap *map = malloc(sizeof(StringIntMap));
    map->keys = malloc(10 * sizeof(char*));
    map->values = malloc(10 * sizeof(int));
    map->count = 0;
    map->capacity = 10;
    return map;
}

void string_int_map_set(StringIntMap *map, const char *key, int value) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            map->values[i] = value;
            return;
        }
    }
    if (map->count >= map->capacity) {
        map->capacity *= 2;
        map->keys = realloc(map->keys, map->capacity * sizeof(char*));
        map->values = realloc(map->values, map->capacity * sizeof(int));
    }
    map->keys[map->count] = malloc(strlen(key) + 1);
    strcpy(map->keys[map->count], key);
    map->values[map->count] = value;
    map->count++;
}

int string_int_map_get(StringIntMap *map, const char *key) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            return map->values[i];
        }
    }
    return -1; // Not found
}

bool string_int_map_has(StringIntMap *map, const char *key) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            return true;
        }
    }
    return false;
}

void string_int_map_free(StringIntMap *map) {
    for (size_t i = 0; i < map->count; i++) {
        free(map->keys[i]);
    }
    free(map->keys);
    free(map->values);
    free(map);
}

// ==================== StringTableMap Implementation ====================

StringTableMap* string_table_map_create() {
    StringTableMap *map = malloc(sizeof(StringTableMap));
    map->keys = malloc(10 * sizeof(char*));
    map->values = malloc(10 * sizeof(Table*));
    map->count = 0;
    map->capacity = 10;
    return map;
}

void string_table_map_set(StringTableMap *map, const char *key, Table *table) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            map->values[i] = table;
            return;
        }
    }
    if (map->count >= map->capacity) {
        map->capacity *= 2;
        map->keys = realloc(map->keys, map->capacity * sizeof(char*));
        map->values = realloc(map->values, map->capacity * sizeof(Table*));
    }
    map->keys[map->count] = malloc(strlen(key) + 1);
    strcpy(map->keys[map->count], key);
    map->values[map->count] = table;
    map->count++;
}

Table* string_table_map_get(StringTableMap *map, const char *key) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            return map->values[i];
        }
    }
    return NULL;
}

bool string_table_map_has(StringTableMap *map, const char *key) {
    for (size_t i = 0; i < map->count; i++) {
        if (strcmp(map->keys[i], key) == 0) {
            return true;
        }
    }
    return false;
}

void string_table_map_free(StringTableMap *map) {
    for (size_t i = 0; i < map->count; i++) {
        free(map->keys[i]);
    }
    free(map->keys);
    free(map->values);
    free(map);
}

// ==================== JoinNode Implementation ====================

JoinNode* join_node_create(Atom *atom, Table *table) {
    JoinNode *node = malloc(sizeof(JoinNode));
    node->atom = atom;
    
    // Create copy of table
    node->table = table_create(table->name);
    node->table->columns = malloc(table->columns_count * sizeof(char*));
    node->table->columns_count = table->columns_count;
    for (size_t i = 0; i < table->columns_count; i++) {
        node->table->columns[i] = malloc(strlen(table->columns[i]) + 1);
        strcpy(node->table->columns[i], table->columns[i]);
    }
    node->table->rows = table->rows;
    node->table->rows_count = table->rows_count;

    node->record = string_int_map_create();
    node->variables = string_set_create();

    node->children = malloc(10 * sizeof(JoinNode*));
    node->children = realloc(node->children, 10 * sizeof(JoinNode*));
    node->children_count = 0;
    node->root = false;

    // Initialize columns and variables based on atom
    for (size_t i = 0; i < atom->original_count; i++) {
        const char *v = atom->original[i];
        if (strcmp(v, "_") != 0) {
            string_set_add(node->variables, v);
            string_int_map_set(node->record, v, i);
            node->table->columns[i] = malloc(strlen(v) + 1);
            strcpy(node->table->columns[i], v);
        } else {
            node->table->columns[i] = malloc(2);
            strcpy(node->table->columns[i], "_");
        }
    }

    return node;
}

void join_node_free(JoinNode *node) {
    if (node == NULL) return;
    
    for (size_t i = 0; i < node->children_count; i++) {
        join_node_free(node->children[i]);
    }
    
    table_free(node->table);
    string_set_free(node->variables);
    string_int_map_free(node->record);
    free(node->children);
    free(node);
}

void join_node_push_child(JoinNode *node, JoinNode *child) {
    if (node->children_count >= 10) {
        node->children = realloc(node->children, (node->children_count + 10) * sizeof(JoinNode*));
    }
    node->children[node->children_count++] = child;
}

// Semi-join operation
void join_node_semi_join(JoinNode *node, JoinNode *other) {
    // Get intersection of variables
    StringSet *intersection = string_set_intersection(node->variables, other->variables);

    // Build index from other node
    TupleSet *index_set = tuple_set_create();
    for (size_t i = 0; i < other->table->rows_count; i++) {
        int *indices = malloc(intersection->count * sizeof(int));
        for (size_t j = 0; j < intersection->count; j++) {
            indices[j] = string_int_map_get(other->record, intersection->items[j]);
        }
        Tuple *key = tuple_create_from_indices(other->table->rows[i], indices, intersection->count);
        tuple_set_add(index_set, key);
        free(indices);
    }

    // Filter rows based on index
    bool *selection = malloc(node->table->columns_count * sizeof(bool));
    for (size_t i = 0; i < node->table->columns_count; i++) {
        selection[i] = true;
    }

    bool (*validate_func)(Tuple *) = NULL;
    // Create closure for validation - we need a different approach
    // For now, we'll filter manually
    TupleSet *filtered = tuple_set_create();
    for (size_t i = 0; i < node->table->rows_count; i++) {
        int *indices = malloc(intersection->count * sizeof(int));
        for (size_t j = 0; j < intersection->count; j++) {
            indices[j] = string_int_map_get(node->record, intersection->items[j]);
        }
        Tuple *key = tuple_create_from_indices(node->table->rows[i], indices, intersection->count);
        
        if (tuple_set_contains(index_set, key)) {
            tuple_set_add(filtered, tuple_copy(node->table->rows[i]));
        }
        tuple_free(key);
        free(indices);
    }

    // Update node table
    for (size_t i = 0; i < node->table->rows_count; i++) {
        tuple_free(node->table->rows[i]);
    }
    free(node->table->rows);
    node->table->rows = tuple_set_to_array(filtered, &node->table->rows_count);
    tuple_set_free(filtered);
    tuple_set_free(index_set);
    free(selection);

    // Update record mapping
    for (size_t i = 0; i < node->table->columns_count; i++) {
        if (string_int_map_has(node->record, node->table->columns[i])) {
            string_int_map_set(node->record, node->table->columns[i], i);
        }
    }

    string_set_free(intersection);
}

// Full join operation
void join_node_full_join(JoinNode *node, JoinNode *other, Head *head, bool strict) {
    StringSet *intersection = string_set_intersection(node->variables, other->variables);

    // Build index from other node
    typedef struct {
        Tuple **rows;
        size_t count;
    } RowList;
    
    RowList *index = malloc(1000 * sizeof(RowList));
    for (int i = 0; i < 1000; i++) {
        index[i].rows = malloc(10 * sizeof(Tuple*));
        index[i].count = 0;
    }

    for (size_t i = 0; i < other->table->rows_count; i++) {
        int *indices = malloc(intersection->count * sizeof(int));
        for (size_t j = 0; j < intersection->count; j++) {
            indices[j] = string_int_map_get(other->record, intersection->items[j]);
        }
        Tuple *key = tuple_create_from_indices(other->table->rows[i], indices, intersection->count);
        int hash = 0;
        for (size_t j = 0; j < key->count; j++) {
            hash = (hash * 31 + (int)key->values[j][0]) % 1000;
        }
        
        RowList *list = &index[hash];
        if (list->count >= 10) {
            list->rows = realloc(list->rows, (list->count + 10) * sizeof(Tuple*));
        }
        list->rows[list->count++] = other->table->rows[i];
        tuple_free(key);
        free(indices);
    }

    // Build selection for columns
    StringSet *variables;
    if (strict) {
        variables = string_set_copy(node->variables);
        for (size_t i = 0; i < head->variables_count; i++) {
            string_set_add(variables, head->variables[i]);
        }
    } else {
        variables = string_set_union(node->variables, other->variables);
    }

    char **columns = malloc(variables->count * sizeof(char*));
    bool *selection = malloc(variables->count * sizeof(bool));
    int *sel_indices = malloc(variables->count * sizeof(int));
    size_t col_count = 0;

    for (size_t i = 0; i < variables->count; i++) {
        bool in_node = string_set_contains(node->variables, variables->items[i]);
        bool in_other = string_set_contains(other->variables, variables->items[i]);
        
        if (in_node || in_other) {
            columns[col_count] = variables->items[i];
            selection[col_count] = in_node;
            sel_indices[col_count] = in_node ?
                string_int_map_get(node->record, variables->items[i]) :
                string_int_map_get(other->record, variables->items[i]);
            col_count++;
        }
    }

    // Perform join
    Tuple **result = malloc(node->table->rows_count * other->table->rows_count * sizeof(Tuple*));
    size_t result_count = 0;

    for (size_t i = 0; i < node->table->rows_count; i++) {
        Tuple *row = node->table->rows[i];
        int *indices = malloc(intersection->count * sizeof(int));
        for (size_t j = 0; j < intersection->count; j++) {
            indices[j] = string_int_map_get(node->record, intersection->items[j]);
        }
        Tuple *key = tuple_create_from_indices(row, indices, intersection->count);
        
        int hash = 0;
        for (size_t j = 0; j < key->count; j++) {
            hash = (hash * 31 + (int)key->values[j][0]) % 1000;
        }

        RowList *matching = &index[hash];
        for (size_t j = 0; j < matching->count; j++) {
            Tuple *row2 = matching->rows[j];
            
            // Patch rows
            Tuple *joined = malloc(sizeof(Tuple));
            joined->values = malloc(col_count * sizeof(char*));
            joined->count = col_count;
            
            for (size_t k = 0; k < col_count; k++) {
                if (selection[k]) {
                    joined->values[k] = row->values[sel_indices[k]];
                } else {
                    joined->values[k] = row2->values[sel_indices[k]];
                }
            }
            
            result[result_count++] = joined;
        }
        
        tuple_free(key);
        free(indices);
    }

    // Update node
    for (size_t i = 0; i < node->table->rows_count; i++) {
        tuple_free(node->table->rows[i]);
    }
    free(node->table->rows);
    node->table->rows = result;
    node->table->rows_count = result_count;

    // Update columns
    for (size_t i = 0; i < node->table->columns_count; i++) {
        free(node->table->columns[i]);
    }
    free(node->table->columns);
    node->table->columns = columns;
    node->table->columns_count = col_count;

    // Update record
    string_int_map_free(node->record);
    node->record = string_int_map_create();
    for (size_t i = 0; i < col_count; i++) {
        string_int_map_set(node->record, columns[i], i);
    }

    // Update variables
    string_set_free(node->variables);
    node->variables = variables;

    // Cleanup
    for (int i = 0; i < 1000; i++) {
        free(index[i].rows);
    }
    free(index);
    free(selection);
    free(sel_indices);
    string_set_free(intersection);
}

void join_node_compute(JoinNode *node, Head *head) {
    for (size_t i = 0; i < node->children_count; i++) {
        join_node_compute(node->children[i], head);
        bool strict = node->root && i == node->children_count - 1;
        join_node_full_join(node, node->children[i], head, strict);
    }
}

// ==================== Instance Implementation ====================

Instance* instance_create() {
    Instance *instance = malloc(sizeof(Instance));
    instance->tables = string_table_map_create();
    return instance;
}

void instance_free(Instance *instance) {
    string_table_map_free(instance->tables);
    free(instance);
}

void instance_add_table(Instance *instance, Table *table) {
    string_table_map_set(instance->tables, table->name, table);
}

JoinNode* instance_join_dfs(Instance *instance, Query *query, int **tree,
                             bool *seen, int i) {
    seen[i] = true;
    JoinNode *jointure = join_node_create(query->atoms[i], string_table_map_get(instance->tables, query->atoms[i]->name));

    for (int j = 0; tree[i][j] != -1; j++) {
        if (!seen[tree[i][j]]) {
            join_node_push_child(jointure, instance_join_dfs(instance, query, tree, seen, tree[i][j]));
        }
    }

    return jointure;
}

JoinNode* instance_jointure(Instance *instance, Query *query) {
    Hyper *hyper = hyper_create(query->variables->count);

    StringIntMap *record = string_int_map_create();
    for (size_t i = 0; i < query->variables->count; i++) {
        string_int_map_set(record, query->variables->items[i], i);
    }

    for (size_t i = 0; i < query->atoms_count; i++) {
        Arete *arete = arete_create();
        int *atom_indices = malloc(query->atoms[i]->variables->count * sizeof(int));
        for (size_t j = 0; j < query->atoms[i]->variables->count; j++) {
            const char *v = query->atoms[i]->variables->items[j];
            atom_indices[j] = string_int_map_get(record, v);
        }
        arete_augmenter(arete, atom_indices, query->atoms[i]->variables->count);
        free(atom_indices);
        hyper_ajouter_arete(hyper, arete);
    }

    size_t tree_size = 0;
    int **tree = hyper_arbre_jointure(hyper, &tree_size);

    if (tree == NULL) {
        // Error: non-acyclic query
        hyper_free(hyper);
        string_int_map_free(record);
        return NULL;
    }

    bool *seen = malloc(query->atoms_count * sizeof(bool));
    for (size_t i = 0; i < query->atoms_count; i++) {
        seen[i] = false;
    }

    JoinNode *result = instance_join_dfs(instance, query, tree, seen, 0);

    free(seen);
    for (size_t i = 0; i < tree_size; i++) {
        free(tree[i]);
    }
    free(tree);
    hyper_free(hyper);
    string_int_map_free(record);

    return result;
}

void instance_bottom_up(Instance *instance, Query *query, JoinNode *node) {
    for (size_t i = 0; i < node->children_count; i++) {
        instance_bottom_up(instance, query, node->children[i]);

        StringSet *variables = string_set_intersection(node->variables, node->children[i]->variables);
        if (variables->count > 0) {
            join_node_semi_join(node->children[i], node);
        }
        string_set_free(variables);
    }
}

void instance_top_down(Instance *instance, Query *query, JoinNode *node) {
    for (size_t i = 0; i < node->children_count; i++) {
        StringSet *variables = string_set_intersection(node->variables, node->children[i]->variables);
        
        if (variables->count > 0) {
            join_node_semi_join(node, node->children[i]);
        }
        string_set_free(variables);
        
        instance_top_down(instance, query, node->children[i]);
    }
}

Table* instance_query(Instance *instance, Query *query) {
    // Verify query
    for (size_t i = 0; i < query->atoms_count; i++) {
        if (!string_table_map_has(instance->tables, query->atoms[i]->name)) {
            return NULL;
        }
        Table *table = string_table_map_get(instance->tables, query->atoms[i]->name);
        if (query->atoms[i]->original_count != table->columns_count) {
            return NULL;
        }
    }

    // Build join tree
    JoinNode *jointree = instance_jointure(instance, query);
    if (jointree == NULL) return NULL;

    jointree->root = true;

    // Bottom-up pass
    instance_bottom_up(instance, query, jointree);

    // Top-down pass
    instance_top_down(instance, query, jointree);

    // Compute join
    join_node_compute(jointree, query->head);

    Table *result = jointree->table;
    free(jointree);

    return result;
}

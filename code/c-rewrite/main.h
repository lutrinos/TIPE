#ifndef MAIN_H
#define MAIN_H

#include "request.h"
#include "table.h"
#include <stddef.h>

// Dictionary for string -> int mapping (record/index)
typedef struct {
    char **keys;
    int *values;
    size_t count;
    size_t capacity;
} StringIntMap;

StringIntMap* string_int_map_create();
void string_int_map_set(StringIntMap *map, const char *key, int value);
int string_int_map_get(StringIntMap *map, const char *key);
bool string_int_map_has(StringIntMap *map, const char *key);
void string_int_map_free(StringIntMap *map);

// Dictionary for string -> Table mapping
typedef struct {
    char **keys;
    Table **values;
    size_t count;
    size_t capacity;
} StringTableMap;

StringTableMap* string_table_map_create();
void string_table_map_set(StringTableMap *map, const char *key, Table *table);
Table* string_table_map_get(StringTableMap *map, const char *key);
bool string_table_map_has(StringTableMap *map, const char *key);
void string_table_map_free(StringTableMap *map);

// Join tree node
typedef struct JoinNode {
    Atom *atom;                    // Atom of the node
    Table *table;                  // Table corresponding to atom
    StringIntMap *record;          // Mapping of variables to column indices
    StringSet *variables;          // Relevant variables of node
    struct JoinNode **children;    // Children in join tree
    size_t children_count;
    bool root;                     // Is root flag
} JoinNode;

JoinNode* join_node_create(Atom *atom, Table *table);
void join_node_free(JoinNode *node);
void join_node_push_child(JoinNode *node, JoinNode *child);
void join_node_semi_join(JoinNode *node, JoinNode *other);
void join_node_full_join(JoinNode *node, JoinNode *other, Head *head, bool strict);
void join_node_patch_rows(JoinNode *node, Tuple *row_a, Tuple *row_b,
                          bool *selection, int *indices, size_t selection_count,
                          Tuple **out);
void join_node_compute(JoinNode *node, Head *head);

// Database instance
typedef struct {
    StringTableMap *tables;
} Instance;

Instance* instance_create();
void instance_free(Instance *instance);
void instance_add_table(Instance *instance, Table *table);
JoinNode* instance_join_dfs(Instance *instance, Query *query, int **tree,
                             bool *seen, int i);
JoinNode* instance_jointure(Instance *instance, Query *query);
void instance_bottom_up(Instance *instance, Query *query, JoinNode *node);
void instance_top_down(Instance *instance, Query *query, JoinNode *node);
Table* instance_query(Instance *instance, Query *query);

#endif

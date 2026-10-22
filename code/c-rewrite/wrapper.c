#include "wrapper.h"
#include "main.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

// Timing utilities
static double get_time_ms() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1000000.0;
}

// ==================== DatabaseHandle Implementation ====================

DatabaseHandle db_create() {
    Instance *instance = instance_create();
    return (DatabaseHandle)instance;
}

void db_free(DatabaseHandle db) {
    Instance *instance = (Instance *)db;
    // Note: tables are freed by caller, only free the instance itself
    instance_free(instance);
}

int db_add_table_from_memory(DatabaseHandle db, const char *table_name,
                             const char **data, size_t rows, size_t cols,
                             const char **column_names) {
    Instance *instance = (Instance *)db;
    
    // Create table
    Table *table = table_create(table_name);
    
    // Set columns
    table->columns = malloc(cols * sizeof(char*));
    table->columns_count = cols;
    for (size_t i = 0; i < cols; i++) {
        table->columns[i] = malloc(strlen(column_names[i]) + 1);
        strcpy(table->columns[i], column_names[i]);
    }
    
    // Create tuples from data
    table->rows = malloc(rows * sizeof(Tuple*));
    table->rows_count = rows;
    
    for (size_t r = 0; r < rows; r++) {
        char **row_values = malloc(cols * sizeof(char*));
        for (size_t c = 0; c < cols; c++) {
            const char *value = data[r * cols + c];
            row_values[c] = malloc(strlen(value) + 1);
            strcpy(row_values[c], value);
        }
        table->rows[r] = tuple_create(row_values, cols);
        for (size_t c = 0; c < cols; c++) {
            free(row_values[c]);
        }
        free(row_values);
    }
    
    instance_add_table(instance, table);
    return 0;
}

int db_add_table_from_csv(DatabaseHandle db, const char *table_name, const char *csv_path) {
    Instance *instance = (Instance *)db;
    
    Table *table = table_create(table_name);
    table_import_from_csv(table, csv_path);
    
    if (table->rows_count == 0 && table->columns_count == 0) {
        table_free(table);
        return -1;
    }
    
    instance_add_table(instance, table);
    return 0;
}

// Parse query string: "head(X,Y) :- table1(A,B), table2(B,C)"
static Query* parse_query_string(const char *query_str, Instance *instance) {
    // Simple parser for the query format
    char *str = malloc(strlen(query_str) + 1);
    strcpy(str, query_str);
    
    // Find ":-"
    char *arrow = strstr(str, ":-");
    if (!arrow) {
        free(str);
        return NULL;
    }
    
    // Parse head
    char *head_str = str;
    *arrow = '\0';
    char *body_str = arrow + 2;
    
    // Extract head name and variables
    char *head_paren = strchr(head_str, '(');
    if (!head_paren) {
        free(str);
        return NULL;
    }
    
    int head_name_len = head_paren - head_str;
    char *head_name = malloc(head_name_len + 1);
    strncpy(head_name, head_str, head_name_len);
    head_name[head_name_len] = '\0';
    
    // Remove whitespace
    for (int i = head_name_len - 1; i >= 0 && (head_name[i] == ' ' || head_name[i] == '\t'); i--) {
        head_name[i] = '\0';
    }
    
    // Extract variables
    char *head_vars_str = head_paren + 1;
    char *head_close = strchr(head_vars_str, ')');
    if (!head_close) {
        free(head_name);
        free(str);
        return NULL;
    }
    
    int head_vars_len = head_close - head_vars_str;
    char *head_vars_copy = malloc(head_vars_len + 1);
    strncpy(head_vars_copy, head_vars_str, head_vars_len);
    head_vars_copy[head_vars_len] = '\0';
    
    // Split head variables
    char **head_vars = malloc(100 * sizeof(char*));
    size_t head_vars_count = 0;
    char *token = strtok(head_vars_copy, ",");
    while (token && head_vars_count < 100) {
        // Trim whitespace
        while (*token == ' ' || *token == '\t') token++;
        int len = strlen(token);
        while (len > 0 && (token[len-1] == ' ' || token[len-1] == '\t')) len--;
        
        head_vars[head_vars_count] = malloc(len + 1);
        strncpy(head_vars[head_vars_count], token, len);
        head_vars[head_vars_count][len] = '\0';
        head_vars_count++;
        token = strtok(NULL, ",");
    }
    free(head_vars_copy);
    
    Head *head = head_create(head_name, (const char**)head_vars, head_vars_count);
    
    // Parse body atoms
    Atom **atoms = malloc(100 * sizeof(Atom*));
    size_t atoms_count = 0;
    
    char *body_copy = malloc(strlen(body_str) + 1);
    strcpy(body_copy, body_str);
    
    char *atom_str = strtok(body_copy, ",");
    while (atom_str && atoms_count < 100) {
        // Trim whitespace
        while (*atom_str == ' ' || *atom_str == '\t') atom_str++;
        
        char *atom_paren = strchr(atom_str, '(');
        if (atom_paren) {
            int atom_name_len = atom_paren - atom_str;
            char *atom_name = malloc(atom_name_len + 1);
            strncpy(atom_name, atom_str, atom_name_len);
            atom_name[atom_name_len] = '\0';
            
            char *atom_vars_str = atom_paren + 1;
            char *atom_close = strchr(atom_vars_str, ')');
            if (atom_close) {
                int atom_vars_len = atom_close - atom_vars_str;
                char *atom_vars_copy = malloc(atom_vars_len + 1);
                strncpy(atom_vars_copy, atom_vars_str, atom_vars_len);
                atom_vars_copy[atom_vars_len] = '\0';
                
                char **atom_vars = malloc(100 * sizeof(char*));
                size_t atom_vars_count = 0;
                char *var_token = strtok(atom_vars_copy, ",");
                while (var_token && atom_vars_count < 100) {
                    while (*var_token == ' ' || *var_token == '\t') var_token++;
                    int var_len = strlen(var_token);
                    while (var_len > 0 && (var_token[var_len-1] == ' ' || var_token[var_len-1] == '\t')) var_len--;
                    
                    atom_vars[atom_vars_count] = malloc(var_len + 1);
                    strncpy(atom_vars[atom_vars_count], var_token, var_len);
                    atom_vars[atom_vars_count][var_len] = '\0';
                    atom_vars_count++;
                    var_token = strtok(NULL, ",");
                }
                
                atoms[atoms_count] = atom_create(atom_name, (const char**)atom_vars, atom_vars_count);
                atoms_count++;
                
                for (size_t i = 0; i < atom_vars_count; i++) {
                    free(atom_vars[i]);
                }
                free(atom_vars);
                free(atom_vars_copy);
            }
            free(atom_name);
        }
        atom_str = strtok(NULL, ",");
    }
    free(body_copy);
    
    Query *query = query_create(head, atoms, atoms_count);
    
    // Cleanup
    for (size_t i = 0; i < head_vars_count; i++) {
        free(head_vars[i]);
    }
    free(head_vars);
    free(head_name);
    free(str);
    
    return query;
}

char** db_query(DatabaseHandle db, const char *query_str,
                size_t *out_rows, size_t *out_cols) {
    QueryTimings timings;
    return db_query_with_timings(db, query_str, out_rows, out_cols, &timings);
}

char** db_query_with_timings(DatabaseHandle db, const char *query_str,
                             size_t *out_rows, size_t *out_cols,
                             QueryTimings *timings) {
    Instance *instance = (Instance *)db;
    
    double t_start = get_time_ms();
    
    Query *query = parse_query_string(query_str, instance);
    double t_parse = get_time_ms();
    
    if (!query) {
        *out_rows = 0;
        *out_cols = 0;
        return NULL;
    }
    
    Table *result = instance_query(instance, query);
    double t_compute = get_time_ms();
    
    if (!result) {
        *out_rows = 0;
        *out_cols = 0;
        return NULL;
    }
    
    // Marshal result to flat array
    size_t total_cells = result->rows_count * result->columns_count;
    char **result_data = malloc((total_cells + result->columns_count + 1) * sizeof(char*));
    
    size_t idx = 0;
    
    // Add header row
    for (size_t i = 0; i < result->columns_count; i++) {
        result_data[idx] = malloc(strlen(result->columns[i]) + 1);
        strcpy(result_data[idx], result->columns[i]);
        idx++;
    }
    
    // Add data rows
    for (size_t r = 0; r < result->rows_count; r++) {
        for (size_t c = 0; c < result->columns_count; c++) {
            const char *value = result->rows[r]->values[c];
            result_data[idx] = malloc(strlen(value) + 1);
            strcpy(result_data[idx], value);
            idx++;
        }
    }
    
    // Sentinel
    result_data[idx] = NULL;
    
    *out_rows = result->rows_count;
    *out_cols = result->columns_count;
    
    if (timings) {
        timings->parsing_time = t_parse - t_start;
        timings->computation_time = t_compute - t_parse;
        timings->total_time = t_compute - t_start;
    }
    
    // Cleanup
    table_free(result);
    query_free(query);
    
    return result_data;
}

void db_free_result(char **result) {
    if (!result) return;
    for (size_t i = 0; result[i] != NULL; i++) {
        free(result[i]);
    }
    free(result);
}

int db_batch_queries(DatabaseHandle db, const char **queries, size_t num_queries,
                     char ****results, size_t *row_counts, size_t *col_counts,
                     QueryTimings *timings) {
    Instance *instance = (Instance *)db;

    *results = malloc(num_queries * sizeof(char**));

    for (size_t i = 0; i < num_queries; i++) {
        (*results)[i] = db_query_with_timings(instance, queries[i],
                                              &row_counts[i], &col_counts[i],
                                              &timings[i]);
        if (!(*results)[i]) {
            return -1;
        }
    }

    return 0;
}

void db_batch_free_results(char ***results, size_t count) {
    for (size_t i = 0; i < count; i++) {
        db_free_result(results[i]);
    }
    free(results);
}

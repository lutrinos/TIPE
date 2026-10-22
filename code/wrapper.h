#ifndef WRAPPER_H
#define WRAPPER_H

#include <stddef.h>
#include <stdint.h>

/*
 * High-level wrapper API for minimal Python/C communication overhead
 * All operations are bulk-oriented to reduce function call count
 */

// Opaque database handle
typedef void* DatabaseHandle;

// Create a database instance
DatabaseHandle db_create();
void db_free(DatabaseHandle db);

// Add a table from CSV file
// Returns 0 on success, -1 on error
int db_add_table_from_csv(DatabaseHandle db, const char *table_name, const char *csv_path);

// Add a table from memory (bulk insert)
// data: array of strings (row-major: [row0_col0, row0_col1, ..., row1_col0, ...])
// rows: number of rows
// cols: number of columns
// column_names: array of column name strings
// Returns 0 on success, -1 on error
int db_add_table_from_memory(DatabaseHandle db, const char *table_name,
                             const char **data, size_t rows, size_t cols,
                             const char **column_names);

// Execute a query and return results
// query_str: format "head(X,Y) :- table1(A,B), table2(B,C)"
// out_rows: pointer to store result row count
// out_cols: pointer to store result column count
// Returns pointer to result data (row-major string array), NULL on error
// Caller must free with db_free_result()
char** db_query(DatabaseHandle db, const char *query_str,
                size_t *out_rows, size_t *out_cols);

// Free result from db_query
void db_free_result(char **result);

// Get timing information (in milliseconds)
typedef struct {
    double total_time;
    double parsing_time;
    double join_tree_time;
    double computation_time;
} QueryTimings;

// Execute query and get timings
char** db_query_with_timings(DatabaseHandle db, const char *query_str,
                             size_t *out_rows, size_t *out_cols,
                             QueryTimings *timings);

// Batch query execution - minimizes context switches
// queries: array of query strings
// num_queries: number of queries
// results: array of result pointers (allocated by function)
// row_counts: array of row counts for each result
// col_counts: array of column counts for each result
// timings: array of timing info for each query
// Returns 0 on success, -1 on error
int db_batch_queries(DatabaseHandle db, const char **queries, size_t num_queries,
                     char ***results, size_t *row_counts, size_t *col_counts,
                     QueryTimings *timings);

// Batch free for multiple results
void db_batch_free_results(char **results, size_t count);

#endif

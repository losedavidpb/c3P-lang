/* Object Q writer for c3P language */
#ifndef Q_WRITER_H
#define Q_WRITER_H
#include <stdio.h>

#include "../symt_type.h"

// Type for labels
typedef int qw_label_t;

/* Available operators for expressions */
typedef enum qw_op_t
{
	QW_ADD,				// add operation
	QW_SUB,				// sub operation
	QW_MULT,			// mult operation
	QW_DIV,				// div operation
	QW_POW,				// pow operation
	QW_MOD,				// mod operation
	QW_LESS,			// less operation
	QW_GREATER,			// greater operation
	QW_LESS_THAN,		// less than operation
	QW_GREATER_THAN,	// greater than operation
	QW_EQUAL,			// equal operation
	QW_NOT_EQUAL,		// not equal operation
	QW_AND,				// and operation
	QW_OR,				// or operation
	QW_NOT				// not operation
} qw_op_t;

/* Open a new file to write an object file */
FILE* qw_new(char *filename);

/* Prepare Q file with basic code */
void qw_prepare(FILE *obj);

/* Write a routine */
void qw_write_routine(FILE *obj, char *name, qw_label_t label);

/* Write the routine end */
void qw_write_close_routine(FILE *obj, char *name);

/* Write the beggining of a loop */
void qw_write_begin_loop(FILE *obj, qw_label_t label);

/* Write the last lines of a loop */
void qw_write_end_loop(FILE *obj, qw_label_t label);

/* Write a new label */
void qw_write_new_label(FILE *obj, qw_label_t label);

/* Write a new goto */
void qw_write_goto(FILE *obj, qw_label_t label);

/* Write a new condition */
void qw_write_condition(FILE *obj, qw_label_t label);

/* Write a value to a register */
void qw_write_value_to_reg(FILE *obj, qw_label_t num_reg, symt_cons_t type, symt_value_t value);

/* Write an expression for two numbers */
void qw_write_expr(FILE *obj, qw_op_t sign, symt_node *num1, symt_node *num2, qw_label_t label);

/* Close passed object file */
void qw_close(FILE * obj);

#endif	// Q_WRITER_H

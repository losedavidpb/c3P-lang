/* Object Q writer for c3P language */
#ifndef Q_WRITER_H
#define Q_WRITER_H
#include <stdio.h>
#include <stdbool.h>

#include "../symt_type.h"

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
void qw_write_routine(FILE *obj, char *name, symt_label_t label, bool is_main);

/* Write the routine end */
void qw_write_close_routine(FILE *obj, char *name, bool is_main);

/* Write the beggining of a loop */
void qw_write_begin_loop(FILE *obj, symt_label_t label);

/* Write the last lines of a loop */
void qw_write_end_loop(FILE *obj, symt_label_t label, symt_label_t next_label);

/* Write a new label */
void qw_write_new_label(FILE *obj, symt_label_t label);

/* Write a new goto */
void qw_write_goto(FILE *obj, symt_label_t label);

/* Write a call statement */
void qw_write_call(FILE *obj, symt_label_t rout_label, symt_label_t label);

/* Write a new condition */
void qw_write_condition(FILE *obj, symt_label_t label);

/* Write the declaration of an array */
int qw_write_array(FILE *obj, symt_cons_t type, int q_direction, symt_value_t value, size_t array_length);

/* Write a value at a position of an array */
void qw_write_value_to_array(FILE *obj, symt_cons_t type, int ini_q_direction, symt_value_t value, size_t pos);

/* Write a value to a variable stored at memory  */
void qw_write_value_to_var(FILE *obj, symt_cons_t type, int q_direction, symt_value_t value);

/* Write the variable's value to a register */
void qw_write_var_to_reg(FILE *obj, symt_label_t num_reg, symt_cons_t type, int q_direction);

/* Write a value to a register */
void qw_write_value_to_reg(FILE *obj, int num_reg, symt_cons_t type, symt_value_t value);

/* Write a register into a variable */
void qw_write_reg_to_var(FILE *obj, int num_reg, symt_cons_t type, int q_direction);

/* Write an expression for two numbers */
void qw_write_expr(FILE *obj, qw_op_t sign, symt_node *num1, symt_node *num2, symt_label_t label, bool no_store_expr);

/* Close passed object file */
void qw_close(FILE * obj, symt_label_t label);

#endif	// Q_WRITER_H

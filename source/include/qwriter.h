// qwriter.h -*- C -*-
//
// This file is part of the c3P language compiler. This project
// is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License
//
// This project is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// If not, see <http://www.gnu.org/licenses/>.
//

/*
 *	ISO C99 Standard: Object Q writer for c3P language
 */

#ifndef Q_WRITER_H
#define Q_WRITER_H
#include <stdio.h>
#include <stdbool.h>

#include "symt_type.h"

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

/* First direction defined for R7 */
#define QW_FIRST_DIR 0x11fe8

/* Static directions associated to the formats
   that will be used to print values of different
   types at show and showln methods */
#define QW_DIR_INT_FORMAT 0x11ffc
#define QW_DIR_DOUBLE_FORMAT 0x11ff8
#define QW_DIR_CHAR_FORMAT 0x11ff4
#define QW_DIR_INT_FORMAT_LN 0x11ff0
#define QW_DIR_DOUBLE_FORMAT_LN 0x11fec
#define QW_DIR_CHAR_FORMAT_LN 0x11fe8

/* Open a new file to write an object file */
FILE* qw_new(char *filename);

/* Prepare Q file with basic code */
void qw_prepare(FILE *obj);

/* Write a routine */
void qw_write_routine(FILE *obj, symt_name_t name, symt_natural_t label);

/* Write the routine end */
void qw_write_close_routine(FILE *obj, symt_name_t name, bool is_main);

/* Write the rotuine using size */
void qw_write_close_routine_function(
	FILE *obj, symt_name_t name, symt_natural_t size, symt_cons_t type,
	symt_natural_t q_dir, symt_natural_t offset, bool is_param
);

/* Write the beggining of a loop */
void qw_write_begin_loop(FILE *obj, symt_natural_t label, symt_natural_t q_dir);

/* Write the last lines of a loop */
void qw_write_end_loop(FILE *obj, symt_natural_t label, symt_natural_t next_label);

/* Write a new label */
void qw_write_new_label(FILE *obj, symt_natural_t label);

/* Write a new goto */
void qw_write_goto(FILE *obj, symt_natural_t label);

/* Write a call statement */
void qw_write_call(FILE *obj, symt_natural_t rout_label, symt_natural_t label);

/* Write return statement */
void qw_write_call_return(FILE *obj, symt_natural_t rout_label, symt_natural_t label, symt_natural_t size, symt_cons_t type);

/* Write a new condition */
void qw_write_condition(FILE *obj, symt_natural_t label);

/* Write show function located at base library */
void qw_write_show_value(
	FILE *obj, symt_natural_t label, symt_cons_t type, symt_natural_t offset,
	symt_natural_t q_dir, symt_value_t value, bool is_param, bool is_void, bool is_array_value, bool show_ln
);

/* Push operation for framepointer */
void qw_push_fp(FILE *obj, symt_cons_t type);

/* Pop operation for framepointer */
void qw_pop_fp(FILE *obj, symt_cons_t type);

/* Write the declaration of an array */
int qw_write_array(
	FILE *obj, symt_cons_t type, symt_natural_t q_dir, symt_natural_t array_length,
	symt_natural_t section_label, symt_natural_t offset, bool globals
);

/* Write a register to an array */
void qw_write_array_to_reg(
	FILE *obj, symt_natural_t num_reg, symt_cons_t type,
	symt_natural_t q_dir, symt_natural_t pos, symt_natural_t offset
);

/* Write a value at a position of an array */
void qw_write_reg_to_array(
	FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_natural_t q_dir,
	symt_natural_t pos, symt_natural_t offset
);

/* Write a value to a variable stored at memory  */
void qw_write_value_to_var(FILE *obj, symt_cons_t type, symt_value_t value);

/* Write the variable's value to a register */
void qw_write_var_to_reg(FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_natural_t q_dir);

/* Write the variable's value to a register using R6 */
void qw_write_var_to_reg_with_R6(FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_natural_t offset, bool is_param, bool is_void);

/* Write a value to a register */
void qw_write_value_to_reg(FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_value_t value);

/* Write a register into a variable */
void qw_write_reg_to_var(FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_natural_t q_dir);

/* Write register to a variable using R6 */
void qw_write_reg_to_var_with_R6(FILE *obj, symt_natural_t num_reg, symt_cons_t type, symt_natural_t offset, bool is_param);

/* Write an expression for two numbers */
void qw_write_expr(FILE *obj, qw_op_t sign, symt_cons_t type, symt_natural_t label);

/* Close passed object file */
void qw_close(FILE * obj, symt_natural_t label);

#endif	// Q_WRITER_H

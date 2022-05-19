#include "../../../include/qlang/qwriter.h"

#include "../../../include/assertb.h"
#include "../../../include/arrcopy.h"

FILE* qw_new(char *filename)
{
	assertp(filename != NULL, "filename must be defined");

	FILE * file = fopen(filename, "w");
	assertf(file != NULL, "internal IO error for %s", filename);

	return file;
}

void qw_prepare(FILE *obj)
{
	assertp(obj != NULL, "object must be defined");
	fprintf(obj, "#include \"../../include/qlang/Qlib.h\"\n");
	//fprintf(obj, "#include \"../../include/qlang/Q.h\"\n");
	fprintf(obj, "BEGIN");
}

void qw_write_routine(FILE *obj, char *name, int label)
{
	assertp(obj != NULL, "object must be defined");
	assertp(name != NULL, "name must be defined");
	fprintf(obj, "\nL %d: /* Routine %s */\n\tR6=R7;\n", label, name);
}

void qw_write_close_routine(FILE *obj, char *name)
{
	assertp(obj != NULL, "object must be defined");
	assertp(name != NULL, "name must be defined");
	fprintf(obj, "\n\tR7=R6;\n\tR6=P(R7+4);\n\tR5=P(R7);\n\tGT(R5); /* End Routine %s */", name);
}

void qw_write_begin_loop(FILE *obj, int label)
{
    assertp(obj != NULL, "object must be defined");
    fprintf(obj, "L %d:\tR7=R7-4;\n", label);
}

void qw_write_end_loop(FILE *obj, int label)
{
    assertp(obj != NULL, "object must be defined");
    fprintf(obj, "L %d:\tR7=R7+4;\n", label);
}

void qw_write_new_label(FILE *obj, int label)
{
    assertp(obj != NULL, "object must be defined");
    fprintf(obj, "L %d:\n", label);
}

void qw_write_goto(FILE *obj, int label)
{
    assertp(obj != NULL, "object must be defined");
    fprintf(obj, "GT(%d);\n", label);
}

void qw_write_condition(FILE *obj, int label)
{
    assertp(obj != NULL, "object must be defined");
    fprintf(obj, "IF(!R1) GT(%d);\n", label);
}

void qw_write_value_to_reg(FILE *obj, int num_reg, symt_cons_t type, symt_value_t value)
{
	assertp(obj != NULL, "object must be defined");

	int value_int;
	double value_double;

	switch(type)
	{
		case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR:
			value_int = *(int*)value;
			assertf(num_reg >= 0 && num_reg <= 7, "%d is not a valid register", num_reg);
			fprintf(obj, "\n\tR%d=%d;", num_reg, value_int);
		break;

		case CONS_DOUBLE:
			value_double = *(double*)value;
			assertf(num_reg >= 0 && num_reg <= 3, "%d is not a valid register", num_reg);
			fprintf(obj, "\n\tRR%d=%f;", num_reg, value_double);
		break;

		//case CONS_STR: break;
	}
}

void qw_write_expr(FILE *obj, qw_op_t sign, symt_node *num1, symt_node *num2, int label)
{
	assertp(obj != NULL, "object must be defined");

	if (num1 != NULL && num2 != NULL)
	{
		if(num1 != NULL) qw_write_value_to_reg(obj, 1, num1->cons->type, num1->cons->value);
		if(num2 != NULL) qw_write_value_to_reg(obj, 2, num2->cons->type, num2->cons->value);

		switch(sign)
		{
			// Comparison
			case QW_LESS: fprintf(obj, "\n\tR%d=R%d<R%d;", 1, 1, 2); 			break;
			case QW_GREATER: fprintf(obj, "\n\tR%d=R%d>R%d;", 1, 1, 2); 		break;
			case QW_LESS_THAN: fprintf(obj, "\n\tR%d=R%d<=R%d;", 1, 1, 2); 		break;
			case QW_GREATER_THAN: fprintf(obj, "\n\tR%d=R%d>=R%d;", 1, 1, 2);   break;
			case QW_EQUAL: fprintf(obj, "\n\tR%d=R%d==R%d;", 1, 1, 2); 			break;
			case QW_NOT_EQUAL: fprintf(obj, "\n\tR%d=R%d!=R%d;", 1, 1, 2); 		break;

			// Logical
			case QW_AND: fprintf(obj, "\n\tR%d=R%d!=R%d;", 1, 1, 2); 			break;
			case QW_OR: fprintf(obj, "\n\tR%d=R%d!=R%d;", 1, 1, 2); 			break;
			case QW_NOT: fprintf(obj, "\n\tR%d=R%d!=R%d;", 1, 1, 2); 			break;

			// Arithmetic
			case QW_ADD: fprintf(obj, "\n\tR%d=R%d+R%d;", 1, 1, 2); 			break;
			case QW_SUB: fprintf(obj, "\n\tR%d=R%d-R%d;", 1, 1, 2); 			break;
			case QW_MULT: fprintf(obj, "\n\tR%d=R%d*R%d;", 1, 1, 2); 			break;
			case QW_DIV: fprintf(obj, "\n\tR%d=R%d/R%d;", 1, 1, 2); 			break;
			case QW_POW: case QW_MOD:
				fprintf(obj, "\n\tR0=%d;", label);
				if (sign == QW_POW) fprintf(obj, "\n\tGT(pow_);");
				else fprintf(obj, "\n\tGT(mod_);");
				fprintf(obj, "\nL %d:", label);
			break;
		}
	}
}

void qw_close(FILE * obj)
{
	assertp(obj != NULL, "object must be defined");
	fprintf(obj, "\n\tGT(-2);\t/* Exit program */\nEND");
	fclose(obj);
}

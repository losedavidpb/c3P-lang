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
	fprintf(obj, "BEGIN\n");
	fprintf(obj, "L 0:\n\tR0=0;\n");
}

void qw_close(FILE * obj)
{
	assertp(obj != NULL, "object must be defined");
	fprintf(obj, "\tGT(-2);\nEND");
	fclose(obj);
}

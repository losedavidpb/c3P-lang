/* Object Q writer for c3P language */
#ifndef Q_WRITER_H
#define Q_WRITER_H
#include <stdio.h>

/* Open a new file to write an object file */
FILE* qw_new(char *filename);

/* Prepare Q file with basic code */
void qw_prepare(FILE *obj);

/* Close passed object file */
void qw_close(FILE * obj);

#endif	// Q_WRITER_H

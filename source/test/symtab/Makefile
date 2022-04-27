############################################################################
#                                                                          #
#                     Makefile for test for c3P symtab                     #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile and execute
# 	symbol table tests for c3P programming language.
#
# SYNTAX
#	make -s
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

symt_path = ../../compiler/symtab
lib_path = ../../compiler/symtab/lib

all:
	make -s install
	make -s execute
	make -s clean

install: $(symt_path)/symt.c $(symt_path)/symt.h $(lib_path)/memlib.h $(lib_path)/memlib.c $(lib_path)/assertb.h $(lib_path)/copy.c $(lib_path)/copy.h symt_test.c
	gcc -o symt_test.exe $(symt_path)/symt.c $(symt_path)/symt.h $(lib_path)/memlib.h $(lib_path)/memlib.c $(lib_path)/assertb.h $(lib_path)/copy.c $(lib_path)/copy.h symt_test.c

execute: symt_test.exe
	./symt_test.exe

clean:
	rm -f symt_test.exe 2>/dev/null
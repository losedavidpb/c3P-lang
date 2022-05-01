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

src_path=../../src
include_path=../../include
symt_src_path=$(src_path)/symtab

all:
	make -s install
	make -s execute
	make -s clean

install: $(symt_src_path) $(include_path)
	gcc -o symt_test.exe $(symt_src_path)/symt.c $(include_path)/*.h $(symt_src_path)/lib/*.c $(symt_src_path)/symt/*.c symt_test.c
	gcc -o copy_test.exe $(include_path)/*.h $(symt_src_path)/lib/*.c copy_test.c

execute: symt_test.exe copy_test.exe
	./copy_test.exe
	./symt_test.exe

clean:
	rm -f copy_test.exe 2>/dev/null
	rm -f symt_test.exe 2>/dev/null

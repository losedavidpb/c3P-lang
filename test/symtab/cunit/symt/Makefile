############################################################################
#                                                                          #
#                     Makefile for test for c3P symtab                     #
#                                                                          #
############################################################################

src_path=../../src
include_path=../../include
symt_src_path=$(src_path)/symtab

all:
	make -s install
	make -s execute
	make -s clean

install: $(symt_src_path) $(include_path)
	gcc -g -o symt_test.exe $(symt_src_path)/symt.c $(include_path)/*.h $(symt_src_path)/lib/*.c $(symt_src_path)/symt/*.c symt_test.c -lm

execute: symt_test.exe
	./symt_test.exe

clean:
	rm -f symt_test.exe 2>/dev/null

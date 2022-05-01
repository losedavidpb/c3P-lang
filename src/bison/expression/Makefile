############################################################################
#                                                                          #
#                   Makefile for expressions		        			   #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile and execute
# 	comparison analyzer for c3P programming language.
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

test_path=../../../test/bison

all:
	make -s clean_output
	make -s install
	make -s execute
	make -s clean

clean_output:
	rm -f c3pbison.output 2>/dev/null

install: expr_c3pflexbison.l expr_c3pbison.y
	bison -d expr_c3pbison.y
	flex expr_c3pflexbison.l
	gcc -g -o c3pflexbison.exe expr_c3pbison.tab.c lex.yy.c -lm -lfl

execute: c3pflexbison.exe expr_c3pbison.tab.c expr_c3pbison.tab.h lex.yy.c
	./c3pflexbison.exe $(test_path)/expressions/b_expression_test_*.c3p

clean:
	rm -f expr_c3pbison.tab.c 2>/dev/null
	rm -f expr_c3pbison.tab.h 2>/dev/null
	rm -f c3pflexbison.exe 2>/dev/null
	rm -f lex.yy.c 2>/dev/null

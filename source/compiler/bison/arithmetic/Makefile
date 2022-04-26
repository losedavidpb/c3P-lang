############################################################################
#                                                                          #
#                   Makefile for arithmetic expressions                    #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile and execute
# 	arithmetic analyzer for c3P programming language.
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

all:
	make -s clean_output
	make -s install
	make -s execute
	make -s clean

clean_output:
	rm -f c3pbison.output 2>/dev/null

install: arithmetic_c3pflexbison.l arithmetic_c3pbison.y
	bison -d arithmetic_c3pbison.y
	flex arithmetic_c3pflexbison.l
	gcc -o c3pflexbison arithmetic_c3pbison.tab.c lex.yy.c -lm -lfl

execute: c3pflexbison arithmetic_c3pbison.tab.c arithmetic_c3pbison.tab.h lex.yy.c
	./c3pflexbison ../../../test/bison/expressions/s_a_test_*.c3p

clean:
	rm -f arithmetic_c3pbison.tab.c 2>/dev/null
	rm -f arithmetic_c3pbison.tab.h 2>/dev/null
	rm -f c3pflexbison 2>/dev/null
	rm -f lex.yy.c 2>/dev/null
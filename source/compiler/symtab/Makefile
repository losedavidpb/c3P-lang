############################################################################
#                                                                          #
#                       Makefile for c3P symbol table                      #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile symbol table
#	for c3P programming language.
#
# SYNTAX
#	make -s src=<<SOURCE_FILES>>
#
# SOURCE_FILES
#	It is possible to define multiple c3P source files separating them
#	at "src" parameter with spaces
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
	rm -f ../../test/*.txt 2>/dev/null

install: c3pflex.l c3pbison.y
	bison -d c3pbison.y
	flex c3pflex.l
	gcc -g -o c3psymt.exe lib/memlib.h lib/memlib.c lib/assertb.h lib/copy.h lib/copy.c symt.c symt.h c3pbison.tab.c lex.yy.c -lfl -lm

execute: c3psymt.exe c3pbison.tab.c c3pbison.tab.h lex.yy.c
	./c3psymt.exe ../../test/bison/*.c3p

clean:
	rm -f c3pbison.tab.c 2>/dev/null
	rm -f c3pbison.tab.h 2>/dev/null
	rm -f lex.yy.c 2>/dev/null
	rm -f c3psymt.exe 2>/dev/null
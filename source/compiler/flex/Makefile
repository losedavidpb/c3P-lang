############################################################################
#                                                                          #
#                          Makefile for c3P flex                           #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile and execute
# 	Flex analyzer for c3P programming language.
#
# SYNTAX
#	make -s src=<<SOURCE_FILES_SPLIT_WITH_SPACES>>
#
# SOURCE_FILES
#	It is possible to define multiple c3P source files separating them
#	at "src" parameter with spaces
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

ifndef src
	src=../../test/flex/*.c3p
endif

all:
	make -s install
	make -s execute
	make -s clean

install: c3pflex.l
	flex c3pflex.l
	gcc -g -o c3pflex.exe lex.yy.c -lfl

execute: c3pflex.exe lex.yy.c
	./c3pflex.exe $(src)

clean:
	rm -f lex.yy.c 2>/dev/null
	rm -f c3pflex.exe 2>/dev/null
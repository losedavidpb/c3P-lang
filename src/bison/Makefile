############################################################################
#                                                                          #
#                          Makefile for c3P bison                          #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile and execute
# 	Bison analyzer for c3P programming language.
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

test_path=../../test/bison
ifndef src
	src=$(test_path)/*.c3p
endif

all:
	make -s clean_output
	make -s install
	make -s execute
	make -s clean

clean_output:
	rm -f c3pbison.output 2>/dev/null
	rm -f $(test_path)/*.txt 2>/dev/null

install: c3pflexbison.l c3pbison.y
	bison -d c3pbison.y
	flex c3pflexbison.l
	gcc -g -o c3pflexbison.exe c3pbison.tab.c lex.yy.c -lfl -lm

execute: c3pflexbison.exe c3pbison.tab.c c3pbison.tab.h lex.yy.c
	./c3pflexbison.exe $(src)

clean:
	rm -f c3pbison.tab.c 2>/dev/null
	rm -f c3pbison.tab.h 2>/dev/null
	rm -f c3pflexbison.exe 2>/dev/null
	rm -f lex.yy.c 2>/dev/null

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
#	make -s
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

all:
	make -s install
	make -s clean

install:
	gcc -o symtab lib/memlib.h lib/memlib.c lib/assertb.h lib/copy.h lib/copy.c symt.c symt.h

clean:
	rm -f symtab 2>/dev/null
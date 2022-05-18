############################################################################
#                                                                          #
#                       Makefile for c3P with Q language                   #
#                                                                          #
############################################################################

# DESCRIPTION
# 	This makefile was designed to compile with Q language
#
# SYNTAX
#	make -s src=<<SOURCE_FILE>>
#
# AUTHOR
#	losedavidpb (https://github.com/losedavidpb)

test_path=../../test/symtab
include_path=../../include

all:
	make -s clean_start
	make -s install
	make -s clean

clean_start:
	rm -f c3pbison.output 2>/dev/null
	rm -f $(test_path)/../*.txt 2>/dev/null
	rm -f $(test_path)/*.out 2>/dev/null
	rm -f $(test_path)/c3p/*.out 2>/dev/null

install: c3pflex.l c3pbison.y
	gcc -no-pie -o IQ.exe qlang/IQ.o qlang/Qlib.c
	bison -d c3pbison.y
	flex c3pflex.l
	gcc -g -o c3pq.exe $(include_path)/*.h $(include_path)/qlang/qwriter.h \
		symt.c lib/*.c qlang/qwriter.c symt/*.c c3pbison.tab.c lex.yy.c -lfl -lm

clean:
	rm -f c3pbison.tab.c 2>/dev/null
	rm -f c3pbison.tab.h 2>/dev/null
	rm -f lex.yy.c 2>/dev/null

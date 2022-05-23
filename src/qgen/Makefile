# Makefile
#
# This file is part of the c3P language compiler. This project
# is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License
#
# This project is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# If not, see <http://www.gnu.org/licenses/>.
#

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
	bison -dv c3pbison.y
	flex c3pflex.l
	gcc -g -o c3pq.exe $(include_path)/symt_*.h $(include_path)/qwriter.h $(include_path)/memlib.h \
		$(include_path)/assertb.h $(include_path)/arrcopy.h symt.c lib/*.c symt/*.c c3pbison.tab.c lex.yy.c -lfl -lm

clean:
	rm -f c3pbison.tab.c 2>/dev/null
	rm -f c3pbison.tab.h 2>/dev/null
	rm -f lex.yy.c 2>/dev/null

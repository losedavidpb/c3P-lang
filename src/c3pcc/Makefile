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

root_path=../..

src_path=$(root_path)/src/c3pcc
include_path=$(src_path)/include

includes=$(include_path)/symt*.h $(include_path)/qwriter.h $(include_path)/arrcopy.h $(include_path)/memlib.h $(include_path)/assertb.h $(include_path)/f_reader.h $(include_path)/y_utils.h
sources=$(src_path)/symt.c $(src_path)/lib/*.c $(src_path)/symt/*.c $(src_path)/*.tab.c $(src_path)/*.yy.c

all:
	find $(root_path) -name "c3pc" -exec rm {} +;
	find $(root_path) -name "iq" -exec rm {} +;
	make -s clean_trash
	make -s prepare_q_assembly
	make -s prepare_bison
	make -s prepare_flex
	make -s prepare_compiler
	make -s clean_trash

clean_trash:
	find $(root_path) -name "*.output" -exec rm {} +;
	find $(root_path) -name "*.exe" -exec rm {} +;
	find $(root_path) -name "*.out" -exec rm {} +;
	find $(root_path) -name "*.q.c*" -exec rm {} +;
	find $(root_path) -name "*.yy.c" -exec rm {} +;
	find $(root_path) -name "*.tab.c" -exec rm {} +;
	find $(root_path) -name "*.tab.h" -exec rm {} +;

prepare_q_assembly:
	gcc -no-pie -o iq $(src_path)/qlang/IQ.o $(src_path)/qlang/Qlib.c 2>/dev/null
	cp include/Qlib.h . 2>/dev/null

prepare_bison:
	bison -d $(src_path)/parser.y 2>/dev/null

prepare_flex:
	flex $(src_path)/scanner.l 2>/dev/null

prepare_compiler:
	gcc -g -o c3pc $(includes) $(sources) -lfl -lm

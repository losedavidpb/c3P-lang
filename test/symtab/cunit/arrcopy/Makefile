############################################################################
#                                                                          #
#                     Makefile for tests for arrcopy                     	 #
#                                                                          #
############################################################################

src_path=../../../../src
include_path=../../../../include
symt_src_path=$(src_path)/symtab

all:
	make -s install
	make -s execute
	make -s clean

install: $(symt_src_path) $(include_path)
	gcc -g -o arrcopy_test.exe $(include_path)/memlib.h $(include_path)/arrcopy.h $(include_path)/cunit.h \
		$(include_path)/assertb.h $(symt_src_path)/lib/memlib.c $(symt_src_path)/lib/arrcopy.c arrcopy_test.c -lm

execute: arrcopy_test.exe
	./arrcopy_test.exe

clean:
	rm -f arrcopy_test.exe 2>/dev/null

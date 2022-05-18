#!/usr/bin/env bash

test_path=($(ls ../../test/symtab/*.c3p))
make -s

echo "c3pq -- Compiler using Q language"
echo "================================="

for (( i=0; i<${#test_path[*]}; i++ )); do
	echo " >> Compiling ${test_path[i]} ... "
    ./c3pq.exe ${test_path[i]}
	./IQ.exe "${test_path[i]}.q.c"
done

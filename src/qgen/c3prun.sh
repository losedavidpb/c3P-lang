#!/usr/bin/env bash
# c3prun.sh
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

test_path=($(ls ../../test/qgen/*.c3p))
[[ ! -z $1 ]] && [[ $1 =~ "-c" ]] && make -s

echo "c3pq -- Compiler using Q language"
echo "================================="

for (( i=0; i<${#test_path[*]}; i++ )); do
	echo -n " >> Compiling ${test_path[i]} ... "
    ./c3pq.exe ${test_path[i]}
	./IQ.exe "${test_path[i]}.q.c"
	echo "OK"
done

/*// f_reader.c -*- C -*-
//
// This file is part of the c3P language compiler. This project
// is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License
//
// This project is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// If not, see <http://www.gnu.org/licenses/>.
//*/

/*
 *	ISO C99 Standard: Implementation of File reader
 */

#include "../include/f_reader.h"

#include "../include/memlib.h"
#include "../include/arrcopy.h"

void fr_open_file(char *file)
{
	reader.file = strcopy(file);
	reader.num_line = 1;
}

void fr_next_line()
{
	reader.num_line++;
}

void fr_close_file()
{
	ml_free(reader.file);
	reader.file = NULL;
	reader.num_line = 0;
}

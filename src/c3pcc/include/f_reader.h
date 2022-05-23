/*// f_reader.h -*- C -*-
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
 *	ISO C99 Standard: File reader to count number of lines
 */

#ifndef F_READER_H
#define F_READER_H

typedef struct f_reader_t
{
	char *file;
	int num_line;
} f_reader_t;

struct f_reader_t reader;

void fr_open_file(char *file);

void fr_next_line();

void fr_close_file();

#endif // F_READER_H

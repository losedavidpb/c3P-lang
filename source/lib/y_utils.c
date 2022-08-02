// y_utils.c -*- C -*-
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
//

/*
 *	ISO C99 Standard: Utilities for Bison
 */

#include "../include/y_utils.h"

int ends_with(const char* name, const char* extension, symt_natural_t length)
{
	const char* ldot = strrchr(name, '.');

  	if (ldot != NULL)
  	{
    	if (length == 0) length = strlen(extension);
    	return strncmp(ldot + 1, extension, length) == 0;
  	}

  	return 0;
}

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

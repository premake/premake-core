#include "../premake_internal.h"

#include <string.h>

int pmk_getFileBaseName(char* result, const char* path)
{
	pmk_getFileName(result, path);

	char* endPtr = strrchr(result, '.');
	if (endPtr != NULL) {
		*endPtr = '\0';
	}

	return (TRUE);
}

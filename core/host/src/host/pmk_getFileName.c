#include "../premake_internal.h"

#include <string.h>

int pmk_getFileName(char* result, const char* path)
{
	/* Find the last '/' or '\' in the path */
	const char* endPtr = strrchr(path, '/');
	if (endPtr == NULL)
		endPtr = strrchr(path, '\\');

	/* If I found one, split and return everything after */
	if (endPtr != NULL) {
		strcpy(result, endPtr + 1);
	} else {
		strcpy(result, path);
	}

	return (TRUE);
}

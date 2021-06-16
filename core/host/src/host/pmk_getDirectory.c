#include "../premake_internal.h"
#include <string.h>

/**
 * Retrieve the directory portion (everything before the file name)
 * of a path. For a path like `/Users/Max/Documents/MyFile.txt', returns
 * `/Users/Max/Documents`.
 *
 * @param result
 *    A buffer to hold the resulting path.
 * @param path
 *    The full path to be processed.
 */
void pmk_getDirectory(char* result, const char* path)
{
	int len = 0;

	/* Find the last '/' or '\' in the path */
	const char* ptr = strrchr(path, '/');
	if (ptr == NULL)
		 ptr = strrchr(path, '\\');

	if (ptr == path) {  /* if (path == "/") */
		len = 1;
	} else if (ptr != NULL) {
		len = (ptr - path);
	}

	if (len > 0) {
		if (result != path)
			strncpy(result, path, len);
		result[len] = '\0';
	} else {
		strcpy(result, ".");
	}
}

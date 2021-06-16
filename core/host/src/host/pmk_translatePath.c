#include "../premake_internal.h"
#include <string.h>

/**
 * Translates slashes in a path, copying the result into the provided buffer.
 *
 * @param result
 *    A buffer to hold the translated path.
 * @param path
 *    The path to be translated.
 * @param separator
 *    A new path separator; only the first character will be used.
 */
const char* pmk_translatePath(char* result, const char* path, const char* separator)
{
	strcpy(result, path);
	pmk_translatePathInPlace(result, separator);
	return (result);
}


/**
 * Translates slashes in a path.
 *
 * @param path
 *    The path to be translated.
 * @param separator
 *    A new path separator; only the first character will be used.
 */
void pmk_translatePathInPlace(char* path, const char* separator)
{
	for (char* ch = path; *ch != '\0'; ++ch) {
		if (*ch == '/' || *ch == '\\') {
			*ch = separator[0];
		}
	}
}

#include "../premake_internal.h"

#include <string.h>

/**
 * Converts a relative path to absolute.
 *
 * @param result
 *    A buffer to hold the converted path.
 * @param path
 *    The path to be converted.
 * @param relativeTo
 *    If specified, `path` will be considered to be relative to this (possibly
 *    also relative) path. May be `nil` if not required.
 */
const char* pmk_getAbsolutePath(char* result, const char* path, const char* relativeTo)
{
	char buffer[PATH_MAX] = { '\0' };

	/* if the path is not already absolute, base it on working dir */
	if (!pmk_isAbsolutePath(path)) {
		if (relativeTo) {
			strcpy(buffer, relativeTo);
		} else {
			pmk_getCwd(buffer);
		}
		strcat(buffer, "/");
	}

	/* normalize the path separators */
	strcat(buffer, path);
	pmk_translatePathInPlace(buffer, "/");

	/* process it part by part */
	result[0] = '\0';

	/* leading "/" or "//"? */
	if (buffer[0] == '/') {
		strcat(result, "/");
		if (buffer[1] == '/') {
			strcat(result, "/");
		}
	}

	char* prev = NULL;
	char* ch = strtok(buffer, "/");

	while (ch) {
		/* remove ".." where I can */
		if (strcmp(ch, "..") == 0 && (prev == NULL || (prev[0] != '$' && prev[0] != '%' && strcmp(prev, "..") != 0))) {
			int i = (int)strlen(result) - 2;
			while (i >= 0 && result[i] != '/') {
				--i;
			}
			if (i >= 0) {
				result[i + 1] = '\0';
			}
			ch = NULL;
		}

		/* allow everything except "." */
		else if (strcmp(ch, ".") != 0) {
			strcat(result, ch);
			strcat(result, "/");
		}

		prev = ch;
		ch = strtok(NULL, "/");
	}

	/* remove trailing slash */
	int i = (int)strlen(result) - 1;
	if (result[i] == '/') {
		result[i] = '\0';
	}

	return (result);
}

#include "../premake_internal.h"
#include <string.h>

/**
 * Locate a file along a list of search paths, using any of a set of naming patterns.
 * The search is performed "pattern-first".
 *
 * Given an array of paths `[ "A", "B", "C"]` and a list of patterns `[ "?/?.lua", "?.lua" ]`
 * will look for the file in this order:
 *
 * `A/mame/name.lua`
 * `A/name.lua`
 * `B/mame/name.lua`
 * `B/name.lua`
 * `C/mame/name.lua`
 * `C/name.lua`
 *
 * @param result
 *    A buffer to hold the results of the search. If successful, will contain
 *    the resolved path to the file.
 * @param name
 *    The name of the file to be located.
 * @param paths
 *    A NULL-terminated list of paths to be searched.
 * @param patterns
 *    A NULL-terminated list of naming patterns, where the character "?" will be
 *    replaced with the provided file name, ex. "?/?.lua" becomes "name/name.lua".
 * @return
 *    If successful, returns `result`. Otherwise returns `NULL`.
 */
const char* pmk_locate(char* result, const char* name, const char* paths[], const char* patterns[])
{
	int nameLen = strlen(name);

	if (pmk_isAbsolutePath(name)) {
		strcpy(result, name);
		return (result);
	}

	for (int i = 0; paths[i] != NULL; ++i) {
		for (int j = 0; patterns[j] != NULL; ++j) {
			strcpy(result, paths[i]);
			strcat(result, "/");

			/* copy pattern into result, replacing "?" with name */
			int len = strlen(result);
			for (const char* ch = patterns[j]; *ch != '\0'; ++ch) {
				if (*ch == '?') {
					strcat(result, name);
					len += nameLen;
				}
				else {
					result[len++] = *ch;
					result[len] = '\0';
				}
			}

			/* does this file exist? */
			if (pmk_isFile(result)) {
				pmk_getAbsolutePath(result, result, NULL);
				return (result);
			}
		}
	}

	*result = '\0';
	return (NULL);
}

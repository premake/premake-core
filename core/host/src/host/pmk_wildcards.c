#include "../premake_internal.h"
#include <string.h>
#include <stdlib.h>

#define ADD(c)  if ((next + 1) < maxLen) { result[next++] = c; }


/**
 * Converts from a simple wildcard syntax to full Lua pattern. When matching plain
 * strings, `*` is "match any". When matching paths, `*` matches anything up to the
 * next path separator, and `**` matches anything to the end of the path (recursive
 * match).
 *
 * @param result
 *    A buffer to hold the expanded pattern.
 * @param maxLen
 *    The maximum allowed length of the result.
 * @param value
 *    The string value which uses the simple wildcard syntax.
 * @param isPath
 *    If `true`, the value is treated as a path. Otherwise it is treated as a
 *    plain string.
 * @returns
 *     `True` if the expansion is successful, or `false` if the buffer is too small.
 */
int pmk_patternFromWildcards(char* result, int maxLen, const char* value, int isPath)
{
	int next = 0;

	int valueLen = strlen(value);
	for (int i = 0; i < valueLen; ++i) {
		char c = value[i];
		switch (c) {
			case '*':
				if (isPath) {
					if (i + 1 == '*') {
						++i;
						ADD('.');
						ADD('*');
					}
					else {
						ADD('[');
						ADD('^');
						ADD('/');
						ADD(']');
						ADD('*');
					}
				}
				else {
					ADD('.');
					ADD('*');
				}
				break;

			default:
				ADD(c);
				break;
		}
	}

	result[next] = '\0';
	return (next < maxLen);
}

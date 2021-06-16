#include "../premake_internal.h"

#include <string.h>

#if PLATFORM_WINDOWS
#include <ctype.h>
#define cmpstr        _stricmp
#define cmpchar(a,b)  (tolower(a) == tolower(b))
#else
#define cmpstr        strcmp
#define cmpchar(a,b)  ((a) == (b))
#endif


/**
 * Returns a path relative to the provided file system location.
 *
 * @param result
 *    A buffer to hold the converted path.
 * @param basePath
 *    The originating path, to with `targetPath` should be made relative. Must be absolute.
 * @param targetPath
 *    The destination path, which will be made relative to `basePath`. Must be absolute.
 */
const char* pmk_getRelativePath(char* result, const char* basePath, const char* targetPath)
{
	int count, last, i;

	char base[PATH_MAX];
	char target[PATH_MAX];

	pmk_normalize(base, basePath);
	pmk_normalize(target, targetPath);

	/* Are they the same path? */
	if (cmpstr(base, target) == 0) {
		strcpy(result, ".");
		return (result);
	}

	/* Does the target path start with a macro? No way to know what the actual path
	 * might be, so treat as absolute. This enables paths like `$(SDK_ROOT)/include`
	 * to work as expected. */
	if (target[0] == '$') {
		strcpy(result, target);
		return (result);
	}

	/* Find the common leading directories */
	strcat(base, "/");
	strcat(target, "/");

	last = -1;

	for (i = 0; base[i] != '\0' && target[i] != '\0' && cmpchar(base[i], target[i]); ++i) {
		if (base[i] == '/')
			last = i;
	}

	target[strlen(target) - 1] = '\0';

	/* If I end up at the root of the file system, either as a single slash or a
	 * DOS driver letter, return the absolute target path */
	if (last <= 0 || (last == 2 && base[1] == ':')) {
		strcpy(result, target);
		return (result);
	}

	/* Same deal for "//server" paths: if we've hit the top of the file system
	* return the absolute target path */
	if (last == 1 && base[0] == '/' && base[1] == '/') {
		strcpy(result, target);
		return (result);
	}

	/* Count how many directory levels the base path continues to decend past the common root... */
	count = 0;

	for (i = last + 1; base[i] != '\0'; ++i) {
		if (base[i] == '/')
			++count;
	}

	/* ...start the result with the corresponding number of "../" to back out to the common root */
	result[0] = '\0';
	for (i = 0; i < count; ++i) {
		strcat(result, "../");
	}

	/* Append whatever is left of the target path past the common root */
	strcat(result, target + last + 1);

	/* Remove trailing slash, if present */
	last = strlen(result) - 1;
	if (result[last] == '/')
		result[last] = '\0';

	return (result);
}

/**
 * \file   os_dirname.c
 * \brief  Return the directory path from the file path.
 */

#include "premake.h"
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#if PLATFORM_POSIX
#include <libgen.h>
#endif

int os_dirname(lua_State* L)
{
	char path_copy[PATH_MAX];
	const char* path = luaL_checkstring(L, 1);
	char* result;
	size_t path_len = strlen(path);
	int ok = 0;

	if (!path) {
		goto exit;
	}

	if (path_len + 1 > PATH_MAX) {
		goto exit;
	}

#if PLATFORM_WINDOWS
	result = path_copy;

	if (_splitpath_s(
		path,
		NULL, 0, // drive
		result, sizeof(path_copy), // dir
		NULL, 0, // name
		NULL, 0 // ext
	) != 0) {
		goto exit;
	}

	// Remove trailing slash to get consistent behavior
	// between POSIX and Windows
	size_t result_length = strnlen(result, sizeof(path_copy));
	result[result_length - 1] = '\0';
#else // PLATFORM_WINDOWS
	// POSIX dirname may modify the argument string,
	// so copy it.
	strncpy(path_copy, path, path_len);
	path_copy[sizeof(path_copy) - 1] = '\0';

#if PLATFORM_POSIX
	result = dirname(path_copy);
#else
	result = do_dirname(path_copy);
#endif

	if (!result) {
		goto exit;
	}
#endif // !PLATFORM_WINDOWS

	ok = 1;

exit:
	if (!ok) {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to fetch directory name of '%s', errno %d : %s",
			path, errno, strerror(errno));
		return 2;
	}

	lua_pushstring(L, result);
	return 1;
}

char* do_dirname(char* path) {
	if (path == NULL) {
		return NULL;
	}

	size_t length = strlen(path);
	size_t pos = length - 1;

	while (pos != 0) {
		if (path[pos] == '/') {
			path[pos] = '\0';
			break;
		}

		pos -= 1;
	}

	return path;
}

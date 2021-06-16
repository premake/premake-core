#include "../premake_internal.h"

/**
 * Set the current working directory.
 */
int pmk_chdir(const char* path)
{
#if PLATFORM_WINDOWS
	wchar_t wideBuffer[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, path, -1, wideBuffer, PATH_MAX) == 0) {
		return (FALSE);
	}
	if (!SetCurrentDirectoryW(wideBuffer)) {
		return (FALSE);
	}
#else
	if (chdir(path) != 0) {
		return (FALSE);
	}
#endif

	return (TRUE);
}

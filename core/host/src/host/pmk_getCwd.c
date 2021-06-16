#include "../premake_internal.h"


/**
 * Retrieve the current working directory.
 *
 * @param result
 *    A buffer to hold the retrieved path.
 */
int pmk_getCwd(char* result)
{
#if PLATFORM_WINDOWS
	wchar_t wideBuffer[PATH_MAX];
	if (GetCurrentDirectoryW(PATH_MAX, wideBuffer) == 0) {
		return (FALSE);
	}
	if (WideCharToMultiByte(CP_UTF8, 0, wideBuffer, -1, result, PATH_MAX, NULL, NULL) == 0) {
		return (FALSE);
	}
	pmk_translatePathInPlace(result, "/");
#else
	if (getcwd(result, PATH_MAX) == 0) {
		return (FALSE);
	}
#endif

	return (TRUE);
}

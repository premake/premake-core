#include "../premake_internal.h"

FILE* pmk_openFile(const char* path, const char* mode)
{
	FILE* file = NULL;

#if PLATFORM_WINDOWS
	wchar_t widePath[PATH_MAX];
	wchar_t wideMode[8];
	if (MultiByteToWideChar(CP_UTF8, 0, mode, -1, wideMode, 8) > 0) {
		if (MultiByteToWideChar(CP_UTF8, 0, path, -1, widePath, PATH_MAX) > 0)
			file = _wfopen(widePath, wideMode);
	}
#else
	file = fopen(path, mode);
#endif

	return (file);
}

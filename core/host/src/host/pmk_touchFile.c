#include "../premake_internal.h"

#include <stdio.h>
#include <string.h>

#if PLATFORM_WINDOWS
	#include <io.h>
#else
	#include <unistd.h>
	#include <sys/types.h>
#endif


int pmk_touchFile(const char* path)
{
	FILE* file;

	if (pmk_isFile(path)) {
#if PLATFORM_WINDOWS
		SYSTEMTIME systemTime;
		FILETIME fileTime;
		HANDLE fileHandle;
		wchar_t wide_path[PATH_MAX];
		if (MultiByteToWideChar(CP_UTF8, 0, path, -1, wide_path, PATH_MAX) == 0)
			return (FALSE);

		fileHandle = CreateFileW(wide_path, FILE_WRITE_ATTRIBUTES, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
		if (fileHandle == NULL)
			return (FALSE);

		GetSystemTime(&systemTime);
		if (SystemTimeToFileTime(&systemTime, &fileTime) == 0)
			return (FALSE);

		if (SetFileTime(fileHandle, NULL, NULL, &fileTime) == 0)
			return (FALSE);

		return (TRUE);
#else
		size_t size;

		FILE* file = fopen(path, "rb");
		file = fopen(path, "ab");

		if (file == NULL)
			return (FALSE);

		fseek(file, 0, SEEK_END);
		size = ftell(file);

		// append a dummy space. There are better ways to do a touch, however this is a rather simple multiplatform method
		if (fwrite(" ", 1, 1, file) != 1) {
			fclose(file);
			return (FALSE);
		}

		fclose(file);

		if (truncate(path, (off_t)size) != 0)
			return (FALSE);

		return (TRUE);
#endif
	}

	/* File doesn't exist... */

#if PLATFORM_WINDOWS
	wchar_t wide_path[PATH_MAX];

	if (MultiByteToWideChar(CP_UTF8, 0, path, -1, wide_path, PATH_MAX) == 0)
		return (FALSE);

	file = _wfopen(wide_path, L"wb");
#else
	file = fopen(path, "wb");
#endif

	if (file != NULL) {
		fclose(file);
		return (TRUE);
	}

	return (FALSE);
}

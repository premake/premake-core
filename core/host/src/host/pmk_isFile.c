#include "../premake_internal.h"
#include <sys/stat.h>

/**
 * Returns true (non-zero) if the given file exists on the file system, and
 * it a file (i.e. not a directory).
 *
 * @param filename
 *    The name of the file to be tested.
 */
int pmk_isFile(const char* filename)
{
#if PLATFORM_WINDOWS
	wchar_t wideBuffer[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, filename, -1, wideBuffer, PATH_MAX) == 0) {
		return (FALSE);
	}

	DWORD attrib = GetFileAttributesW(wideBuffer);
	if (attrib != INVALID_FILE_ATTRIBUTES) {
		return ((attrib & FILE_ATTRIBUTE_DIRECTORY) == 0);
	}
#else
	struct stat buf;
	if (stat(filename, &buf) == 0) {
		return ((buf.st_mode & S_IFDIR) == 0);
	}
#endif

	return (FALSE);
}

#include "../premake_internal.h"

#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

#if PLATFORM_WINDOWS
#include <direct.h>
#include <errno.h>
#endif


int pmk_mkdir(const char* path)
{
	char buffer[PATH_MAX];
	struct stat sb;
	int i;
	int length;

	/* path already exists? just return */
	if (stat(path, &sb) == 0)
		return (OKAY);

	/* pull out the parent directory name; find the last separator */
	length = (int)strlen(path);
	for (i = length - 1; i >= 0; --i)
	{
		if (path[i] == '/' || path[i] == '\\')
			break;
	}

	/* if the path has a parent directory, create it */
	if (i > 0)
	{
		memcpy(buffer, path, i);
		buffer[i] = '\0';

#if PLATFORM_WINDOWS
		if (buffer[i - 1] == ':')
		{
			buffer[i + 0] = '/';
			buffer[i + 1] = '\0';
		}
#endif

		int result = pmk_mkdir(buffer);
		if (result != OKAY)
			return (result);
	}

	/* parent directory is now in place, create destination directory */
#if PLATFORM_WINDOWS
	return (_mkdir(path));
#else
	return (mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH));
#endif
}

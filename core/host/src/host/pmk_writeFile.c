#include "../premake_internal.h"

#include <string.h>


int pmk_writeFile(const char* path, const char* contents)
{
	FILE* file = pmk_openFile(path, "wb");
	if (file == NULL)
		return (-1);

	fwrite(contents, 1, strlen(contents), file);
	fclose(file);
	return (OKAY);
}

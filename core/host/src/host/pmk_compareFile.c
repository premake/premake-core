#include "../premake_internal.h"

#include <string.h>

#define CMP_FAILED    (-1)
#define CMP_NO_MATCH  (0)
#define CMP_MATCH     (1)


int pmk_compareFile(const char* path, const char* contents)
{
	char buffer[4096];
	size_t numBytesInFile;

	FILE* file = pmk_openFile(path, "rb");
	if (file == NULL)
		return (CMP_FAILED);

	/* Does file size match string length? */
	fseek(file, 0, SEEK_END);
	numBytesInFile = ftell(file);
	if (numBytesInFile != strlen(contents)) {
		fclose(file);
		return (CMP_NO_MATCH);
	}

	/* Read and compare chunks until a difference is found */
	fseek(file, 0, SEEK_SET);
	while (numBytesInFile > 0) {
		size_t numBytesToRead = (numBytesInFile > 4096) ? 4096 : numBytesInFile;
		size_t numBytesRead = fread(buffer, 1, numBytesToRead, file);
		if (numBytesRead != numBytesToRead) {
			fclose(file);
			return (CMP_FAILED);
		}

		if (memcmp(contents, buffer, numBytesRead) != 0) {
			fclose(file);
			return (CMP_NO_MATCH);
		}

		numBytesInFile -= numBytesRead;
		contents += numBytesRead;
	}

	fclose(file);
	return (CMP_MATCH);
}

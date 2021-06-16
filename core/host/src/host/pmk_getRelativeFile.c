#include "../premake_internal.h"

#include <string.h>


/**
 * The relative path between two files.
 *
 * @param result
 *    A buffer to hold the converted path.
 * @param basePath
 *    The originating file, to with `targetPath` should be made relative. Must be absolute.
 * @param targetPath
 *    The destination path, which will be made relative to `basePath`. Must be absolute.
 */
const char* pmk_getRelativeFile(char* result, const char* baseFile, const char* targetFile)
{
	pmk_getDirectory(result, baseFile);
	pmk_getRelativePath(result, result, targetFile);
	return (result);
}

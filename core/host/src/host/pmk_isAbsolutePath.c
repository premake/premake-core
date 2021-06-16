#include "../premake_internal.h"

/**
 * Returns true (non-zero) if the given path is absolute. Returns false (zero)
 * if the path is relative, or if its absolute-ness can not be determined (i.e.
 * it leads with a variable reference).
 *
 * @param path
 *    The path to be tested.
 */
int pmk_isAbsolutePath(const char* path)
{
	int kind = pmk_pathKind(path);
	return (kind == PMK_PATH_ABSOLUTE);
}

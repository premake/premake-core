#include "../premake_internal.h"

#include <string.h>

int pmk_startsWith(const char* haystack, const char* needle)
{
	size_t nHaystack = strlen(haystack);
	size_t nNeedle = strlen(needle);
	if (nHaystack >= nNeedle)
		return (strncmp(haystack, needle, nNeedle) == 0);
	else
		return (FALSE);
}

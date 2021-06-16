#include "../premake_internal.h"

#include <string.h>

int pmk_endsWith(const char* haystack, const char* needle)
{
	size_t nHaystack = strlen(haystack);
	size_t nNeedle = strlen(needle);
	if (nHaystack >= nNeedle)
		return (strcmp(haystack + nHaystack - nNeedle, needle) == 0);
	else
		return (FALSE);
}

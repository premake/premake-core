#include "../premake_internal.h"

#include <string.h>

uint32_t pmk_hash(const char* value, int seed)
{
	/* DJB2 hashing; see http://www.cse.yorku.ca/~oz/hash.html */

	uint32_t hash = 5381;

	if (seed != 0) {
		hash = hash * 33 + seed;
	}

	while (*value) {
		hash = hash * 33 + (*value);
		value++;
	}

	return hash;
}

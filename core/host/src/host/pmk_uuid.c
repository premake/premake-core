#include "../premake_internal.h"

#if PLATFORM_WINDOWS
#include <Objbase.h>
#endif


/*
 * Pull off the four lowest result of a value and add them to a byte array,
 * without the help of the determinately sized C99 data types that are not
 * yet universally supported.
 */
static void add(unsigned char* result, int offset, uint32_t value)
{
	for (int i = 0; i < 4; ++i)
	{
		result[offset++] = (unsigned char)(value & 0xff);
		value >>= 8;
	}
}


int pmk_uuid(char* result, const char* value)
{
	unsigned char bytes[16];

	/* If a name argument is supplied, build the UUID from that. For speed we
	 * are using a simple DBJ2 hashing function; if this isn't sufficient we
	 * can switch to a full RFC 4122 §4.3 implementation later. */
	if (value != NULL) {
		add(bytes, 0, pmk_hash(value, 0));
		add(bytes, 4, pmk_hash(value, 'L'));
		add(bytes, 8, pmk_hash(value, 'u'));
		add(bytes, 12, pmk_hash(value, 'a'));
	}

	/* If no name is supplied, try to build one properly */
	else
	{
#if PLATFORM_WINDOWS
		CoCreateGuid((GUID*)bytes);
#else
		/* not sure how to get a UUID for non-Windows platforms, so fake it */
		FILE* rnd = fopen("/dev/urandom", "rb");
		int status = fread(bytes, 16, 1, rnd);
		fclose(rnd);
		if (!status) {
			return (FALSE);
		}
#endif
	}

	sprintf(result, "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]);

	return (TRUE);
}

/**
 * \file   os_uuid.c
 * \brief  Create a new UUID.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#if PLATFORM_WINDOWS
#include <Objbase.h>
#endif

int os_uuid(lua_State* L)
{
	unsigned char bytes[16];
	char uuid[38];

#if PLATFORM_WINDOWS
	CoCreateGuid((char*)bytes);
#else
	int result;

	/* not sure how to get a UUID here, so I fake it */
	FILE* rnd = fopen("/dev/urandom", "rb");
	result = fread(bytes, 16, 1, rnd);
	fclose(rnd);
	if (!result)
		return 0;
#endif

	sprintf(uuid, "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]);

	lua_pushstring(L, uuid);
	return 1;
}

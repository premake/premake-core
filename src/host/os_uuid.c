/**
 * \file   os_uuid.c
 * \brief  Create a new UUID.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <stdint.h>

#if PLATFORM_WINDOWS
#include <Objbase.h>
#endif

int os_uuid(lua_State* L)
{
	char uuid[38];
	uint32_t buffer[4];
	uint8_t* bytes = (uint8_t*)buffer;
	
	/* If a name argument is supplied, build the UUID from that. For speed we
	 * are using a simple DBJ2 hashing function; if this isn't sufficient we
	 * can switch to a full RFC 4122 §4.3 implementation later. */
	const char* name = luaL_optstring(L, 1, NULL);
	if (name != NULL)
	{
		buffer[0] = do_hash(name, 0);
		buffer[1] = do_hash(name, 'L');
		buffer[2] = do_hash(name, 'u');
		buffer[3] = do_hash(name, 'a');
	}

	/* If no name is supplied, try to build one properly */	
	else
	{
#if PLATFORM_WINDOWS
		CoCreateGuid((GUID*)buffer);
#else
		int result;

		/* not sure how to get a UUID here, so I fake it */
		FILE* rnd = fopen("/dev/urandom", "rb");
		result = fread(buffer, 16, 1, rnd);
		fclose(rnd);
		if (!result)
		{
			return 0;
		}
#endif
	}

	sprintf(uuid, "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]);

	lua_pushstring(L, uuid);
	return 1;
}

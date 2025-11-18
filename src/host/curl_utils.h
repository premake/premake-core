/**
* \file   curl_utils.h
* \brief  curl utilities for the http library.
* \author Copyright (c) 2017 Tom van Dijck, João Matos and the Premake project
*/
#ifndef curl_utils_h
#define curl_utils_h

#ifdef PREMAKE_CURL

#include "buffered_io.h"
#ifdef LUA_STATICLIB
#include "lua.h"
#else
#include <lua5.3/lua.h>
#endif

#include <curl/curl.h>

typedef struct
{
	lua_State*          L;
	int                 RefIndex;
	Buffer              S;
	char                errorBuffer[256];
	struct curl_slist*  headers;
} curl_state;

CURL*  curlRequest(lua_State* L, curl_state* state, int optionsIndex, int progressFnIndex, int headersIndex);
void   curlCleanup(CURL* curl, curl_state* state);


#endif // PREMAKE_CURL

#endif // curl_utils_h

/**
* \file   curl_utils.h
* \brief  curl utilities for the http library.
* \author Copyright (c) 2017 Tom van Dijck, João Matos and the Premake project
*/
#ifndef curl_utils_h
#define curl_utils_h

#ifdef PREMAKE_CURL

#include "buffered_io.h"
#include "lua.h"

#define _MPRINTF_REPLACE /* use curl functions only */
#include <curl/curl.h>
#include <curl/mprintf.h>

typedef struct
{
	lua_State*          L;
	int                 RefIndex;
	Buffer              S;
	char                errorBuffer[256];
	struct curl_slist*  headers;
} curl_state;


#if LIBCURL_VERSION_NUM >= 0x072000
int curlProgressCallback(curl_state* state, curl_off_t dltotal, curl_off_t dlnow, curl_off_t ultotal, curl_off_t ulnow);
#else
int curlProgressCallback(curl_state* state, double dltotal, double dlnow, double ultotal, double ulnow);
#endif
size_t curlWriteCallback(char *ptr, size_t size, size_t nmemb, void* state);

CURL*  curlRequest(lua_State* L, curl_state* state, int optionsIndex, int progressFnIndex, int headersIndex);
void   curlCleanup(CURL* curl, curl_state* state);


#endif // PREMAKE_CURL

#endif // curl_utils_h

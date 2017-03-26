/**
* \file   http_get.c
* \brief  HTTP get request support using libcurl.
* \author Copyright (c) 2017 Blizzard Entertainment, João Matos and the Premake project
*/

#include "premake.h"
#include "curl_utils.h"

#ifdef PREMAKE_CURL

int http_get(lua_State* L)
{
	curl_state state;
	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;
	long responseCode = 0;

	if (lua_istable(L, 2))
	{
		// http.get(source, { options })
		curl = curlRequest(L, &state, /*optionsIndex=*/2, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.get(source, progressFunction, { headers })
		curl = curlRequest(L, &state, /*optionsIndex=*/0, /*progressFnIndex=*/2, /*headersIndex=*/3);
	}

	if (curl)
	{
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);

		code = curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
		curlCleanup(curl, &state);
	}

	if (code != CURLE_OK)
	{
		char errorBuf[1024];

		lua_pushnil(L);
		snprintf(errorBuf, sizeof(errorBuf) - 1, "%s\n%s\n", curl_easy_strerror(code), state.errorBuffer);
		lua_pushstring(L, errorBuf);
	}
	else
	{
		lua_pushlstring(L, state.S.data, state.S.length);
		lua_pushstring(L, "OK");
	}

	buffer_destroy(&state.S);
	lua_pushnumber(L, (lua_Number)responseCode);
	return 3;
}

#endif

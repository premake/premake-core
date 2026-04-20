/**
* \file   http_download.c
* \brief  HTTP download support using libcurl.
* \author Copyright (c) 2017 Blizzard Entertainment, João Matos and the Premake project
*/

#include "premake.h"
#include "curl_utils.h"

#ifdef PREMAKE_CURL

static size_t curl_file_cb(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fwrite(ptr, size, nmemb, stream);
}

int http_download(lua_State* L)
{
	curl_state state;
	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;
	long responseCode = 0;

	FILE* fp;
#if PLATFORM_WINDOWS
	const wchar_t *file = luaL_checkconvertstring(L, 2);
	fp = _wfopen(file, L"wb");
	lua_pop(L, 1);
#else
	const char* file = luaL_checkstring(L, 2);
	fp = fopen(file, "wb");
#endif
	if (!fp)
	{
		lua_pushstring(L, "Unable to open file.");
		lua_pushnumber(L, -1);
		return 2;
	}

	if (lua_istable(L, 3))
	{
		// http.download(source, destination, { options })
		curl = curlRequest(L, &state, /*optionsIndex=*/3, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.download(source, destination, progressFunction, { headers })
		curl = curlRequest(L, &state, /*optionsIndex=*/0, /*progressFnIndex=*/3, /*headersIndex=*/4);
	}

	if (curl)
	{
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_file_cb);

		code = curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
		curlCleanup(curl, &state);
	}

	fclose(fp);

	if (code != CURLE_OK)
	{
		char errorBuf[1024];
		snprintf(errorBuf, sizeof(errorBuf) - 1, "%s\n%s\n", curl_easy_strerror(code), state.errorBuffer);
		lua_pushstring(L, errorBuf);
	}
	else
	{
		lua_pushstring(L, "OK");
	}

	premake_buffer_destroy(&state.S);
	lua_pushnumber(L, (lua_Number)responseCode);
	return 2;
}

#endif

/**
 * \file   http.c
 * \brief  HTTP requests support using libcurl.
 * \author Copyright (c) 2014 João Matos and the Premake project
 */

#include "premake.h"
#include <stdlib.h>
#include <string.h>

#ifdef PREMAKE_CURL

#include <curl/curl.h>

#define _MPRINTF_REPLACE /* use curl functions only */
#include <curl/mprintf.h>

typedef struct {
	char* ptr;
	size_t len;
} string;

void string_init(string* s)
{
	s->len = 0;
	s->ptr = (char*) malloc(s->len+1);
	if (s->ptr == NULL)
	{
		fprintf(stderr, "malloc() failed\n");
		exit(EXIT_FAILURE);
	}
	s->ptr[0] = '\0';
}

void string_free(string* s)
{
	free(s->ptr);
	s->ptr = NULL;
	s->len = 0;
}

typedef struct
{
	lua_State* L;
	int RefIndex;
	string S;
	char errorBuffer[CURL_ERROR_SIZE];
} CurlCallbackState;

static int curl_progress_cb(void* userdata, double dltotal, double dlnow, double ultotal, double ulnow)
{
	CurlCallbackState* state = (CurlCallbackState*) userdata;
	lua_State* L = state->L;

	(void)ultotal;
	(void)ulnow;

	if (dltotal == 0) return 0;

	/* retrieve the lua progress callback we saved before */
	lua_rawgeti(L, LUA_REGISTRYINDEX, state->RefIndex);
	lua_pushnumber(L, (lua_Number) dltotal);
	lua_pushnumber(L, (lua_Number) dlnow);
	lua_pcall(L, 2, LUA_MULTRET, 0);

	return 0;
}

static size_t curl_write_cb(char *ptr, size_t size, size_t nmemb, void *userdata)
{
	CurlCallbackState* state = (CurlCallbackState*) userdata;
	string* s = &state->S;

	size_t new_len = s->len + size * nmemb;
	s->ptr = (char*) realloc(s->ptr, new_len+1);

	if (s->ptr == NULL)
	{
		fprintf(stderr, "realloc() failed\n");
		exit(EXIT_FAILURE);
	}

	memcpy(s->ptr+s->len, ptr, size * nmemb);
	s->ptr[new_len] = '\0';
	s->len = new_len;

	return size * nmemb;
}


static size_t curl_file_cb(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fwrite(ptr, size, nmemb, stream);
}


static void curl_init()
{
	static int initializedHTTP = 0;

	if (initializedHTTP)
		return;

	curl_global_init(CURL_GLOBAL_ALL);
	atexit(curl_global_cleanup);
	initializedHTTP = 1;
}

static void get_headers(lua_State* L, int headersIndex, struct curl_slist** headers)
{
	lua_pushnil(L);
	while (lua_next(L, headersIndex) != 0)
	{
		const char *item = luaL_checkstring(L, -1);
		lua_pop(L, 1);
		*headers = curl_slist_append(*headers, item);
	}
}

static CURL* curl_request(lua_State* L, CurlCallbackState* state, const char* url, FILE* fp, int optionsIndex, int progressFnIndex, int headersIndex)
{
	CURL* curl;
	struct curl_slist* headers = NULL;

	curl_init();
	curl = curl_easy_init();

	if (!curl)
		return NULL;

	curl_easy_setopt(curl, CURLOPT_URL, url);
	curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
	curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
	curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, state->errorBuffer);
	curl_easy_setopt(curl, CURLOPT_USERAGENT, "Premake/" PREMAKE_VERSION);

	if (optionsIndex && lua_istable(L, optionsIndex))
	{
		lua_pushnil(L);
		while (lua_next(L, optionsIndex) != 0)
		{
			const char* key = luaL_checkstring(L, -2);

			if (!strcmp(key, "headers") && lua_istable(L, -1))
			{
				get_headers(L, lua_gettop(L), &headers);
				curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
			}
			else if (!strcmp(key, "progress") && lua_isfunction(L, -1))
			{
				state->L = L;
				lua_pushvalue(L, -1);
				state->RefIndex = luaL_ref(L, LUA_REGISTRYINDEX);
			}
			else if (!strcmp(key, "userpwd") && lua_isstring(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_USERPWD, luaL_checkstring(L, -1));
			}
			else if (!strcmp(key, "username") && lua_isstring(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_USERNAME, luaL_checkstring(L, -1));
			}
			else if (!strcmp(key, "password") && lua_isstring(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_PASSWORD, luaL_checkstring(L, -1));
			}

			// pop the value, leave the key for lua_next
			lua_pop(L, 1);
		}
	}
	else
	{
		if (progressFnIndex && lua_type(L, progressFnIndex) == LUA_TFUNCTION)
		{
			state->L = L;
			lua_pushvalue(L, progressFnIndex);
			state->RefIndex = luaL_ref(L, LUA_REGISTRYINDEX);
		}

		if (headersIndex && lua_istable(L, headersIndex))
		{
			get_headers(L, headersIndex, &headers);
			curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
		}
	}

	curl_easy_setopt(curl, CURLOPT_WRITEDATA, state);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_cb);

	if (fp)
	{
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_file_cb);
	}

	if (state->L != 0)
	{
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, state);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, curl_progress_cb);
	}

	// clear error buffer.
	state->errorBuffer[0] = 0;

	return curl;
}


int http_get(lua_State* L)
{
	CurlCallbackState state = { 0, 0, {NULL, 0}, {0} };
	CURL* curl;
	CURLcode code;

	if (lua_istable(L, 2))
	{
		// http.get(source, { options })
		curl = curl_request(L, &state, luaL_checkstring(L, 1), /*fp=*/NULL, /*optionsIndex=*/2, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.get(source, progressFunction, { headers })
		curl = curl_request(L, &state, luaL_checkstring(L, 1), /*fp=*/NULL, /*optionsIndex=*/0, /*progressFnIndex=*/2, /*headersIndex=*/3);
	}

	if (!curl)
	{
		lua_pushnil(L);
		return 1;
	}

	string_init(&state.S);

	code = curl_easy_perform(curl);
	if (code != CURLE_OK)
	{
		char errorBuf[1024];
		snprintf(errorBuf, sizeof(errorBuf) - 1, "%s\n%s\n", curl_easy_strerror(code), state.errorBuffer);

		lua_pushnil(L);
		lua_pushfstring(L, errorBuf);
		string_free(&state.S);
		return 2;
	}

	curl_easy_cleanup(curl);

	lua_pushlstring(L, state.S.ptr, state.S.len);
	string_free(&state.S);

	return 1;
}


int http_download(lua_State* L)
{
	CurlCallbackState state = { 0, 0, {NULL, 0}, {0} };

	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;

	FILE* fp;
	const char* file = luaL_checkstring(L, 2);

	fp = fopen(file, "wb");
	if (!fp)
	{
		lua_pushstring(L, "Unable to open file.");
		lua_pushnumber(L, -1);
		return 2;
	}

	if (lua_istable(L, 3))
	{
		// http.download(source, destination, { options })
		curl = curl_request(L, &state, luaL_checkstring(L, 1), fp, /*optionsIndex=*/3, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.download(source, destination, progressFunction, { headers })
		curl = curl_request(L, &state, luaL_checkstring(L, 1), fp, /*optionsIndex=*/0, /*progressFnIndex=*/3, /*headersIndex=*/4);
	}

	if (curl)
	{
		code = curl_easy_perform(curl);
		curl_easy_cleanup(curl);
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

	lua_pushnumber(L, code);
	return 2;
}

#endif

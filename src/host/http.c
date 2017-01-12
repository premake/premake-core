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
	struct curl_slist* headers;
} curl_state;

static int curl_progress_cb(void* userdata, double dltotal, double dlnow, double ultotal, double ulnow)
{
	curl_state* state = (curl_state*) userdata;
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
	curl_state* state = (curl_state*) userdata;
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

static CURL* curl_request(lua_State* L, curl_state* state, int optionsIndex, int progressFnIndex, int headersIndex)
{
	CURL* curl;

	state->L = 0;
	state->RefIndex = 0;
	state->S.ptr = NULL;
	state->S.len = 0;
	state->errorBuffer[0] = '\0';
	state->headers = NULL;

	curl_init();
	curl = curl_easy_init();

	if (!curl)
		return NULL;

	curl_easy_setopt(curl, CURLOPT_URL, luaL_checkstring(L, 1));
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
				get_headers(L, lua_gettop(L), &state->headers);
				curl_easy_setopt(curl, CURLOPT_HTTPHEADER, state->headers);
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
			else if (!strcmp(key, "timeout") && lua_isnumber(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_TIMEOUT, (long)luaL_checknumber(L, -1));
			}
			else if (!strcmp(key, "timeoutms") && lua_isnumber(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, (long)luaL_checknumber(L, -1));
			}
			else if (!strcmp(key, "sslverifyhost") && lua_isnumber(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, (long)luaL_checknumber(L, -1));
			}
			else if (!strcmp(key, "sslverifypeer") && lua_isnumber(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, (long)luaL_checknumber(L, -1));
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
			get_headers(L, headersIndex, &state->headers);
			curl_easy_setopt(curl, CURLOPT_HTTPHEADER, state->headers);
		}
	}

	curl_easy_setopt(curl, CURLOPT_WRITEDATA, state);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_cb);

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

static void curl_cleanup(CURL* curl, curl_state* state)
{
	if (state->headers)
	{
		curl_slist_free_all(state->headers);
		state->headers = 0;
	}
	curl_easy_cleanup(curl);
}


int http_get(lua_State* L)
{
	curl_state state;
	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;
	long responseCode = 0;

	if (lua_istable(L, 2))
	{
		// http.get(source, { options })
		curl = curl_request(L, &state, /*optionsIndex=*/2, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.get(source, progressFunction, { headers })
		curl = curl_request(L, &state, /*optionsIndex=*/0, /*progressFnIndex=*/2, /*headersIndex=*/3);
	}

	string_init(&state.S);
	if (curl)
	{
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);

		code = curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
		curl_cleanup(curl, &state);
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
		lua_pushlstring(L, state.S.ptr, state.S.len);
		lua_pushstring(L, "OK");
	}

	string_free(&state.S);
	lua_pushnumber(L, (lua_Number)responseCode);
	return 3;
}


int http_post(lua_State* L)
{
	curl_state state;
	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;
	long responseCode = 0;

	// http.post(source, postdata, { options })
	curl = curl_request(L, &state, /*optionsIndex=*/3, /*progressFnIndex=*/0, /*headersIndex=*/0);

	string_init(&state.S);
	if (curl)
	{
		size_t dataSize;
		const char* data = luaL_checklstring(L, 2, &dataSize);

		curl_easy_setopt(curl, CURLOPT_POST, 1);
		if (data && dataSize > 0)
		{
			curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)dataSize);
			curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);
		}

		code = curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
		curl_cleanup(curl, &state);
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
		lua_pushlstring(L, state.S.ptr, state.S.len);
		lua_pushstring(L, "OK");
	}

	string_free(&state.S);
	lua_pushnumber(L, (lua_Number)responseCode);
	return 3;
}


int http_download(lua_State* L)
{
	curl_state state;
	CURL* curl;
	CURLcode code = CURLE_FAILED_INIT;
	long responseCode = 0;

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
		curl = curl_request(L, &state, /*optionsIndex=*/3, /*progressFnIndex=*/0, /*headersIndex=*/0);
	}
	else
	{
		// backward compatible function signature
		// http.download(source, destination, progressFunction, { headers })
		curl = curl_request(L, &state, /*optionsIndex=*/0, /*progressFnIndex=*/3, /*headersIndex=*/4);
	}

	if (curl)
	{
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_file_cb);

		code = curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
		curl_cleanup(curl, &state);
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

	lua_pushnumber(L, (lua_Number)responseCode);
	return 2;
}

#endif

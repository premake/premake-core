/**
 * \file   http.c
 * \brief  HTTP requests support using libcurl.
 * \author Copyright (c) 2014 João Matos and the Premake project
 */

#include "premake.h"
#include <stdlib.h>

#ifdef PREMAKE_CURL

#include <curl/curl.h>

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

typedef struct {
	lua_State* L;
	int RefIndex;
	string S;
} CurlCallbackState;

static int curl_progress_cb(void* userdata, double dltotal, double dlnow,
	double ultotal, double ulnow)
{
	CurlCallbackState* state = (CurlCallbackState*) userdata;
	lua_State* L = state->L;

	(void)ultotal;
	(void)ulnow;

	if (dltotal == 0) return 0;

	/* retrieve the lua progress callback we saved before */
	lua_rawgeti(L, LUA_REGISTRYINDEX, state->RefIndex);
	lua_pushnumber(L, (lua_Number)dltotal);
	lua_pushnumber(L, (lua_Number)dlnow);
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


static void get_headers(lua_State* L, struct curl_slist** headers)
{
	int i;
	int argc = lua_gettop(L);
	// Headers are optional so loop through them if they exist(also indexed 1 -> N instead of 0 -> N-1 in lua)
	for (i = 3; i <= argc; ++i)
	{
		if (lua_istable(L, -1))
		{
			lua_pushnil(L);

			while (lua_next(L, -2) != 0)
			{
				const char *item = luaL_checkstring(L, -1);
				lua_pop(L, 1);
				*headers = curl_slist_append(*headers, item);
			}
			// Only expect a single table as a parameter so break after reading it
			break;
		}
	}
}


static CURL* curl_request(lua_State* L, CurlCallbackState* state, FILE* fp, int progressFnIndex)
{
	CURL* curl;
	struct curl_slist* headers = NULL;
	const char* url = luaL_checkstring(L, 1);

	/* if the second argument is a lua function, then we save it
		to call it later as the http progress callback */
	if (lua_type(L, progressFnIndex) == LUA_TFUNCTION)
	{
		state->L = L;
		state->RefIndex = luaL_ref(L, LUA_REGISTRYINDEX);
	}

	curl_init();
	curl = curl_easy_init();

	if (!curl)
		return NULL;

	curl_easy_setopt(curl, CURLOPT_URL, url);
	curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
	curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);

	get_headers(L, &headers);
	curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

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

	return curl;
}


int http_get(lua_State* L)
{
	CurlCallbackState state = { 0, 0 };

	CURL* curl = curl_request(L, &state, /*fp=*/NULL, /*progressFnIndex=*/2);
	CURLcode code;

	const char* err;

	string_init(&state.S);

	if (!curl)
	{
		lua_pushnil(L);
		return 1;
	}

	code = curl_easy_perform(curl);
	if (code != CURLE_OK)
	{
		err = curl_easy_strerror(code);

		lua_pushnil(L);
		lua_pushfstring(L, err);
		return 2;
	}

	curl_easy_cleanup(curl);

	lua_pushlstring(L, state.S.ptr, state.S.len);
	return 1;
}


int http_download(lua_State* L)
{
	CurlCallbackState state = { 0, 0 };

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

	curl = curl_request(L, &state, fp, /*progressFnIndex=*/3);
	if (curl)
	{
		code = curl_easy_perform(curl);
		curl_easy_cleanup(curl);
	}

	fclose(fp);

	lua_pushstring(L, curl_easy_strerror(code));
	lua_pushnumber(L, code);
	return 2;
}

#endif

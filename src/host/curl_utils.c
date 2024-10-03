/**
* \file   curl_utils.c
* \brief  curl utilities for the http library.
* \author Copyright (c) 2017 Tom van Dijck, João Matos and the Premake project
*/
#ifdef PREMAKE_CURL

#include "curl_utils.h"
#include "premake.h"
#include <string.h>

#if LIBCURL_VERSION_NUM >= 0x072000
int curlProgressCallback(curl_state* state, curl_off_t dltotal, curl_off_t dlnow, curl_off_t ultotal, curl_off_t ulnow)
#else
int curlProgressCallback(curl_state* state, double dltotal, double dlnow, double ultotal, double ulnow)
#endif
{
	lua_State* L = state->L;

	(void)ultotal;
	(void)ulnow;

	if (dltotal == 0) return 0;

	/* retrieve the lua progress callback we saved before */
	lua_rawgeti(L, LUA_REGISTRYINDEX, state->RefIndex);
	lua_pushnumber(L, (lua_Number)dltotal);
	lua_pushnumber(L, (lua_Number)dlnow);
	int ret = premake_pcall(L, 2, LUA_MULTRET);
	if (ret != LUA_OK) {
		printLastError(L);
		return -1; // abort download
	}

	return 0;
}


size_t curlWriteCallback(char *ptr, size_t size, size_t nmemb, curl_state* state)
{
	size_t length = size * nmemb;
	premake_buffer_puts(&state->S, ptr, length);
	return length;
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


CURL* curlRequest(lua_State* L, curl_state* state, int optionsIndex, int progressFnIndex, int headersIndex)
{
	char agent[1024];
	CURL* curl;

	state->L = 0;
	state->RefIndex = 0;
	state->errorBuffer[0] = '\0';
	state->headers = NULL;
	premake_buffer_init(&state->S);

	curl_init();
	curl = curl_easy_init();

	if (!curl)
		return NULL;

	strcpy(agent, "Premake/");
	strcat(agent, PREMAKE_VERSION);

	curl_easy_setopt(curl, CURLOPT_URL, luaL_checkstring(L, 1));
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
	curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
	curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, state->errorBuffer);
	curl_easy_setopt(curl, CURLOPT_USERAGENT, agent);

	// check if the --insecure option was specified on the commandline.
	lua_getglobal(L, "_OPTIONS");
	lua_pushstring(L, "insecure");
	lua_gettable(L, -2);
	if (!lua_isnil(L, -1))
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);
	}
	lua_pop(L, 2);

	// apply all other options.
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
			else if (!strcmp(key, "proxyurl") && lua_isstring(L, -1))
			{
				curl_easy_setopt(curl, CURLOPT_PROXY, luaL_checkstring(L, -1));
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
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curlWriteCallback);

	if (state->L != 0)
	{
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, state);
#if LIBCURL_VERSION_NUM >= 0x072000
		curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, curlProgressCallback);
#else
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, curlProgressCallback);
#endif
	}

	// clear error buffer.
	state->errorBuffer[0] = 0;

	return curl;
}



void curlCleanup(CURL* curl, curl_state* state)
{
	if (state->headers)
	{
		curl_slist_free_all(state->headers);
		state->headers = 0;
	}
	curl_easy_cleanup(curl);
}


#endif

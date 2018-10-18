/**
 * \file   criteria_matches.c
 * \brief  Determine if this criteria is met by the provided filter terms.
 * \author Copyright (c) 2002-2014 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <stdlib.h>
#include <string.h>


struct Word {
	const char* word;
	const char* prefix;
	int matchesFiles;
	int assertion;
	int wildcard;
};

struct Pattern {
	int matchesFiles;
	int n;
	struct Word* word;
};

struct Patterns {
	int prefixed;
	int filePatterns;
	int n;
	struct Pattern* pattern;
};


static int criteria_compilePattern(lua_State* L, struct Pattern* pattern);


int criteria_compile(lua_State* L)
{
	struct Patterns* patterns;
	int i, n;

	/* create a Patterns object and userdata; holds a list of Pattern items */
	patterns = (struct Patterns*)lua_newuserdata(L, sizeof(struct Patterns));
	patterns->prefixed = 0;
	patterns->filePatterns = 0;

	if (luaL_newmetatable(L, "premake.criteria")) {
		lua_pushstring(L, "__gc");
		lua_pushcfunction(L, criteria_delete);
		lua_settable(L, -3);
	}
	lua_setmetatable(L, -2);

	/* create array to hold the incoming list of patterns */
	n = (int)lua_rawlen(L, 1);
	patterns->n = n;
	patterns->pattern = (struct Pattern*)malloc(sizeof(struct Pattern) * n);

	/* create a new pattern object for each incoming pattern */
	for (i = 0; i < n; ++i) {
		struct Pattern* pattern = &patterns->pattern[i];

		lua_rawgeti(L, 1, i + 1);
		criteria_compilePattern(L, pattern);
		lua_pop(L, 1);

		if (pattern->n > 0 && pattern->word[0].prefix != NULL) {
			patterns->prefixed = 1;
		}

		if (pattern->matchesFiles) {
			++patterns->filePatterns;
		}
	}

	return 1;
}


int criteria_compilePattern(lua_State* L, struct Pattern* pattern)
{
	int i, n;

	/* create array to hold the incoming list of words */
	n = (int)lua_rawlen(L, -1);
	pattern->n = n;
	pattern->word = (struct Word*)malloc(sizeof(struct Word) * n);
	pattern->matchesFiles = 0;

	for (i = 0; i < n; ++i) {
		struct Word* word = &pattern->word[i];
		word->matchesFiles = 0;

		lua_rawgeti(L, -1, i + 1);

		lua_rawgeti(L, -1, 1);
		word->word = lua_tostring(L, -1);
		lua_pop(L, 1);

		lua_rawgeti(L, -1, 2);
		word->prefix = lua_tostring(L, -1);
		lua_pop(L, 1);

		lua_rawgeti(L, -1, 3);
		word->assertion = lua_toboolean(L, -1);
		lua_pop(L, 1);

		lua_rawgeti(L, -1, 4);
		word->wildcard  = lua_toboolean(L, -1);
		lua_pop(L, 1);

		if (word->prefix && strcmp(word->prefix, "files") == 0) {
			word->matchesFiles = 1;
			pattern->matchesFiles = 1;
		}

		lua_pop(L, 1);
	}

	return 0;
}



int criteria_delete(lua_State* L)
{
	int i, n;
	struct Patterns* patterns = (struct Patterns*)lua_touserdata(L, 1);

	n = patterns->n;
	for (i = 0; i < n; ++i) {
		free(patterns->pattern[i].word);
	}
	free(patterns->pattern);

	return 0;
}



static int match(lua_State* L, const char* value, struct Word* word)
{
	if (word->wildcard) {
		/* use string.match() to compare */
		const char* result;
		int matched = 0;

		int top = lua_gettop(L);

		lua_pushvalue(L, 4);
		lua_pushstring(L, value);
		lua_pushstring(L, word->word);
		lua_call(L, 2, 1);

		if (lua_isstring(L, -1)) {
			result = lua_tostring(L, -1);
			matched = (strcmp(value, result) == 0);
		}

		lua_settop(L, top);
		return matched;
	}
	else {
		return (strcmp(value, word->word) == 0);
	}
}



/*
 * Compares the value on the top of the stack to the specified word.
 */

static int testValue(lua_State* L, struct Word* word)
{
	const char* value;
	size_t i, n;
	int result;

	if (lua_istable(L, -1)) {
		n = lua_rawlen(L, -1);
		for (i = 1; i <= n; ++i) {
			lua_rawgeti(L, -1, i);
			result = testValue(L, word);
			lua_pop(L, 1);
			if (result) {
				return 1;
			}
		}
		return 0;
	}

	value = lua_tostring(L, -1);
	if (value) {
		return match(L, value, word);
	}

	return 0;
}



static int testWithPrefix(lua_State* L, struct Word* word, const char* filename, int* fileMatched)
{
	int result;

	if (word->matchesFiles && !filename) {
		return 0;
	}

	lua_pushstring(L, word->prefix);
	lua_rawget(L, 2);
	result = testValue(L, word);
	lua_pop(L, 1);

	if (word->matchesFiles && result == word->assertion) {
		(*fileMatched) = 1;
	}

	if (result) {
		return word->assertion;
	}

	return (!word->assertion);
}



static int testNoPrefix(lua_State* L, struct Word* word, const char* filename, int* fileMatched)
{
	if (filename && word->assertion && match(L, filename, word)) {
		(*fileMatched) = 1;
		return 1;
	}

	lua_pushnil(L);
	while (lua_next(L, 2)) {
		if (testValue(L, word)) {
			lua_pop(L, 2);
			return word->assertion;
		}
		lua_pop(L, 1);
	}

	return (!word->assertion);
}



int criteria_matches(lua_State* L)
{
	/* stack [1] = criteria */
	/* stack [2] = context */

	struct Patterns* patterns;
	const char* filename;
	int i, j, fileMatched;
	int matched = 1;

	/* filename = context.files */
	lua_pushstring(L, "files");
	lua_rawget(L, 2);
	filename = lua_tostring(L, -1);
	lua_pop(L, 1);

	/* fetch the patterns to be tested */
	lua_pushstring(L, "data");
	lua_rawget(L, 1);
	patterns = (struct Patterns*)lua_touserdata(L, -1);
	lua_pop(L, 1);

	/* if a file is being matched, the pattern must be able to match it */
	if (patterns->prefixed && filename != NULL && patterns->filePatterns == 0) {
		return 0;
	}

	/* Cache string.match on the stack (at index 4) to save time in matches() later */

	lua_getglobal(L, "string");
	lua_getfield(L, -1, "match");

	/* if there is no file to consider, consider it matched */
	fileMatched = (filename == NULL);

	/* all patterns must match to pass */
	for (i = 0; matched && i < patterns->n; ++i) {
		struct Pattern* pattern = &patterns->pattern[i];

		/* only one word needs to match for the pattern to pass */
		matched = 0;

		for (j = 0; !matched && j < pattern->n; ++j) {
			struct Word* word = &pattern->word[j];
			if (word->prefix) {
				matched = testWithPrefix(L, word, filename, &fileMatched);
			}
			else {
				matched = testNoPrefix(L, word, filename, &fileMatched);
			}
		}
	}

	/* if a file name was provided in the context, it must be matched */
	if (filename && !fileMatched) {
		matched = 0;
	}

	lua_pushboolean(L, matched);
	return 1;
}

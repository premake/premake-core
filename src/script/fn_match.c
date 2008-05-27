/**
 * \file   fn_match.c
 * \brief  Perform a wildcard match for files.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"
#include "platform/platform.h"
#include "base/cstr.h"
#include "base/path.h"
#include "base/string.h"

static void do_scan(lua_State* L, const char* mask);


/**
 * Perform a wildcard match for files; returns a table of file names which
 * match the supplied pattern.
 */
int fn_match(lua_State* L)
{
	int i, n;

	/* table to hold the results */
	lua_newtable(L);

	/* scan each mask in the provided list */
	n = lua_gettop(L);
	for (i = 1; i < n; ++i)
	{
		const char* mask = luaL_checkstring(L, i);
		do_scan(L, mask);
	}

	return 1;
}


/**
 * Does the real work of scanning the file system and matching the supplied patterns.
 */
void do_scan(lua_State* L, const char* mask)
{
	/* mark the end of the results lists so I know where to add new entries */
	int n = luaL_getn(L, -1);

	/* the search will only return file names; remember the path so I can add it back */
	String dir = string_create(path_directory(mask));

	/* search */
	PlatformSearch search = platform_search_create(mask);
	while (platform_search_next(search))
	{
		const char* filename = platform_search_get_name(search);
		int is_file = platform_search_is_file(search);

		if (is_file)
		{
			/* add it to the results */
			const char* path = path_join(string_cstr(dir), filename);
			lua_pushstring(L, path);
			lua_rawseti(L, -2, ++n);
		}
	}
	platform_search_destroy(search);

	/* if the mask uses the ** pattern, recurse into subdirectories */
	if (cstr_contains(mask, "**"))
	{
		mask = path_filename(mask);

		/* look for subdirectories */
		search = platform_search_create(path_join(string_cstr(dir), "*"));
		while (platform_search_next(search))
		{
			if (!platform_search_is_file(search))
			{
				const char* dirname = platform_search_get_name(search);
				if (dirname[0] != '.')
				{
					/* build a new mask from the original directory, this new subdirectory,
					 * and the original search mask. Need to put it in a string to ensure
					 * its buffer doesn't get overwritten */
					String subsearch;
					const char* path = path_join(string_cstr(dir), dirname);
					path = path_join(path, mask);
					subsearch = string_create(path);

					/* recurse to search this subdirectory */
					do_scan(L, string_cstr(subsearch));

					string_destroy(subsearch);
				}
			}
		}
		platform_search_destroy(search);
	}

	string_destroy(dir);
}

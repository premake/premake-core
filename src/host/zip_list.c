#include "premake.h"

#ifdef PREMAKE_COMPRESSION

#include "zip.h"

int zip_list(lua_State* L)
{
    const char* src = luaL_checkstring(L, 1);

    int err = 0;
    struct zip* z_archive = zip_open(src, 0, &err);

    if(!z_archive)
    {
        lua_newtable(L);
        lua_pushstring(L, "Cannot open file");
        return 2;
    }
    const zip_int64_t entries_count = zip_get_num_entries(z_archive, 0);
    lua_createtable(L, entries_count, 0);
    for(zip_int64_t i = 0; i != entries_count; ++i)
    {
        const char* full_name = zip_get_name(z_archive, i, 0);
        lua_pushstring(L, full_name);
        lua_rawseti(L, -2, i);
    }
    zip_close(z_archive);
    lua_pushnil(L);
    return 2;
}

#endif

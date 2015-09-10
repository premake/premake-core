/**
* \file   json.c
* \brief  JSON parsing with Jansson library.
* \author Copyright (c) 2015 Joao Matos and the Premake project
* Lua bindings based on code from https://github.com/Twisol/lua_jansson
*/

#include "premake.h"

#ifdef PREMAKE_JSON

#include "jansson.h"

// Metatable identifier in the Lua registry
static const char* json_metaname = "jansson.json";

// JSON null value
static json_t** jsonlua_null = NULL;

/***************************************************
Private utility methods
***************************************************/

// Calculates the largest whole-number index of a table.
static lua_Integer table_maxn(lua_State* L, int stack_idx)
{
    // L:  ...
    luaL_checkstack(L, 2, "Nested too deep!");

    lua_Integer max = 0, num = 0;
    lua_Number dbl = 0;

    lua_pushnil(L); // first key
    if (stack_idx < 0) --stack_idx; // adjust table index
    // L: ... nil
    while (lua_next(L, stack_idx) != 0)
    {
        // L: ... key, value
        lua_pop(L, 1); // don't need value
        // L: ... key
        if (lua_type(L, -1) == LUA_TNUMBER)
        {
            dbl = lua_tonumber(L, -1);
            num = lua_tointeger(L, -1);

            if (num == dbl && num > max)
                max = num;
        }
    }
    // L: ...

    return max;
}

enum {
	JSON_TYPE_UNCERTAIN = 0,
	JSON_TYPE_ARRAY,
	JSON_TYPE_OBJECT,
	JSON_TYPE_INVALID,
};

// Returns 1 if it's a JSON array, 2 if it's a JSON object,
// 3 if it's invalid, and 0 for uncertain (empty table {})
static unsigned char lua_table_json_type(lua_State* L)
{
    // L: ... table

    luaL_checkstack(L, 2, "Nested too deep!");

    unsigned int numArrayEntries = 0;
    unsigned char type = 0;
    int ltype;

    lua_pushnil(L); // first key
    // L: ... table, nil
    while (lua_next(L, -2) != 0)
    {
        // L: .. table, key, value
        lua_pop(L, 1); // don't need the value
        // L: .. table, key
        ltype = lua_type(L, -1);

        if (type != 2 && ltype == LUA_TNUMBER)
        {
            if (type != 1) type = 1;
        }
        else if (type != 1 && ltype == LUA_TSTRING)
        {
            if (type != 2) type = 2;
        }
        else
        {
            type = 3;
            break;
        }
    }
    // L: ... table

    return type;
}

// Pushes a JSON object to the Lua stack
static void push_json_udata(lua_State* L, json_t* obj)
{
    if (json_is_null(obj))
    {
        lua_pushlightuserdata(L, jsonlua_null);
        lua_gettable(L, LUA_REGISTRYINDEX);
    }
    else
    {
        json_t** ud = (json_t**)lua_newuserdata(L, sizeof(json_t*));
        luaL_getmetatable(L, json_metaname);
        lua_setmetatable(L, -2);
        *ud = obj;
    }
}

/***************************************************
JSON encoding implementation
***************************************************/

static json_t* encode_lua_data(lua_State* L);

static json_t* encode_lua_table_array(lua_State* L)
{
    // L: ... table

    luaL_checkstack(L, 2, "Nested too deep!");

    json_t* obj = json_array();
    if (!obj)
    {
        lua_pushliteral(L, "Unknown JSON error while encoding.");
        lua_error(L);
    }

    // Push it to the stack in case the Lua stack overflows while inserting members.
    push_json_udata(L, obj);
    // L: ... table, udata

    json_t* member = NULL;
    for (lua_Integer i = 1; i <= table_maxn(L, -2); ++i)
    {
        lua_pushnumber(L, i);
        // L: ... table, udata, index
        lua_gettable(L, -3);
        // L: ... table, udata, value

        member = encode_lua_data(L);
        if (!member || json_array_append_new(obj, member) != 0)
        {
            lua_pushliteral(L, "Unknown JSON error while encoding.");
            lua_error(L);
        }

        lua_pop(L, 1);
        // L: ... table, udata
    }

    json_incref(obj); // add a reference for when it's GC'd
    lua_pop(L, 1);
    // L: ... table

    return obj;
}

static json_t* encode_lua_table_object(lua_State* L)
{
    // L: ... table

    luaL_checkstack(L, 2, "Nested too deep!");

    json_t* obj = json_object();
    if (!obj)
    {
        lua_pushliteral(L, "Unable to create json_object for unknown reason.");
        lua_error(L);
    }

    // Push it to the stack in case the Lua stack overflows while inserting members.
    push_json_udata(L, obj);
    // L: ... table, udata

    json_t* member = NULL;
    lua_pushnil(L); // first key
    // L: ... table, udata, nil
    while (lua_next(L, -3) != 0)
    {
        // L: ... table, udata, key, value
        if (lua_type(L, -2) == LUA_TSTRING)
        {
            member = encode_lua_data(L);
            if (!member || json_object_set_new(obj, lua_tostring(L, -2), member) != 0)
            {
                lua_pushliteral(L, "Unknown JSON error while encoding.");
                lua_error(L);
            }
        }
        lua_pop(L, 1);
        // L: ... table, udata, key
    }
    // L: ... table, udata

    json_incref(obj); // add a reference for when it's GC'd
    lua_pop(L, 1);
    // L: ... table

    return obj;
}

static json_t* encode_lua_table(lua_State* L)
{
    // L: ... table

    json_t* obj = NULL;

    switch (lua_table_json_type(L))
    {
    case 0:
        luaL_error(L, "Ambiguity: empty table could be either array or object.");
        break;
    case 1:
        obj = encode_lua_table_array(L);
        break;
    case 2:
        obj = encode_lua_table_object(L);
        break;
    case 3:
        luaL_error(L, "Unable to convert mixed table!");
        break;
    }

    return obj;
}

static json_t* encode_lua_json_udata(lua_State* L)
{
    json_t* obj = *((json_t**)lua_touserdata(L, -1));

    // increment the reference count
    json_incref(obj);

    // return the same object
    return obj;
}

static json_t* encode_lua_number(lua_State* L)
{
    // L: ... number
    lua_Number dbl = lua_tonumber(L, -1);
    lua_Integer num = lua_tointeger(L, -1);

    if (num == dbl)
        return json_integer(num);
    else
        return json_real(dbl);
}

static json_t* encode_lua_data(lua_State* L)
{
    // L: ... item

    int ltype = lua_type(L, -1);
    switch (ltype)
    {
    case LUA_TUSERDATA:
    {
        luaL_getmetatable(L, json_metaname);
        lua_getmetatable(L, -2);
        int is_json = lua_rawequal(L, -1, -2);
        lua_pop(L, 2);

        if (is_json)
            return encode_lua_json_udata(L);
        break;
    }
    case LUA_TTABLE:
        return encode_lua_table(L);
    case LUA_TNUMBER:
        return encode_lua_number(L);
    case LUA_TSTRING:
        return json_string(lua_tostring(L, -1));
    case LUA_TBOOLEAN:
        return (lua_toboolean(L, -1) ? json_true() : json_false());
    case LUA_TNIL:
        return json_null();
    }

    luaL_error(L, "Invalid data type: %s", lua_typename(L, ltype));
    return NULL; // never reached
}

/***************************************************
JSON decoding implementation
***************************************************/

static void decode_json_data(lua_State* L, json_t* obj);

static void decode_json_object(lua_State* L, json_t* obj)
{
    luaL_checkstack(L, 3, "Nested too deep!");

    lua_newtable(L);
    void* itr = json_object_iter(obj);
    const char* key = NULL;
    json_t* val = NULL;

    while (itr)
    {
        key = json_object_iter_key(itr);
        val = json_object_iter_value(itr);

        lua_pushstring(L, key);
        decode_json_data(L, val);
        lua_rawset(L, -3);

        itr = json_object_iter_next(obj, itr);
    }
}

static void decode_json_array(lua_State* L, json_t* obj)
{
    luaL_checkstack(L, 3, "Nested too deep!");

    lua_newtable(L);
    for (size_t i = 0; i < json_array_size(obj); ++i)
    {
        lua_pushinteger(L, i + 1);
        decode_json_data(L, json_array_get(obj, i));
        lua_rawset(L, -3);
    }
}

static void decode_json_data(lua_State* L, json_t* obj)
{
    switch (json_typeof(obj))
    {
    case JSON_OBJECT:
        decode_json_object(L, obj);
        break;
    case JSON_ARRAY:
        decode_json_array(L, obj);
        break;
    case JSON_STRING:
        lua_pushstring(L, json_string_value(obj));
        break;
    case JSON_REAL:
        lua_pushnumber(L, json_real_value(obj));
        break;
    case JSON_INTEGER:
        lua_pushinteger(L, json_integer_value(obj));
        break;
    case JSON_TRUE:
        lua_pushboolean(L, 1);
        break;
    case JSON_FALSE:
        lua_pushboolean(L, 0);
        break;
    case JSON_NULL:
        push_json_udata(L, json_null());
        break;
    }
}

/***************************************************
JSON library methods
***************************************************/

// Converts a Lua datum into a JSON string
static int Ljson_encode(lua_State* L)
{
    lua_settop(L, 2);
    // L: item, flags
    lua_Integer flags = 0;
    if (!lua_isnoneornil(L, 2))
        flags = luaL_checkinteger(L, 2);
    lua_pop(L, 1);
    json_t* obj = encode_lua_data(L);

    char* json = json_dumps(obj, flags);
    if (!json)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "Unable to encode JSON for an unknown reason.");
        return 2;
    }
    else
    {
        lua_pushstring(L, json);
        free(json);
        return 1;
    }
}

// Converts a JSON string into a Lua datum
static int Ljson_decode(lua_State* L)
{
    lua_settop(L, 1);
    // L: json
    json_t* obj = NULL;

    if (lua_isuserdata(L, 1) && !lua_islightuserdata(L, 1))
    {
        obj = *((json_t**)luaL_checkudata(L, 1, json_metaname));
    }
    else
    {
        json_error_t error;
        obj = json_loads(luaL_checkstring(L, 1), 0, &error);
        if (!obj)
        {
            lua_pushnil(L);
            lua_pushstring(L, error.text);
            lua_pushinteger(L, error.line);
            return 3;
        }
    }

    decode_json_data(L, obj);
    return 1;
}

// Converts a Lua table as a JSON array into a compiled JSON chunk
static int Ljson_as_array(lua_State* L)
{
    lua_settop(L, 1);
    luaL_argcheck(L, lua_type(L, 1) == LUA_TTABLE, 1, "expected table");
    json_t* obj = encode_lua_table_array(L);
    lua_pop(L, 1);

    push_json_udata(L, obj);
    return 1;
}

// Converts a Lua table as a JSON object into a compiled JSON chunk
static int Ljson_as_object(lua_State* L)
{
    lua_settop(L, 1);
    luaL_argcheck(L, lua_type(L, 1) == LUA_TTABLE, 1, "expected table");
    json_t* obj = encode_lua_table_object(L);
    lua_pop(L, 1);

    push_json_udata(L, obj);
    return 1;
}

// Calculates indent level flag
static int Ljson_indent_flag(lua_State* L)
{
    lua_settop(L, 1);
    int indent = luaL_checkinteger(L, 1);
    lua_pushinteger(L, JSON_INDENT(indent));
    return 1;
}

/***************************************************
JSON object meta table and methods
***************************************************/

// Cleans up the JSON chunk once it's no longer accessible
static int Ljson_gc_(lua_State* L)
{
    json_t* obj = *((json_t**)luaL_checkudata(L, 1, json_metaname));
    lua_pop(L, 1);
    json_decref(obj);
    return 0;
}

static int Ljson_tostring_(lua_State* L)
{
    json_t** obj = (json_t**)luaL_checkudata(L, 1, json_metaname);
    lua_pop(L, 1);

    switch (json_typeof(*obj))
    {
    case JSON_OBJECT:
        lua_pushfstring(L, "json: object (%p)", *obj);
        break;
    case JSON_ARRAY:
        lua_pushfstring(L, "json: array (%p)", *obj);
        break;
    case JSON_NULL:
        lua_pushliteral(L, "json: null");
        break;
    default:
        lua_pushfstring(L, "json: unknown (%p)", *obj);
        break;
    }

    return 1;
}

static const luaL_Reg json_meta[] = {
    { "__gc", &Ljson_gc_ },
    { "__tostring", &Ljson_tostring_ },
    { NULL, NULL }
};


/***************************************************
Library setup data
***************************************************/

static const luaL_Reg json_lib[] = {
    { "encode", &Ljson_encode },
    { "decode", &Ljson_decode },
    { "array", &Ljson_as_array },
    { "object", &Ljson_as_object },
    { NULL, NULL }
};

int premake_init_json(lua_State *L)
{
    // Create JSON object metatable
    luaL_newmetatable(L, json_metaname);   /* create new metatable */
    lua_pushliteral(L, "__index");
    lua_pushvalue(L, -2);         /* push metatable */
    lua_rawset(L, -3);            /* metatable.__index = metatable */

    luaL_register(L, NULL, json_meta);
    lua_pop(L, 1);

    // register 'json' library
    luaL_register(L, "json", json_lib);

    // add "null" JSON item
    lua_pushliteral(L, "null");
    // json, "null"
    jsonlua_null = (json_t**)lua_newuserdata(L, sizeof(json_t*));
    luaL_getmetatable(L, json_metaname);
    lua_setmetatable(L, -2);
    *jsonlua_null = json_null();
    // json, "null", null

    // stick it in the registry
    lua_pushlightuserdata(L, jsonlua_null);
    // json, "null", null, light
    lua_pushvalue(L, -2);
    // json, "null", null, light, null
    lua_settable(L, LUA_REGISTRYINDEX);
    // json, "null", null

    lua_rawset(L, -3);
    // json

    // Add encoding flags
    lua_pushliteral(L, "INDENT");
    lua_pushcfunction(L, &Ljson_indent_flag);
    lua_settable(L, -3);

    lua_pushliteral(L, "COMPACT");
    lua_pushinteger(L, JSON_COMPACT);
    lua_settable(L, -3);

    lua_pushliteral(L, "ENSURE_ASCII");
    lua_pushinteger(L, JSON_ENSURE_ASCII);
    lua_settable(L, -3);

    lua_pushliteral(L, "SORT_KEYS");
    lua_pushinteger(L, JSON_SORT_KEYS);
    lua_settable(L, -3);

    return 1;
}

#endif

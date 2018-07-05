/**
* \file   luashim.h
* \brief  Lua shim for premake binary modules.
* \author Copyright (c) 2017 Tom van Dijck and the Premake project
*/
#ifndef HEADER_luashim_H
#define HEADER_luashim_H

#include "lua.h"
#include "lauxlib.h"

// premake specific helper methods.
void luaL_register(lua_State *L, const char *libname, const luaL_Reg *l);
void shimInitialize(lua_State* L);

typedef struct {
	void              (*shimL_register)(lua_State *L, const char *libname, const luaL_Reg *l);
	lua_State*        (*shim_newstate)(lua_Alloc f, void* ud);
	void              (*shim_close)(lua_State* L);
	lua_State*        (*shim_newthread)(lua_State* L);
	lua_CFunction     (*shim_atpanic)(lua_State* L, lua_CFunction panicf);
	const lua_Number* (*shim_version)(lua_State* L);
	int               (*shim_absindex)(lua_State* L, int idx);
	int               (*shim_gettop)(lua_State* L);
	void              (*shim_settop)(lua_State* L, int idx);
	void              (*shim_pushvalue)(lua_State* L, int idx);
	void              (*shim_rotate)(lua_State* L, int idx, int n);
	void              (*shim_copy)(lua_State* L, int fromidx, int toidx);
	int               (*shim_checkstack)(lua_State* L, int n);
	void              (*shim_xmove)(lua_State* from, lua_State* to, int n);
	int               (*shim_isnumber)(lua_State* L, int idx);
	int               (*shim_isstring)(lua_State* L, int idx);
	int               (*shim_iscfunction)(lua_State* L, int idx);
	int               (*shim_isinteger)(lua_State* L, int idx);
	int               (*shim_isuserdata)(lua_State* L, int idx);
	int               (*shim_type)(lua_State* L, int idx);
	const char*       (*shim_typename)(lua_State* L, int tp);
	lua_Number        (*shim_tonumberx)(lua_State* L, int idx, int* isnum);
	lua_Integer       (*shim_tointegerx)(lua_State* L, int idx, int* isnum);
	int               (*shim_toboolean)(lua_State* L, int idx);
	const char*       (*shim_tolstring)(lua_State* L, int idx, size_t* len);
	size_t            (*shim_rawlen)(lua_State* L, int idx);
	lua_CFunction     (*shim_tocfunction)(lua_State* L, int idx);
	void*             (*shim_touserdata)(lua_State* L, int idx);
	lua_State*        (*shim_tothread)(lua_State* L, int idx);
	const void*       (*shim_topointer)(lua_State* L, int idx);
	void              (*shim_arith)(lua_State* L, int op);
	int               (*shim_rawequal)(lua_State* L, int idx1, int idx2);
	int               (*shim_compare)(lua_State* L, int idx1, int idx2, int op);
	void              (*shim_pushnil)(lua_State* L);
	void              (*shim_pushnumber)(lua_State* L, lua_Number n);
	void              (*shim_pushinteger)(lua_State* L, lua_Integer n);
	const char*       (*shim_pushlstring)(lua_State* L, const char* s, size_t len);
	const char*       (*shim_pushstring)(lua_State* L, const char* s);
	const char*       (*shim_pushvfstring)(lua_State* L, const char* fmt, va_list argp);
	void              (*shim_pushcclosure)(lua_State* L, lua_CFunction fn, int n);
	void              (*shim_pushboolean)(lua_State* L, int b);
	void              (*shim_pushlightuserdata)(lua_State* L, void* p);
	int               (*shim_pushthread)(lua_State* L);
	int               (*shim_getglobal)(lua_State* L, const char* name);
	int               (*shim_gettable)(lua_State* L, int idx);
	int               (*shim_getfield)(lua_State* L, int idx, const char* k);
	int               (*shim_geti)(lua_State* L, int idx, lua_Integer n);
	int               (*shim_rawget)(lua_State* L, int idx);
	int               (*shim_rawgeti)(lua_State* L, int idx, lua_Integer n);
	int               (*shim_rawgetp)(lua_State* L, int idx, const void* p);
	void              (*shim_createtable)(lua_State* L, int narr, int nrec);
	void*             (*shim_newuserdata)(lua_State* L, size_t sz);
	int               (*shim_getmetatable)(lua_State* L, int objindex);
	int               (*shim_getuservalue)(lua_State* L, int idx);
	void              (*shim_setglobal)(lua_State* L, const char* name);
	void              (*shim_settable)(lua_State* L, int idx);
	void              (*shim_setfield)(lua_State* L, int idx, const char* k);
	void              (*shim_seti)(lua_State* L, int idx, lua_Integer n);
	void              (*shim_rawset)(lua_State* L, int idx);
	void              (*shim_rawseti)(lua_State* L, int idx, lua_Integer n);
	void              (*shim_rawsetp)(lua_State* L, int idx, const void* p);
	int               (*shim_setmetatable)(lua_State* L, int objindex);
	void              (*shim_setuservalue)(lua_State* L, int idx);
	void              (*shim_callk)(lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k);
	int               (*shim_pcallk)(lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k);
	int               (*shim_load)(lua_State* L, lua_Reader reader, void* dt, const char* chunkname, const char* mode);
	int               (*shim_dump)(lua_State* L, lua_Writer writer, void* data, int strip);
	int               (*shim_yieldk)(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k);
	int               (*shim_resume)(lua_State* L, lua_State* from, int narg);
	int               (*shim_status)(lua_State* L);
	int               (*shim_isyieldable)(lua_State* L);
	int               (*shim_gc)(lua_State* L, int what, int data);
	int               (*shim_error)(lua_State* L);
	int               (*shim_next)(lua_State* L, int idx);
	void              (*shim_concat)(lua_State* L, int n);
	void              (*shim_len)(lua_State* L, int idx);
	size_t            (*shim_stringtonumber)(lua_State* L, const char* s);
	lua_Alloc         (*shim_getallocf)(lua_State* L, void** ud);
	void              (*shim_setallocf)(lua_State* L, lua_Alloc f, void* ud);
	int               (*shim_getstack)(lua_State* L, int level, lua_Debug* ar);
	int               (*shim_getinfo)(lua_State* L, const char* what, lua_Debug* ar);
	const char*       (*shim_getlocal)(lua_State* L, const lua_Debug* ar, int n);
	const char*       (*shim_setlocal)(lua_State* L, const lua_Debug* ar, int n);
	const char*       (*shim_getupvalue)(lua_State* L, int funcindex, int n);
	const char*       (*shim_setupvalue)(lua_State* L, int funcindex, int n);
	void*             (*shim_upvalueid)(lua_State* L, int fidx, int n);
	void              (*shim_upvaluejoin)(lua_State* L, int fidx1, int n1, int fidx2, int n2);
	void              (*shim_sethook)(lua_State* L, lua_Hook func, int mask, int count);
	lua_Hook          (*shim_gethook)(lua_State* L);
	int               (*shim_gethookmask)(lua_State* L);
	int               (*shim_gethookcount)(lua_State* L);
	void              (*shimL_checkversion_)(lua_State* L, lua_Number ver, size_t sz);
	int               (*shimL_getmetafield)(lua_State* L, int obj, const char* e);
	int               (*shimL_callmeta)(lua_State* L, int obj, const char* e);
	const char*       (*shimL_tolstring)(lua_State* L, int idx, size_t* len);
	int               (*shimL_argerror)(lua_State* L, int arg, const char* extramsg);
	const char*       (*shimL_checklstring)(lua_State* L, int arg, size_t* l);
	const char*       (*shimL_optlstring)(lua_State* L, int arg, const char* def, size_t* l);
	lua_Number        (*shimL_checknumber)(lua_State* L, int arg);
	lua_Number        (*shimL_optnumber)(lua_State* L, int arg, lua_Number def);
	lua_Integer       (*shimL_checkinteger)(lua_State* L, int arg);
	lua_Integer       (*shimL_optinteger)(lua_State* L, int arg, lua_Integer def);
	void              (*shimL_checkstack)(lua_State* L, int sz, const char* msg);
	void              (*shimL_checktype)(lua_State* L, int arg, int t);
	void              (*shimL_checkany)(lua_State* L, int arg);
	int               (*shimL_newmetatable)(lua_State* L, const char* tname);
	void              (*shimL_setmetatable)(lua_State* L, const char* tname);
	void*             (*shimL_testudata)(lua_State* L, int ud, const char* tname);
	void*             (*shimL_checkudata)(lua_State* L, int ud, const char* tname);
	void              (*shimL_where)(lua_State* L, int lvl);
	int               (*shimL_checkoption)(lua_State* L, int arg, const char* def, const char* const lst[]);
	int               (*shimL_fileresult)(lua_State* L, int stat, const char* fname);
	int               (*shimL_execresult)(lua_State* L, int stat);
	int               (*shimL_ref)(lua_State* L, int t);
	void              (*shimL_unref)(lua_State* L, int t, int ref);
	int               (*shimL_loadfilex)(lua_State* L, const char* filename, const char* mode);
	int               (*shimL_loadbufferx)(lua_State* L, const char* buff, size_t sz, const char* name, const char* mode);
	int               (*shimL_loadstring)(lua_State* L, const char* s);
	lua_State*        (*shimL_newstate)();
	lua_Integer       (*shimL_len)(lua_State* L, int idx);
	const char*       (*shimL_gsub)(lua_State* L, const char* s, const char* p, const char* r);
	void              (*shimL_setfuncs)(lua_State* L, const luaL_Reg* l, int nup);
	int               (*shimL_getsubtable)(lua_State* L, int idx, const char* fname);
	void              (*shimL_traceback)(lua_State* L, lua_State* L1, const char* msg, int level);
	void              (*shimL_requiref)(lua_State* L, const char* modname, lua_CFunction openf, int glb);
	void              (*shimL_buffinit)(lua_State* L, luaL_Buffer* B);
	char*             (*shimL_prepbuffsize)(luaL_Buffer* B, size_t sz);
	void              (*shimL_addlstring)(luaL_Buffer* B, const char* s, size_t l);
	void              (*shimL_addstring)(luaL_Buffer* B, const char* s);
	void              (*shimL_addvalue)(luaL_Buffer* B);
	void              (*shimL_pushresult)(luaL_Buffer* B);
	void              (*shimL_pushresultsize)(luaL_Buffer* B, size_t sz);
	char*             (*shimL_buffinitsize)(lua_State* L, luaL_Buffer* B, size_t sz);
} LuaFunctionTable_t;

#endif

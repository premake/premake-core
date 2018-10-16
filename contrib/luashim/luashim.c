/**
* \file   luashim.c
* \brief  Lua shim for premake binary modules.
* \author Copyright (c) 2017 Tom van Dijck and the Premake project
*/
#include "luashim.h"
#include <assert.h>
#include "lstate.h"

static const LuaFunctionTable_t* g_shimTable;

void luaL_register(lua_State *L, const char *libname, const luaL_Reg *l)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_register(L, libname, l);
}

lua_State* lua_newstate(lua_Alloc f, void* ud)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_newstate(f, ud);
}

void lua_close(lua_State* L)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_close(L);
}

lua_State* lua_newthread(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_newthread(L);
}

lua_CFunction lua_atpanic(lua_State* L, lua_CFunction panicf)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_atpanic(L, panicf);
}

const lua_Number* lua_version(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_version(L);
}

int lua_absindex(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_absindex(L, idx);
}

int lua_gettop(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gettop(L);
}

void lua_settop(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_settop(L, idx);
}

void lua_pushvalue(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushvalue(L, idx);
}

void lua_rotate(lua_State* L, int idx, int n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_rotate(L, idx, n);
}

void lua_copy(lua_State* L, int fromidx, int toidx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_copy(L, fromidx, toidx);
}

int lua_checkstack(lua_State* L, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_checkstack(L, n);
}

void lua_xmove(lua_State* from, lua_State* to, int n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_xmove(from, to, n);
}

int lua_isnumber(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_isnumber(L, idx);
}

int lua_isstring(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_isstring(L, idx);
}

int lua_iscfunction(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_iscfunction(L, idx);
}

int lua_isinteger(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_isinteger(L, idx);
}

int lua_isuserdata(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_isuserdata(L, idx);
}

int lua_type(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_type(L, idx);
}

const char* lua_typename(lua_State* L, int tp)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_typename(L, tp);
}

lua_Number lua_tonumberx(lua_State* L, int idx, int* isnum)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_tonumberx(L, idx, isnum);
}

lua_Integer lua_tointegerx(lua_State* L, int idx, int* isnum)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_tointegerx(L, idx, isnum);
}

int lua_toboolean(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_toboolean(L, idx);
}

const char* lua_tolstring(lua_State* L, int idx, size_t* len)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_tolstring(L, idx, len);
}

size_t lua_rawlen(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_rawlen(L, idx);
}

lua_CFunction lua_tocfunction(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_tocfunction(L, idx);
}

void* lua_touserdata(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_touserdata(L, idx);
}

lua_State* lua_tothread(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_tothread(L, idx);
}

const void* lua_topointer(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_topointer(L, idx);
}

void lua_arith(lua_State* L, int op)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_arith(L, op);
}

int lua_rawequal(lua_State* L, int idx1, int idx2)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_rawequal(L, idx1, idx2);
}

int lua_compare(lua_State* L, int idx1, int idx2, int op)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_compare(L, idx1, idx2, op);
}

void lua_pushnil(lua_State* L)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushnil(L);
}

void lua_pushnumber(lua_State* L, lua_Number n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushnumber(L, n);
}

void lua_pushinteger(lua_State* L, lua_Integer n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushinteger(L, n);
}

const char* lua_pushlstring(lua_State* L, const char* s, size_t len)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_pushlstring(L, s, len);
}

const char* lua_pushstring(lua_State* L, const char* s)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_pushstring(L, s);
}

const char* lua_pushvfstring(lua_State* L, const char* fmt, va_list argp)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_pushvfstring(L, fmt, argp);
}

const char* lua_pushfstring(lua_State* L, const char* fmt, ...)
{
	const char* ret;
	va_list argp;
	va_start(argp, fmt);
	ret = lua_pushvfstring(L, fmt, argp);
	va_end(argp);
	return ret;
}

void lua_pushcclosure(lua_State* L, lua_CFunction fn, int n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushcclosure(L, fn, n);
}

void lua_pushboolean(lua_State* L, int b)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushboolean(L, b);
}

void lua_pushlightuserdata(lua_State* L, void* p)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_pushlightuserdata(L, p);
}

int lua_pushthread(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_pushthread(L);
}

int lua_getglobal(lua_State* L, const char* name)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getglobal(L, name);
}

int lua_gettable(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gettable(L, idx);
}

int lua_getfield(lua_State* L, int idx, const char* k)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getfield(L, idx, k);
}

int lua_geti(lua_State* L, int idx, lua_Integer n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_geti(L, idx, n);
}

int lua_rawget(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_rawget(L, idx);
}

int lua_rawgeti(lua_State* L, int idx, lua_Integer n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_rawgeti(L, idx, n);
}

int lua_rawgetp(lua_State* L, int idx, const void* p)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_rawgetp(L, idx, p);
}

void lua_createtable(lua_State* L, int narr, int nrec)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_createtable(L, narr, nrec);
}

void* lua_newuserdata(lua_State* L, size_t sz)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_newuserdata(L, sz);
}

int lua_getmetatable(lua_State* L, int objindex)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getmetatable(L, objindex);
}

int lua_getuservalue(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getuservalue(L, idx);
}

void lua_setglobal(lua_State* L, const char* name)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_setglobal(L, name);
}

void lua_settable(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_settable(L, idx);
}

void lua_setfield(lua_State* L, int idx, const char* k)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_setfield(L, idx, k);
}

void lua_seti(lua_State* L, int idx, lua_Integer n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_seti(L, idx, n);
}

void lua_rawset(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_rawset(L, idx);
}

void lua_rawseti(lua_State* L, int idx, lua_Integer n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_rawseti(L, idx, n);
}

void lua_rawsetp(lua_State* L, int idx, const void* p)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_rawsetp(L, idx, p);
}

int lua_setmetatable(lua_State* L, int objindex)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_setmetatable(L, objindex);
}

void lua_setuservalue(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_setuservalue(L, idx);
}

void lua_callk(lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_callk(L, nargs, nresults, ctx, k);
}

int lua_pcallk(lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_pcallk(L, nargs, nresults, errfunc, ctx, k);
}

int lua_load(lua_State* L, lua_Reader reader, void* dt, const char* chunkname, const char* mode)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_load(L, reader, dt, chunkname, mode);
}

int lua_dump(lua_State* L, lua_Writer writer, void* data, int strip)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_dump(L, writer, data, strip);
}

int lua_yieldk(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_yieldk(L, nresults, ctx, k);
}

int lua_resume(lua_State* L, lua_State* from, int narg)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_resume(L, from, narg);
}

int lua_status(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_status(L);
}

int lua_isyieldable(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_isyieldable(L);
}

int lua_gc(lua_State* L, int what, int data)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gc(L, what, data);
}

int lua_error(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_error(L);
}

int lua_next(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_next(L, idx);
}

void lua_concat(lua_State* L, int n)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_concat(L, n);
}

void lua_len(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_len(L, idx);
}

size_t lua_stringtonumber(lua_State* L, const char* s)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_stringtonumber(L, s);
}

lua_Alloc lua_getallocf(lua_State* L, void** ud)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getallocf(L, ud);
}

void lua_setallocf(lua_State* L, lua_Alloc f, void* ud)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_setallocf(L, f, ud);
}

int lua_getstack(lua_State* L, int level, lua_Debug* ar)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getstack(L, level, ar);
}

int lua_getinfo(lua_State* L, const char* what, lua_Debug* ar)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getinfo(L, what, ar);
}

const char* lua_getlocal(lua_State* L, const lua_Debug* ar, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getlocal(L, ar, n);
}

const char* lua_setlocal(lua_State* L, const lua_Debug* ar, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_setlocal(L, ar, n);
}

const char* lua_getupvalue(lua_State* L, int funcindex, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_getupvalue(L, funcindex, n);
}

const char* lua_setupvalue(lua_State* L, int funcindex, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_setupvalue(L, funcindex, n);
}

void* lua_upvalueid(lua_State* L, int fidx, int n)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_upvalueid(L, fidx, n);
}

void lua_upvaluejoin(lua_State* L, int fidx1, int n1, int fidx2, int n2)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_upvaluejoin(L, fidx1, n1, fidx2, n2);
}

void lua_sethook(lua_State* L, lua_Hook func, int mask, int count)
{
	assert(g_shimTable != NULL);
	g_shimTable->shim_sethook(L, func, mask, count);
}

lua_Hook lua_gethook(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gethook(L);
}

int lua_gethookmask(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gethookmask(L);
}

int lua_gethookcount(lua_State* L)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shim_gethookcount(L);
}

void luaL_checkversion_(lua_State* L, lua_Number ver, size_t sz)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_checkversion_(L, ver, sz);
}

int luaL_getmetafield(lua_State* L, int obj, const char* e)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_getmetafield(L, obj, e);
}

int luaL_callmeta(lua_State* L, int obj, const char* e)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_callmeta(L, obj, e);
}

const char* luaL_tolstring(lua_State* L, int idx, size_t* len)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_tolstring(L, idx, len);
}

int luaL_argerror(lua_State* L, int arg, const char* extramsg)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_argerror(L, arg, extramsg);
}

const char* luaL_checklstring(lua_State* L, int arg, size_t* l)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_checklstring(L, arg, l);
}

const char* luaL_optlstring(lua_State* L, int arg, const char* def, size_t* l)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_optlstring(L, arg, def, l);
}

lua_Number luaL_checknumber(lua_State* L, int arg)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_checknumber(L, arg);
}

lua_Number luaL_optnumber(lua_State* L, int arg, lua_Number def)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_optnumber(L, arg, def);
}

lua_Integer luaL_checkinteger(lua_State* L, int arg)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_checkinteger(L, arg);
}

lua_Integer luaL_optinteger(lua_State* L, int arg, lua_Integer def)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_optinteger(L, arg, def);
}

void luaL_checkstack(lua_State* L, int sz, const char* msg)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_checkstack(L, sz, msg);
}

void luaL_checktype(lua_State* L, int arg, int t)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_checktype(L, arg, t);
}

void luaL_checkany(lua_State* L, int arg)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_checkany(L, arg);
}

int luaL_newmetatable(lua_State* L, const char* tname)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_newmetatable(L, tname);
}

void luaL_setmetatable(lua_State* L, const char* tname)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_setmetatable(L, tname);
}

void* luaL_testudata(lua_State* L, int ud, const char* tname)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_testudata(L, ud, tname);
}

void* luaL_checkudata(lua_State* L, int ud, const char* tname)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_checkudata(L, ud, tname);
}

void luaL_where(lua_State* L, int lvl)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_where(L, lvl);
}

int luaL_error(lua_State* L, const char* fmt, ...)
{
	va_list argp;
	va_start(argp, fmt);
	luaL_where(L, 1);
	lua_pushvfstring(L, fmt, argp);
	va_end(argp);
	lua_concat(L, 2);
	return lua_error(L);
}

int luaL_checkoption(lua_State* L, int arg, const char* def, const char* const lst[])
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_checkoption(L, arg, def, lst);
}

int luaL_fileresult(lua_State* L, int stat, const char* fname)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_fileresult(L, stat, fname);
}

int luaL_execresult(lua_State* L, int stat)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_execresult(L, stat);
}

int luaL_ref(lua_State* L, int t)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_ref(L, t);
}

void luaL_unref(lua_State* L, int t, int ref)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_unref(L, t, ref);
}

int luaL_loadfilex(lua_State* L, const char* filename, const char* mode)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_loadfilex(L, filename, mode);
}

int luaL_loadbufferx(lua_State* L, const char* buff, size_t sz, const char* name, const char* mode)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_loadbufferx(L, buff, sz, name, mode);
}

int luaL_loadstring(lua_State* L, const char* s)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_loadstring(L, s);
}

lua_State* luaL_newstate()
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_newstate();
}

lua_Integer luaL_len(lua_State* L, int idx)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_len(L, idx);
}

const char* luaL_gsub(lua_State* L, const char* s, const char* p, const char* r)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_gsub(L, s, p, r);
}

void luaL_setfuncs(lua_State* L, const luaL_Reg* l, int nup)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_setfuncs(L, l, nup);
}

int luaL_getsubtable(lua_State* L, int idx, const char* fname)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_getsubtable(L, idx, fname);
}

void luaL_traceback(lua_State* L, lua_State* L1, const char* msg, int level)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_traceback(L, L1, msg, level);
}

void luaL_requiref(lua_State* L, const char* modname, lua_CFunction openf, int glb)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_requiref(L, modname, openf, glb);
}

void luaL_buffinit(lua_State* L, luaL_Buffer* B)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_buffinit(L, B);
}

char* luaL_prepbuffsize(luaL_Buffer* B, size_t sz)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_prepbuffsize(B, sz);
}

void luaL_addlstring(luaL_Buffer* B, const char* s, size_t l)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_addlstring(B, s, l);
}

void luaL_addstring(luaL_Buffer* B, const char* s)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_addstring(B, s);
}

void luaL_addvalue(luaL_Buffer* B)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_addvalue(B);
}

void luaL_pushresult(luaL_Buffer* B)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_pushresult(B);
}

void luaL_pushresultsize(luaL_Buffer* B, size_t sz)
{
	assert(g_shimTable != NULL);
	g_shimTable->shimL_pushresultsize(B, sz);
}

char* luaL_buffinitsize(lua_State* L, luaL_Buffer* B, size_t sz)
{
	assert(g_shimTable != NULL);
	return g_shimTable->shimL_buffinitsize(L, B, sz);
}

static const Node* hashpow2(const Table* t, int n) {
	int i = lmod(n, sizenode(t));
	return &t->node[i];
}

static const Node* findNode(const Table* t, int key) {
	const Node* n = hashpow2(t, key);
	while (n->i_key.tvk.value_.i != key)
	{
		int nx = n->i_key.nk.next;
		if (nx == 0)
			return NULL;
		n += nx;
	}
	return n;
}

void shimInitialize(lua_State* L)
{
	lua_lock(L);

	// Find the 'SHIM' entry in the registry.
	const Table* reg = hvalue(&G(L)->l_registry);
	const Node* n = findNode(reg, 0x5348494D); // equal to 'SHIM'
	assert(n != NULL);

	g_shimTable = (const LuaFunctionTable_t*)n->i_val.value_.p;
	assert(g_shimTable != NULL);

	lua_unlock(L);
}

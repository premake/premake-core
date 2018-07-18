#include "luashim.h"


static int example_test(lua_State* L)
{
	lua_pushstring(L, "hello ");
	lua_pushvalue(L, 1);
	lua_concat(L, 2);
	return 1;
}


static const luaL_Reg example_functions[] = {
	{ "test",  example_test },
	{ NULL, NULL }
};


#ifdef _WIN32
__declspec(dllexport) int luaopen_example(lua_State *L)
#else
int luaopen_example(lua_State *L)
#endif
{
	shimInitialize(L);
	luaL_register(L, "example", example_functions);
	return 0;
}

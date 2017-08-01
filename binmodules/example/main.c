#include <luashim.h>


static int example_test(lua_State* L)
{
	const char* text = luaL_checkstring(L, 1);
	printf("%s\n", text);
	lua_pushboolean(L, 1);
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

#include <luashim.h>

int luaopen_socket_core(lua_State *L);

#ifdef _WIN32
__declspec(dllexport) int luaopen_luasocket(lua_State *L)
#else
int luaopen_luasocket(lua_State *L)
#endif
{
	shimInitialize(L);
	luaL_requiref(L, "socket", luaopen_socket_core, 1);
	lua_pop(L, 1);
	return 0;
}

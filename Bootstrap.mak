MSDEV	= vs2012
LUA_DIR	= contrib/lua/src

SRC		= src/host/*.c			\
		$(LUA_DIR)/lapi.c		\
		$(LUA_DIR)/lcode.c		\
		$(LUA_DIR)/ldebug.c		\
		$(LUA_DIR)/ldump.c		\
		$(LUA_DIR)/lgc.c		\
		$(LUA_DIR)/liolib.c		\
		$(LUA_DIR)/lmathlib.c	\
		$(LUA_DIR)/loadlib.c	\
		$(LUA_DIR)/lopcodes.c	\
		$(LUA_DIR)/lparser.c	\
		$(LUA_DIR)/lstring.c	\
		$(LUA_DIR)/ltable.c		\
		$(LUA_DIR)/ltm.c		\
		$(LUA_DIR)/lvm.c		\
		$(LUA_DIR)/lbaselib.c	\
		$(LUA_DIR)/ldblib.c		\
		$(LUA_DIR)/ldo.c		\
		$(LUA_DIR)/lfunc.c		\
		$(LUA_DIR)/linit.c		\
		$(LUA_DIR)/llex.c		\
		$(LUA_DIR)/lmem.c		\
		$(LUA_DIR)/lobject.c	\
		$(LUA_DIR)/loslib.c		\
		$(LUA_DIR)/lstate.c		\
		$(LUA_DIR)/lstrlib.c	\
		$(LUA_DIR)/ltablib.c	\
		$(LUA_DIR)/lundump.c	\
		$(LUA_DIR)/lzio.c

PLATFORM = none
default: $(PLATFORM)

none:
	@echo "Please do"
	@echo "   nmake -f Bootstrap.mak windows"
	@echo "or"
	@echo "   CC=mingw32-gcc mingw32-make -f Bootstrap.mak mingw"
	@echo "or"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM"
	@echo "where HOST_PLATFORM is one of these:"
	@echo "   osx linux"

mingw: $(SRC)
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" $? -lole32
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --os=windows --to=build/bootstrap gmake
	$(MAKE) -C build/bootstrap

osx: $(SRC)
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_MACOSX -I"$(LUA_DIR)" -framework CoreServices $?
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap gmake
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN`

linux: $(SRC)
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" $? -lm -ldl -lrt
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap gmake
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN`

windows: $(SRC)
	if not exist build\bootstrap (mkdir build\bootstrap)
	cl /Fo.\build\bootstrap\ /Fe.\build\bootstrap\premake_bootstrap.exe /DPREMAKE_NO_BUILTIN_SCRIPTS /I"$(LUA_DIR)" user32.lib ole32.lib $**
	.\build\bootstrap\premake_bootstrap.exe embed
	.\build\bootstrap\premake_bootstrap --to=build/bootstrap $(MSDEV)
	devenv .\build\bootstrap\Premake5.sln /Upgrade
	devenv .\build\bootstrap\Premake5.sln /Build Release

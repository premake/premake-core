MSDEV       = vs2012
CONFIG      = release
PLATFORM    = x86
LUA_DIR     = contrib/lua/src
LUASHIM_DIR = contrib/luashim
PREMAKE_OPTS =

SRC		= src/host/*.c			\
		$(LUA_DIR)/lapi.c		\
		$(LUA_DIR)/lbaselib.c	\
		$(LUA_DIR)/lbitlib.c	\
		$(LUA_DIR)/lcode.c		\
		$(LUA_DIR)/lcorolib.c	\
		$(LUA_DIR)/lctype.c		\
		$(LUA_DIR)/ldblib.c		\
		$(LUA_DIR)/ldebug.c		\
		$(LUA_DIR)/ldo.c		\
		$(LUA_DIR)/ldump.c		\
		$(LUA_DIR)/lfunc.c		\
		$(LUA_DIR)/lgc.c		\
		$(LUA_DIR)/linit.c		\
		$(LUA_DIR)/liolib.c		\
		$(LUA_DIR)/llex.c		\
		$(LUA_DIR)/lmathlib.c	\
		$(LUA_DIR)/lmem.c		\
		$(LUA_DIR)/loadlib.c	\
		$(LUA_DIR)/lobject.c	\
		$(LUA_DIR)/lopcodes.c	\
		$(LUA_DIR)/loslib.c		\
		$(LUA_DIR)/lparser.c	\
		$(LUA_DIR)/lstate.c		\
		$(LUA_DIR)/lstring.c	\
		$(LUA_DIR)/lstrlib.c	\
		$(LUA_DIR)/ltable.c		\
		$(LUA_DIR)/ltablib.c	\
		$(LUA_DIR)/ltm.c		\
		$(LUA_DIR)/lundump.c	\
		$(LUA_DIR)/lutf8lib.c	\
		$(LUA_DIR)/lvm.c		\
		$(LUA_DIR)/lzio.c		\

HOST_PLATFORM= none

.PHONY: default none clean nix-clean windows-clean \
	mingw-clean mingw macosx macosx-clean osx-clean osx \
	linux-clean linux bsd-clean bsd solaris-clean solaris \
	haiku-clean haiku windows-base windows windows-msbuild

default: $(HOST_PLATFORM)

none:
	@echo "Please do"
	@echo "   nmake -f Bootstrap.mak windows"
	@echo "or"
	@echo "   CC=mingw32-gcc mingw32-make -f Bootstrap.mak mingw CONFIG=x64"
	@echo "or"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM"
	@echo "where HOST_PLATFORM is one of these:"
	@echo "   osx linux bsd"
	@echo ""
	@echo "To clean the source tree, run the same command by adding a '-clean' suffix to the target name."
		@echo "Example"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM-clean"

clean:
	@echo "Please run the same command used for building by adding a '-clean' suffix to the target name."
	@echo "   nmake -f Bootstrap.mak windows-clean"
	@echo "or"
	@echo "   CC=mingw32-gcc mingw32-make -f Bootstrap.mak mingw-clean CONFIG=x64"
	@echo "or"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM-clean"
	@echo "where HOST_PLATFORM is one of these:"
	@echo "   osx linux bsd"

nix-clean:
	$(SILENT) rm -rf ./bin
	$(SILENT) rm -rf ./build
	$(SILENT) rm -rf ./obj

windows-clean:
	$(SILENT) if exist .\bin rmdir /s /q .\bin
	$(SILENT) if exist .\build rmdir /s /q .\build
	$(SILENT) if exist .\obj rmdir /s /q .\obj

mingw-clean: nix-clean

mingw: mingw-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lole32 -lversion
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --arch=$(PLATFORM) --os=windows --to=build/bootstrap --cc=mingw $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)_$(PLATFORM:x86=win32)

macosx: osx

macosx-clean: osx-clean

osx-clean: nix-clean

osx: osx-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_MACOSX -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" -framework CoreServices -framework Foundation -framework Security -lreadline $(SRC)
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --arch=$(PLATFORM) --to=build/bootstrap $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)

linux-clean: nix-clean

linux: linux-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lm -ldl -lrt -luuid
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)

bsd-clean: nix-clean

bsd: bsd-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lm
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf NPROCESSORS_ONLN` config=$(CONFIG)

solaris-clean: nix-clean

solaris: solaris-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lm
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf NPROCESSORS_ONLN` config=$(CONFIG)

haiku-clean: nix-clean

haiku: haiku-clean
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -D_BSD_SOURCE -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lbsd
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap $(PREMAKE_OPTS) gmake2
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)

windows-base: windows-clean
	if not exist build\bootstrap (mkdir build\bootstrap)
	cl /Fo.\build\bootstrap\ /Fe.\build\bootstrap\premake_bootstrap.exe /DPREMAKE_NO_BUILTIN_SCRIPTS /I"$(LUA_DIR)" /I"$(LUASHIM_DIR)" user32.lib ole32.lib advapi32.lib $(SRC)
	.\build\bootstrap\premake_bootstrap.exe embed
	.\build\bootstrap\premake_bootstrap --arch=$(PLATFORM) --to=build/bootstrap $(PREMAKE_OPTS) $(MSDEV)

windows: windows-base
	devenv .\build\bootstrap\Premake5.sln /Upgrade
	devenv .\build\bootstrap\Premake5.sln /Build "$(CONFIG)|$(PLATFORM:x86=win32)"

windows-msbuild: windows-base
	msbuild /p:Configuration=$(CONFIG) /p:Platform=$(PLATFORM:x86=win32) .\build\bootstrap\Premake5.sln

cosmo-clean: nix-clean

cosmo: cosmo-clean
	mkdir -p build/bootstrap
	cosmocc -o build/bootstrap/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" -I"$(LUASHIM_DIR)" $(SRC) -lm -ldl -lrt
	./build/bootstrap/premake_bootstrap embed
	./build/bootstrap/premake_bootstrap --to=build/bootstrap --cc=cosmocc gmake2
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)

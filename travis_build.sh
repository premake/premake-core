if [ $BUILD = "mingw" ]; then
	export CC="i586-mingw32msvc-gcc"
fi

make -f Bootstrap.mak $BUILD

if [ $RUN_TESTS = 1 ]; then
	bin/release/premake5 test
fi

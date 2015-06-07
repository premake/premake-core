#!/bin/bash
set -e
TOP="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/. && pwd )"

UNAME=`uname`
case $UNAME in
'Darwin')
    EXTRA_PREMAKE_CFLAGS="-framework CoreServices"
    CC=${CC-clang}
    ;;
'Linux')
    EXTRA_PREMAKE_CFLAGS="-lm"
    CC=${CC-gcc}
    ;;
MINGW32*)

    # Use gcc on mingw if we have it,
    # Otherwise chain to the Visual Studio bootstrap.

    if [ "$CC" == "" ] ; then
        if [ "$(which mingw32-gcc)" != "" ] ; then
            CC="mingw32-gcc"
        elif [ "$(which gcc)" != "" ] ; then
            CC="gcc"
        fi
    fi

    if [ "$MAKE" == "" ] ; then
        if [ "$(which mingw32-make)" != "" ] ; then
            MAKE="mingw32-make"
        fi
    fi

    if [ "$CC" == "" ] || [ "$MAKE" == "" ] ; then
        echo "MinGW bootstrap did not find GCC, using Visual Studio"
        exec cmd //C "bootstrap.bat"
    fi

    EXTRA_PREMAKE_CFLAGS="-lole32"
    export CC # So mingw32-make uses the CC we selected

    echo "MinGW bootstrap found GCC, using $CC and $MAKE"
    ;;
*)
    echo "$0: Don't know how to bootstrap on '$UNAME'"
    exit 1
    ;;
esac

MAKE=${MAKE-make}

# Figure out which source files we want

LUA_SRC_DIR="$TOP/src/host/lua-5.1.4/src"
SRC_DIR="$TOP/src/host"
BOOTSTRAP_DIR="$TOP/build/bootstrap"

SRC=()
for i in "$SRC_DIR"/*.c; do
    case $i in
		$SRC_DIR/scripts.c)   ;;
        *)
            SRC=("${SRC[@]}" "${i}")
            ;;
    esac
done

LUA_SRC=()
for i in "$LUA_SRC_DIR"/*.c; do
    case $i in
		$LUA_SRC_DIR/lauxlib.c)   ;;
		$LUA_SRC_DIR/lua.c)       ;;
		$LUA_SRC_DIR/luac.c)      ;;
		$LUA_SRC_DIR/print.c)     ;;
        *)
            LUA_SRC=("${LUA_SRC[@]}" "${i}")
            ;;
    esac
done

# Build a bootstrap executable

mkdir -p "$BOOTSTRAP_DIR"
cd "$BOOTSTRAP_DIR"

$CC -o premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$LUA_SRC_DIR" "${LUA_SRC[@]}" "${SRC[@]}" $EXTRA_PREMAKE_CFLAGS

cd "$TOP"

# Embed scripts and build premake

"$BOOTSTRAP_DIR/premake_bootstrap" embed
"$BOOTSTRAP_DIR/premake_bootstrap" --to="$BOOTSTRAP_DIR" gmake
"$MAKE" -C "$BOOTSTRAP_DIR"

echo Bootstrap complete.
echo $TOP/bin/release/premake5





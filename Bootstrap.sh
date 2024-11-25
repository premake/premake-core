#!/bin/sh

DIR=$( cd "$( dirname "$0" )" && pwd )
cd "$DIR"

COSMO_FLAG=""
for arg in "$@"; do
  if [ "$arg" = "-cosmo" ]; then
    COSMO_FLAG="cosmo"
    break
  fi
done

PLATFORM_ARG=""
CONFIG_ARG=""
PREMAKE_OPTS_ARG=""

if [ -n "$PLATFORM" ]; then
  PLATFORM_ARG="PLATFORM=$PLATFORM"
fi

if [ -n "$CONFIG" ]; then
  CONFIG_ARG="CONFIG=$CONFIG"
fi

if [ -n "$PREMAKE_OPTS" ]; then
  PREMAKE_OPTS_ARG="PREMAKE_OPTS=$PREMAKE_OPTS"
fi

case "$(uname -s)" in
   Linux)
     NPROC=$(nproc --all)
     make -f Bootstrap.mak ${COSMO_FLAG:-linux} $PLATFORM_ARG $CONFIG_ARG $PREMAKE_OPTS_ARG -j$NPROC
     ;;
   Darwin)
     NPROC=$(sysctl -n hw.ncpu)
     make -f Bootstrap.mak ${COSMO_FLAG:-osx} $PLATFORM_ARG $CONFIG_ARG $PREMAKE_OPTS_ARG -j$NPROC
     ;;
   FreeBSD|OpenBSD|NetBSD)
     NPROC=$(sysctl -n hw.ncpu)
     make -f Bootstrap.mak ${COSMO_FLAG:-bsd} $PLATFORM_ARG $CONFIG_ARG $PREMAKE_OPTS_ARG -j$NPROC
     ;;
   CYGWIN*|MINGW32*|MSYS*|MINGW*)
     make -f Bootstrap.mak ${COSMO_FLAG:-mingw} $PLATFORM_ARG $CONFIG_ARG $PREMAKE_OPTS_ARG -j$NPROC
     ;;
   *)
    echo "Unsupported platform"
    exit 1
     ;;
esac

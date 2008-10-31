#!/bin/sh
MYCFG=$1
if [ ! $MYCFG ]; then MYCFG="debug"; fi
../bin/$MYCFG/premake4 /scripts=../src test

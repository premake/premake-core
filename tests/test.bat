@echo off
pushd "%~dp0"
..\bin\debug\premake5.exe /scripts=..\src /file=..\premake5.lua %* test
popd

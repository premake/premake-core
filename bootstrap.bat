@echo off
setlocal enabledelayedexpansion

rem Detect Visual Studio Version

if not "%VS140COMNTOOLS%" == "" (
  set _VSCOMMON="%VS140COMNTOOLS%"
  set _VSVERSION=vs2015
) else ( if not "%VS120COMNTOOLS%" == "" (
  set _VSCOMMON="%VS120COMNTOOLS%"
  set _VSVERSION=vs2013
) else ( if not "%VS110COMNTOOLS%" == "" (
  set _VSCOMMON="%VS110COMNTOOLS%"
  set _VSVERSION=vs2012
) else (
  echo Visual Studio 2012, 2013 or 2014 not found!
  exit /B 1
) ) )

echo Found %_VSVERSION%
call %_VSCOMMON%vsvars32.bat

rem Figure out which source files we want

set LUA_SRC_DIR=%~dp0src\host\lua-5.1.4\src
set SRC_DIR=%~dp0src\host
set BOOTSTRAP_DIR=%~dp0build\bootstrap

set SRC=
for %%i in ("%SRC_DIR%\*.c") do (
    if "%%i" == "%SRC_DIR%\scripts.c" ( rem
    ) else ( set SRC=!SRC!"%%i" )
)

set LUA_SRC=
for %%i in ("%LUA_SRC_DIR%\*.c") do (
    if "%%i" == "%LUA_SRC_DIR%\lauxlib.c" ( rem
	) else if "%%i" == "%LUA_SRC_DIR%\lua.c" ( rem
	) else if "%%i" == "%LUA_SRC_DIR%\luac.c" ( rem
	) else if "%%i" == "%LUA_SRC_DIR%\print.c" ( rem
    ) else ( set LUA_SRC=!LUA_SRC!"%%i" )
)

rem Build a bootstrap executable

IF NOT EXIST "%BOOTSTRAP_DIR%" ( mkdir "%BOOTSTRAP_DIR%" )
cd "%BOOTSTRAP_DIR%"
cl /Fepremake_bootstrap.exe /DPREMAKE_NO_BUILTIN_SCRIPTS /I"%LUA_SRC_DIR%" %LUA_SRC% %SRC% user32.lib ole32.lib
cd %~dp0

rem Embed scripts and build premake on the detected version of Visual Studio

"%BOOTSTRAP_DIR%"\premake_bootstrap embed
"%BOOTSTRAP_DIR%"\premake_bootstrap %_VSVERSION% --to="%BOOTSTRAP_DIR%"
msbuild.exe "%BOOTSTRAP_DIR%"\Premake5.sln -nologo -consoleloggerparameters:NoSummary;Verbosity=minimal -m -p:Configuration=Release

echo Bootstrap complete.
echo %~dp0bin\release\premake5.exe

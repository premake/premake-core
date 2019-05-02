@ECHO OFF
SETLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION

SET vsversion=%1
IF "%vsversion%" == "" (
	SET vsversion=vs2015
)

IF "%vsversion%" == "vs2010" (
	CALL :LegacyVisualBootstrap "%vsversion%" "100"

) ELSE IF "%vsversion%" == "vs2012" (
	CALL :LegacyVisualBootstrap "%vsversion%" "110"

) ELSE IF "%vsversion%" == "vs2013" (
	CALL :LegacyVisualBootstrap "%vsversion%" "120"

) ELSE IF "%vsversion%" == "vs2015" (
	CALL :LegacyVisualBootstrap "%vsversion%" "140"

) ELSE IF "%vsversion%" == "vs2017" (
	CALL :VsWhereVisualBootstrap "%vsversion%" "15.0" "16.0"

) ELSE IF "%vsversion%" == "vs2019" (
	CALL :VsWhereVisualBootstrap "%vsversion%" "16.0" "17.0"

) ELSE (
	ECHO Unrecognized Visual Studio version %vsversion%
	EXIT /B 2
)

REM On error, pause to allow user to notice it if script was launched through explorer
IF %ERRORLEVEL% NEQ 0 (
	PAUSE
)

EXIT /B %ERRORLEVEL%

REM ===========================================================================

REM Utils

REM ===========================================================================

REM %1: PremakeVsVersion -> ex: vs2015
REM %2: VsVersion envvar -> ex: 140
:LegacyVisualBootstrap

SET "VsVersion_NoPoint=%~2"
SET "VsEnvVar=VS%VsVersion_NoPoint%COMNTOOLS"
SET "VsPath=!%VsEnvVar%!"

IF NOT EXIST "%VsPath%vsdevcmd.bat" (
	ECHO Could not find vsdevcmd.bat to setup Visual Studio environment
	EXIT /B 2
)

CALL "%VsPath%vsdevcmd.bat" && nmake MSDEV="%~1" -f Bootstrap.mak windows
EXIT /B %ERRORLEVEL%

REM :LegacyVisualBootstrap


REM ===========================================================================

REM %1: PremakeVsVersion -> ex: vs2010
REM %2: VisualStudio-style VSversionMin -> ex: 15.0
REM %3: VisualStudio-style VSversionMax -> ex: 16.0
:VsWhereVisualBootstrap
SET "PremakeVsVersion=%~1"
SET "VsVersionMin=%~2"
SET "VsVersionMax=%~3"

REM ref: https://github.com/Microsoft/vswhere/wiki/Start-Developer-Command-Prompt

SET VsWherePath="C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"

IF NOT EXIST %VsWherePath% (
	ECHO Could not find vswhere.exe
	EXIT /B 2
)

SET VsWhereCmdLine="%VsWherePath% -nologo -latest -version [%VsVersionMin%,%VsVersionMax%) -property installationPath"

FOR /F "usebackq delims=" %%i in (`!VsWhereCmdLine!`) DO (

	IF EXIST "%%i\VC\Auxiliary\Build\vcvars32.bat" (
		CALL "%%i\VC\Auxiliary\Build\vcvars32.bat" && nmake MSDEV="%PremakeVsVersion%" -f Bootstrap.mak windows
		EXIT /B %ERRORLEVEL%
	)
)

ECHO Could not find vcvars32.bat to setup Visual Studio environment
EXIT /B 2

REM :VsWhereVisualBootstrap

REM ===========================================================================

REM SETLOCAL ENABLEDELAYEDEXPANSION
ENDLOCAL
REM SETLOCAL
ENDLOCAL

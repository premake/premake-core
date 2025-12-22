@ECHO OFF
SETLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===========================================================================

SET SelfPath="%0"
SET VsWherePath="C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"

REM ===========================================================================

SET "PlatformArg="
SET "ConfigArg="

IF NOT "%PLATFORM%" == "" (
	SET "PlatformArg=PLATFORM=%PLATFORM%"
)

IF NOT "%CONFIG%" == "" (
	SET "ConfigArg=CONFIG=%CONFIG%"
)

SET vsversion=%1
IF "%vsversion%" == "" (
	CALL :BootstrapLatest
	EXIT /B %ERRORLEVEL%
)

SET PREMAKE_OPTS=%2

IF "%vsversion%" == "vs2010" (
	CALL :LegacyVisualBootstrap "%vsversion%" "100"

) ELSE IF "%vsversion%" == "vs2012" (
	CALL :LegacyVisualBootstrap "%vsversion%" "110"

) ELSE IF "%vsversion%" == "vs2013" (
	CALL :LegacyVisualBootstrap "%vsversion%" "120"

) ELSE IF "%vsversion%" == "vs2015" (
	CALL :LegacyVisualBootstrap "%vsversion%" "140"

) ELSE IF "%vsversion%" == "vs2017" (
	CALL :VsWhereVisualBootstrap "%vsversion%" "15.0" "16.0" %PREMAKE_OPTS%

) ELSE IF "%vsversion%" == "vs2019" (
	CALL :VsWhereVisualBootstrap "%vsversion%" "16.0" "17.0" %PREMAKE_OPTS%

) ELSE IF "%vsversion%" == "vs2022" (
	CALL :VsWhereVisualBootstrap "%vsversion%" "17.0" "18.0" %PREMAKE_OPTS%

) ELSE IF "%vsversion%" == "vs18" (
	CALL :VsWhereVisualBootstrap "vs2026" "18.0" "19.0"

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

CALL "%VsPath%vsdevcmd.bat" && nmake MSDEV="%~1" %PlatformArg% %ConfigArg% -f Bootstrap.mak windows
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
SET PREMAKE_OPTS=%4

REM ref: https://github.com/Microsoft/vswhere/wiki/Start-Developer-Command-Prompt

IF NOT EXIST %VsWherePath% (
	ECHO Could not find vswhere.exe
	EXIT /B 2
)

SET VsWhereCmdLine="!VsWherePath! -nologo -latest -version [%VsVersionMin%,%VsVersionMax%) -property installationPath"

FOR /F "usebackq delims=" %%i in (`!VsWhereCmdLine!`) DO (
	IF EXIST "%%i\VC\Auxiliary\Build\vcvars64.bat" (
		CALL "%%i\VC\Auxiliary\Build\vcvars64.bat" && nmake MSDEV="%PremakeVsVersion%" %PlatformArg% %ConfigArg%  %PREMAKE_OPTS% -f Bootstrap.mak windows
		EXIT /B %ERRORLEVEL%
	) ELSE (
		IF EXIST "%%i\VC\Auxiliary\Build\vcvars32.bat" (
			CALL "%%i\VC\Auxiliary\Build\vcvars32.bat" && nmake MSDEV="%PremakeVsVersion%" %PlatformArg% %ConfigArg% %PREMAKE_OPTS% -f Bootstrap.mak windows
			EXIT /B %ERRORLEVEL%
		)
	)
)

ECHO Could not find vcvars64.bat or vcvars32.bat to setup Visual Studio environment
EXIT /B 2

REM :VsWhereVisualBootstrap

REM ===========================================================================

:BootstrapLatest

IF EXIST %VsWherePath% (

	REM First try for not legacy Visual Studios ( >vs2017 )

	SET VsWhereCmdLine="!VsWherePath! -nologo -latest -property catalog.productLineVersion"

	FOR /F "usebackq delims=" %%i in (`!VsWhereCmdLine!`) DO (

		CALL %SelfPath% vs%%i

		EXIT /B %ERRORLEVEL%
	)

)

SET LegacyVSVersions=

REM Get latest Visual Studio legacy version

REM For all env var starting with VS
FOR /F "usebackq delims==" %%i in (`SET VS`) DO (

	REM Check if env var match pattern VS*COMNTOOLS (ie: VS140COMNTOOLS)
	ECHO "%%i" | FINDSTR /R /C:VS.*COMNTOOLS >nul && (

		SET "LegacyVSVersions=%%i"
	)
)

REM Strip VS
SET LegacyVSVersions=%LegacyVSVersions:VS=%
REM Strip COMNTOOLS
SET LegacyVSVersions=%LegacyVSVersions:COMNTOOLS=%

SET "VsVersionMap=140-vs2015;120-vs2013;110-vs2012;100-vs2010"
CALL SET PremakeVsVersion=%%VsVersionMap:*%LegacyVSVersions%-=%%
SET PremakeVsVersion=%PremakeVsVersion:;=&REM.%

IF NOT "%PremakeVsVersion%" == "" (
	CALL %SelfPath% %PremakeVsVersion%
	EXIT /B %ERRORLEVEL%
)

ECHO Could not find a Visual Studio installation
EXIT /B 2

REM :BootstrapLatest

REM ===========================================================================

REM SETLOCAL ENABLEDELAYEDEXPANSION
ENDLOCAL
REM SETLOCAL
ENDLOCAL

---
-- Premake Next build configuration script
-- Use this script to configure the project with Premake5.
---

workspace 'Premake6'

	configurations { 'Release', 'Debug' }

	filter { 'system:windows' }
		platforms { 'x86', 'x64' }


project 'Premake6'

	targetname 'premake6'
	language 'C'
	kind 'ConsoleApp'

	files
	{
		'core/host/src/**.h',
		'core/host/src/**.c',
		'core/host/src/**.lua',
		'core/contrib/lua/src/**.h',
		'core/contrib/lua/src/**.c'
	}

	removefiles
	{
		'core/contrib/lua/src/lua.c',
		'core/contrib/lua/src/luac.c',
		'core/contrib/lua/src/print.c',
		'core/contrib/lua/**.lua',
		'core/contrib/lua/etc/*.c'
	}

	includedirs
	{
		'core/host/include',
		'core/contrib'
	}

	flags { 'MultiProcessorCompile' }
	staticruntime 'On'
	warnings 'Extra'

	filter 'configurations:Debug'
		defines '_DEBUG'
		symbols 'On'
		targetdir 'bin/debug'
		debugargs { '--scripts=%{prj.location}/%{path.getrelative(prj.location, prj.basedir)}' }
		debugdir '.'

	filter 'configurations:Release'
		defines 'NDEBUG'
		optimize 'Full'
		flags { 'NoBufferSecurityCheck', 'NoRuntimeChecks' }
		targetdir 'bin/release'

	filter 'system:windows'
		links { 'ole32', 'ws2_32', 'advapi32' }

	filter { 'system:windows', 'configurations:Release' }
		flags { 'NoIncrementalLink', 'LinkTimeOptimization' }

	filter 'system:linux or bsd or hurd'
		defines { 'LUA_USE_POSIX', 'LUA_USE_DLOPEN' }
		links { 'm' }
		linkoptions { '-rdynamic' }

	filter 'system:linux or hurd'
		links { 'dl', 'rt' }

	filter 'system:macosx'
		defines { 'LUA_USE_MACOSX' }
		links { 'CoreServices.framework', 'Foundation.framework', 'Security.framework', 'readline' }

	filter { 'system:macosx', 'action:gmake' }
		toolset 'clang'

	filter { 'system:solaris' }
		links { 'm', 'socket', 'nsl' }

	filter 'system:aix'
		defines { 'LUA_USE_POSIX', 'LUA_USE_DLOPEN' }
		links { 'm' }

	filter 'action:vs*'
		defines { '_CRT_SECURE_NO_DEPRECATE', '_CRT_SECURE_NO_WARNINGS', '_CRT_NONSTDC_NO_WARNINGS' }

	filter 'toolset:clang'
		disablewarnings 'string-plus-int'

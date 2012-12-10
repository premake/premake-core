--
-- premake.lua
-- High-level processing functions.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--


--
-- Define some commonly used symbols, for future-proofing.
--

	premake.C           = "C"
	premake.C7          = "c7"
	premake.CONSOLEAPP  = "ConsoleApp"
	premake.CPP         = "C++"
	premake.GCC         = "gcc"
	premake.HAIKU       = "haiku"
	premake.LINUX       = "linux"
	premake.MACOSX      = "macosx"
	premake.POSIX       = "posix"
	premake.PS3         = "ps3"
	premake.SHAREDLIB   = "SharedLib"
	premake.STATICLIB   = "StaticLib"
	premake.UNIVERSAL   = "universal"
	premake.WINDOWEDAPP = "WindowedApp"
	premake.WINDOWS     = "windows"
	premake.X32         = "x32"
	premake.X64         = "x64"
	premake.XBOX360     = "xbox360"


--
-- Open a file for output, and call a function to actually do the writing.
-- Used by the actions to generate solution and project files.
--
-- @param obj
--    A solution or project object; will be based to the callback function.
-- @param ext
--    An optional extension for the generated file, with the leading dot.
-- @param callback
--    The function responsible for writing the file, should take a solution
--    or project as a parameters.
--

	function premake.generate(obj, ext, callback)
		local fn = premake5.project.getfilename(obj, ext)
		printf("Generating %s...", path.getrelative(os.getcwd(), fn))

		local f, err = io.open(fn, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		callback(obj)
		f:close()
	end


--
-- Override an existing function with a new one; the original function
-- is passed as the first argument to the replacement when called.
--
-- @param scope
--    The table containing the function to be overridden. Use _G for
--    global functions.
-- @param name
--    The name of the function to override.
-- @param repl
--    The replacement function. The first argument to the function
--    will be the original implementation.
--

	function premake.override(scope, name, repl)
		local original = scope[name]
		scope[name] = function(...)
			return repl(original, ...)
		end
	end

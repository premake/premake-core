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
	premake.MACOSX      = "macosx"
	premake.POSIX       = "posix"
	premake.PS3         = "ps3"
	premake.SHAREDLIB   = "SharedLib"
	premake.STATICLIB   = "StaticLib"
	premake.WINDOWEDAPP = "WindowedApp"
	premake.WINDOWS     = "windows"
	premake.X32         = "x32"
	premake.X64         = "x64"
	premake.XBOX360     = "xbox360"


--
-- The list of known systems, with metadata to help drive the generation process.
--

	premake.systems = {
		linux = 
		{
			sharedlib = { prefix = "lib", extension = ".so" },
			staticlib = { prefix = "lib", extension = ".a" },
			
		},
		
		macosx = 
		{
			sharedlib = { prefix = "lib", extension = ".dylib" },
			staticlib = { prefix = "lib", extension = ".a" },
		},
		
		ps3 =
		{
			consoleapp = { extension = ".elf" },
			sharedlib  = { prefix = "lib" },
			staticlib  = { prefix = "lib", extension = ".a" },
		},
		
		windows = 
		{
			consoleapp  = { extension = ".exe" },
			windowedapp = { extension = ".exe" },
			sharedlib   = { extension = ".dll" },
			staticlib   = { extension = ".lib" },
		}
	}
	
	premake.systems.bsd     = premake.systems.linux
	premake.systems.haiku   = premake.systems.linux
	premake.systems.solaris = premake.systems.linux
	premake.systems.xbox360 = premake.systems.windows
	
	
--
-- Open a file for output, and call a function to actually do the writing.
-- Used by the actions to generate solution and project files.
--
-- @param obj
--    A solution or project object; will be based to the callback function.
-- @param filename
--    The output filename; see the docs for premake.project.getfilename()
--    for the expected format.
-- @param callback
--    The function responsible for writing the file, should take a solution
--    or project as a parameters.
--

	function premake.generate(obj, filename, callback)
		filename = premake.project.getfilename(obj, filename)
		printf("Generating %s...", filename)

		local f, err = io.open(filename, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		callback(obj)
		f:close()
	end

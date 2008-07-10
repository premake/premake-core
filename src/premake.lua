package.name = "Premake"
package.target = "premake4"
package.language = "c"
package.kind = "exe"

	local lua      = "script/lua-5.1.2"
	local unittest = "testing/UnitTest++/src"


-- Build settings

	package.buildflags = 
	{
		"no-64bit-checks",
		"extra-warnings",
		"fatal-warnings"
	}

	package.config["Debug"].defines =
	{
		"_DEBUG"
	}
	
	package.config["Release"].buildflags = 
	{
		"no-symbols",
		"optimize-size",
		"no-frame-pointers"
	}
	
	package.config["Release"].defines =
	{
		"NDEBUG"
	}

	package.defines =
	{
		"_CRT_SECURE_NO_WARNINGS"
	}
	
	package.includepaths = 
	{
		".",
		lua .. "/src",
	}

	package.files =
	{
		matchrecursive("*.h", "*.c"),
	}
		
	package.excludes =
	{
		lua .. "/src/lua.c",
		lua .. "/src/luac.c",
		matchfiles(lua .. "/etc/*.c")
	}	


-- Automated tests

	if (not options["no-tests"]) then
		
		-- UnitTest++ is a C++ system
		package.language = "c++"  

		-- Define a symbol so I can compile in the testing calls
		table.insert(package.defines, "TESTING_ENABLED")
		
		table.insert(package.files, matchrecursive("*.cpp"))
		table.insert(package.excludes, matchfiles(unittest .. "/tests/*"))
		
		if (windows) then
			table.insert(package.excludes, matchfiles(unittest .. "/Posix/*"))
			package.config["Debug"].postbuildcommands = { "..\\bin\\debug\\premake4.exe" }
			package.config["Release"].postbuildcommands = { "..\\bin\\release\\premake4.exe" }
		else
			table.insert(package.excludes, matchfiles(unittest .. "/Win32/*"))
			package.config["Debug"].postbuildcommands = { "../bin/debug/premake4" }
			package.config["Release"].postbuildcommands = { "../bin/release/premake4" }
		end
		
	end


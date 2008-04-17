package.name = "Premake"
package.target = "premake4"
package.language = "c"
package.kind = "exe"

local subsystems = 
{
	"platform",
	"base",
	"project",
	"action",
	"action/make",
	"action/vs200x",
	"engine",
	"host"
}


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
		"."
	}
	
	
-- Files

	package.files = matchfiles("*.h", "*.c")
	for k,m in subsystems do
		table.insert(package.files, matchfiles(m.."/*.h", m.."/*.c"))
	end


-- Lua scripting engine

	local lua = "engine/lua-5.1.2/src"
	table.insert(package.includepaths, lua)
	table.insert(package.files, matchfiles(lua.."/*.h", lua.."/*.c"))
	table.insert(package.excludes, {lua.."/lua.c", lua.."/luac.c"})


-- Automated tests

	if (not options["no-tests"]) then
		local unittest = "testing/UnitTest++/src"
		
		-- UnitTest++ is a C++ system
		package.language = "c++"  

		-- Define a symbol so I can compile in the testing calls
		table.insert(package.defines, "TESTING_ENABLED")
		
		table.insert(package.files, matchfiles("testing/*.h", "testing/*.cpp", unittest.."/*"))
	
		for k,m in subsystems do
			table.insert(package.files, matchfiles(m.."/tests/*.h", m.."/tests/*.cpp"))
		end
		
		if (windows) then 
			table.insert(package.files, matchfiles(unittest.."/Win32/*"))
			package.config["Debug"].postbuildcommands = { "..\\bin\\debug\\premake4.exe" }
			package.config["Release"].postbuildcommands = { "..\\bin\\release\\premake4.exe" }
		else
			table.insert(package.files, matchfiles(unittest.."/Posix/*"))
			package.config["Debug"].postbuildcommands = { "../bin/debug/premake4" }
			package.config["Release"].postbuildcommands = { "../bin/release/premake4" }
		end
		
	end


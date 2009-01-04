package.name = "Premake"
package.target = "premake4"
package.language = "c"
package.kind = "exe"

-- Build settings

	package.buildflags = 
	{
		"no-64bit-checks",
		"extra-warnings"
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
		"host/lua-5.1.4/src"
	}
	
	package.files =
	{
		matchrecursive("host/*.h", "host/*.c"),
		matchrecursive("*.lua", "*.tmpl"),
		matchrecursive("../tests/*.lua")
	}

	package.excludes =
	{
		"premake.lua", "premake4.lua",
		"host/lua-5.1.4/src/lua.c",
		"host/lua-5.1.4/src/luac.c",
		"host/lua-5.1.4/src/print.c",
		matchrecursive("host/lua-5.1.4/*.lua"),
		matchfiles("host/lua-5.1.4/etc/*.c")
	}

	if (linux) then
		table.insert(package.links, "m")
	end


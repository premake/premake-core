--
-- Premake 4.x build configuration script
-- 

if (_ACTION == "vs2002" or _ACTION == "vs2003") then
	error(
		"\nBecause of compiler limitations, Visual Studio 2002 and 2003 aren't able to\n" ..
		"build this version of Premake. Use the free Visual Studio Express instead.", 0)
end



--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--

	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}



--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to 
-- worry about the /scripts argument and all that.
--

	solution "Premake4"
		configurations { "Release", "Debug" }
		location ( _OPTIONS["to"] )
	
	project "Premake4"
		targetname  "premake4"
		language    "C"
		kind        "ConsoleApp"
		flags       { "No64BitChecks", "ExtraWarnings" }	
		includedirs { "src/host/lua-5.1.4/src" }
		location    ( _OPTIONS["to"] )

		files 
		{
			"src/**.h", "src/**.c", "src/**.lua", "src/**.tmpl",
			"tests/**.lua"
		}

		excludes
		{
			"src/premake.lua",
			"src/host/lua-5.1.4/src/lua.c",
			"src/host/lua-5.1.4/src/luac.c",
			"src/host/lua-5.1.4/src/print.c",
			"src/host/lua-5.1.4/**.lua",
			"src/host/lua-5.1.4/etc/*.c"
		}
			
		configuration "Debug"
			targetdir   "bin/debug"
			defines     "_DEBUG"
			flags       { "Symbols" }
			
		configuration "Release"
			targetdir   "bin/release"
			defines     "NDEBUG"
			flags       { "OptimizeSize" }

		configuration "vs*"
			defines     { "_CRT_SECURE_NO_WARNINGS" }

		configuration "linux"
			defines     { "LUA_USE_LINUX" }
			links       { "m", "dl" } 
			
		configuration "macosx"
			defines     { "LUA_USE_MACOSX" }



--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
	
	

--
-- Embed the Lua scripts into src/host/scripts.c as static data buffers.
-- I embed the actual scripts, rather than Lua bytecodes, because the 
-- bytecodes are not portable to different architectures.
--

	local function loadscript(fname)
		local f = io.open(fname)
		local s = f:read("*a")
		f:close()

		-- strip out comments
		s = s:gsub("[\n]%-%-[^\n]*", "")
		
		-- strip any CRs
		s = s:gsub("[\r]", "")
		
		-- escape backslashes
		s = s:gsub("\\", "\\\\")

		-- escape line feeds
		s = s:gsub("\n", "\\n")
		
		-- escape double quote marks
		s = s:gsub("\"", "\\\"")

		return s
	end

	
	local function embedfile(out, fname)
		local s = loadscript(fname)

		-- strip tabs
		s = s:gsub("[\t]", "")
		
		-- strip duplicate line feeds
		s = s:gsub("\n+", "\n")
		
		
		out:write("\t\"")
		out:write(s)
		out:write("\",\n")
	end

	
	local function embedtemplate(out, fname)
		local s = loadscript(fname)
		
		local name = path.getbasename(fname)
		out:write(string.format("\t\"_TEMPLATES.%s=premake.loadtemplatestring('%s',[[", name, name))
		out:write(s)
		out:write("]])\",\n")
	end
	
	
	premake.actions["embed"] = {
		description = "Embed scripts in scripts.c; required before release builds",
		execute     = function ()
			-- load the manifest of script files
			scripts, templates, actions = dofile("src/_manifest.lua")
			table.insert(scripts, "_premake_main.lua")
			
			-- open scripts.c and write the file header
			local out = io.open("src/host/scripts.c", "w+b")
			out:write("/* Premake's Lua scripts, as static data buffers for release mode builds */\n")
			out:write("/* To regenerate this file, run: premake4 embed */ \n\n")
			out:write("const char* builtin_scripts[] = {\n")
			
			for i,fn in ipairs(scripts) do
				print(fn)
				s = embedfile(out, "src/"..fn)
			end

			for i,fn in ipairs(templates) do
				print(fn)
				s = embedtemplate(out, "src/"..fn)
			end

			for i,fn in ipairs(actions) do
				print(fn)
				s = embedfile(out, "src/"..fn)
			end
			
			out:write("\t0\n};\n");		
			out:close()
		end
	}

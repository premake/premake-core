--
-- Embed the Lua scripts into src/host/scripts.c as static data buffers.
-- I embed the actual scripts, rather than Lua bytecodes, because the 
-- bytecodes are not portable to different architectures, which causes 
-- issues in Mac OS X Universal builds.
--

	local function embedfile(out, fname)
		local f = io.open(fname)
		local s = f:read("*a")
		f:close()

		-- strip tabs
		s = s:gsub("[\t]", "")
		
		-- strip any CRs
		s = s:gsub("[\r]", "")
		
		-- strip out comments
		s = s:gsub("\n%-%-[^\n]*", "")
				
		-- escape backslashes
		s = s:gsub("\\", "\\\\")

		-- strip duplicate line feeds
		s = s:gsub("\n+", "\n")

		-- strip out leading comments
		s = s:gsub("^%-%-\n", "")

		-- escape line feeds
		s = s:gsub("\n", "\\n")
		
		-- escape double quote marks
		s = s:gsub("\"", "\\\"")
		
		out:write("\t\"")
		out:write(s)
		out:write("\",\n")
	end


	function doembed()
			-- load the manifest of script files
			scripts = dofile("src/_manifest.lua")
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
			
			out:write("\t0\n};\n");		
			out:close()
	end

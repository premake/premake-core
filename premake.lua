project.name = "Premake4"

	project.configs = { "Release", "Debug" }
	
-- Output directories

	project.config["Debug"].bindir = "bin/debug"
	project.config["Release"].bindir = "bin/release"

  
-- Packages

	dopackage("src")


-- Cleanup code

	function doclean(cmd, arg)
		docommand(cmd, arg)
		os.rmdir("bin")
	end



-- Functions copied from Premake4; can drop them once I'm self-hosting

	path = { }

	function string.findlast(s, pattern, plain)
		local curr = 0
		repeat
			local next = s:find(pattern, curr + 1, plain)
			if (next) then curr = next end
		until (not next)
		if (curr > 0) then
			return curr
		end	
	end

	function path.getbasename(p)
		local fn = path.getname(p)
		local i = fn:findlast(".", true)
		if (i) then
			return fn:sub(1, i - 1)
		else
			return fn
		end
	end
	
	function path.getname(p)
		local i = p:findlast("/", true)
		if (i) then
			return p:sub(i + 1)
		else
			return p
		end
	end



-- Compile scripts to bytecodes

	function dumpfile(out, filename)
		local func = loadfile(filename)			
		local dump = string.dump(func)
		local len = string.len(dump)
		out:write("\t\"")
		for i=1,len do
			out:write(string.format("\\%03o", string.byte(dump, i)))
		end
		out:write("\",\n")
		return len
	end

	function dumptmpl(out, filename)
		local f = io.open(filename)
		local tmpl = f:read("*a")
		f:close()

		local name = path.getbasename(filename)
		local dump = "_TEMPLATES."..name.."=premake.template.loadstring('"..name.."',[["..tmpl.."]])"
		local len = string.len(dump)
		out:write("\t\"")
		for i=1,len do
			out:write(string.format("\\%03o", string.byte(dump, i)))
		end
		out:write("\",\n")
		return len
	end				
	
	function docompile(cmd, arg)
		local sizes = { }

		scripts, templates, actions = dofile("src/_manifest.lua")

		local out = io.open("src/host/bytecode.c", "w+b")
		out:write("/* Precompiled bytecodes for built-in Premake scripts */\n")
		out:write("/* To regenerate this file, run `premake --compile` (Premake 3.x) */\n\n")

		out:write("const char* builtin_bytecode[] = {\n")
		
		for i,fn in ipairs(scripts) do
			print(fn)
			s = dumpfile(out, "src/"..fn)
			table.insert(sizes, s)
		end

		for i,fn in ipairs(templates) do
			print(fn)
			s = dumptmpl(out, "src/"..fn)
			table.insert(sizes, s)
		end
		
		for i,fn in ipairs(actions) do
			print(fn)
			s = dumpfile(out, "src/"..fn)
			table.insert(sizes, s)
		end
		
		out:write("};\n\n");
		out:write("int builtin_sizes[] = {\n")

		for i,v in ipairs(sizes) do
			out:write("\t"..v..",\n")
		end

		out:write("\t0\n};\n");		
		out:close()
		
		print("Done.")	
	end

--
-- io.lua
-- Additions to the I/O namespace.
-- Copyright (c) 2008-2014 Jason Perkins and the Premake project
--


--
-- Open an overload of the io.open() function, which will create any missing
-- subdirectories in the filename if "mode" is set to writeable.
--

	premake.override(io, "open", function(base, fname, mode)
		if mode and (mode:find("w") or mode:find("a"))  then
			local dir = path.getdirectory(fname)
			ok, err = os.mkdir(dir)
			if not ok then
				error(err, 0)
			end
		end
		return base(fname, mode)
	end)


--
-- Write content to a new file.
--
	function io.writefile(filename, content)
		local file = io.open(filename, "w+b")
		if file then
			file:write(content)
			file:close()
			return true
		end
	end

--
-- Read content from new file.
--
	function io.readfile(filename)
		local file = io.open(filename, "rb")
		if file then
			local content = file:read("*a")
			file:close()
			return content
		end
	end
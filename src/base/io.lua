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

--
-- premake.lua
-- High-level processing functions.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--


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
		-- open the file for output and handle any errors
		filename = premake.project.getfilename(obj, filename)
		local f, err = io.open(filename, "wb")
		if (not f) then
			error(err, 0)
		end
		io.output(f)

		-- generate the file
		callback(obj)
		
		-- clean up
		f:close()
	end

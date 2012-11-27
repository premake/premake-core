--
-- _clean.lua
-- The "clean" action: removes all generated files.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.clean = {}


--
-- Register the "clean" action.
--

	newaction {
		trigger     = "clean",
		description = "Remove all binaries and generated files",

		execute = function()
			print("** The clean action has not yet been ported")
		end
	}

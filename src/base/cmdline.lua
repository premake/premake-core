--
-- cmdline.lua
-- Functions to define and handle command line actions and options.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	local requiredactionfields =
	{
		"description",
		"trigger",
	}


--
-- Define a new action.
--

	function newaction(a)
		-- some sanity checking
		local missing
		for _, field in ipairs(requiredactionfields) do
			if (not a[field]) then
				missing = field
			end
		end
		
		if (missing) then
			error("action needs a " .. missing, 2)
		end

		premake.actions[a.trigger] = a		
	end
	
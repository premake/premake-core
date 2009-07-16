--
-- action.lua
-- Work with the list of registered actions.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	premake.action = { }



--
-- Trigger an action.
-- @param name
--    The name of the action to be triggered.
-- @returns
--    None.
--

	function premake.action.call(name)
		local a = premake.actions[name]
		
		-- if the action has an execute() function, call it
		if type(a.execute) == "function" then
			a.execute()
		end
	end

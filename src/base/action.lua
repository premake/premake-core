--
-- action.lua
-- Work with the list of registered actions.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	premake.action = { }


--
-- The list of registered actions.
--

	premake.action.list = { }
	

--
-- Register a new action.
--
-- @param a
--    The new action object.
-- 

	function premake.action.add(a)
		-- validate the action object, at least a little bit
		local missing
		for _, field in ipairs({"description", "trigger"}) do
			if (not a[field]) then
				missing = field
			end
		end
		
		if (missing) then
			error("action needs a " .. missing, 3)
		end

		-- add it to the master list
		premake.action.list[a.trigger] = a		
	end


--
-- Retrieve the current action, as determined by _ACTION.
--
-- @return
--    The current action, or nil if _ACTION is nil or does not match any action.
--

	function premake.action.current()
		return premake.action.get(_ACTION)
	end
	
	
--
-- Retrieve an action by name.
--
-- @param name
--    The name of the action to retrieve.
-- @returns
--    The requested action, or nil if the action does not exist.
--

	function premake.action.get(name)
		return premake.action.list[name]
	end


--
-- Trigger an action.
--
-- @param name
--    The name of the action to be triggered.
-- @returns
--    None.
--

	function premake.action.call(name)
		local a = premake.action.list[name]
		
		-- walk the session objects and pass to the action for handling
		local function generatefiles(this, templates)
			if (not templates) then return end
			for _,tmpl in ipairs(templates) do
				local output = true
				if (tmpl[3]) then
					output = tmpl[3](this)
				end
				if (output) then
					local fname = path.getrelative(os.getcwd(), premake.getoutputname(this, tmpl[1]))
					printf("Generating %s...", fname)
					local f, err = io.open(fname, "wb")
					if (not f) then
						error(err, 0)
					end
					io.output(f)
					
					-- call the template function to generate the output
					tmpl[2](this)

					io.output():close()
				end
			end
		end

		for _,sln in ipairs(_SOLUTIONS) do
			if type(a.onsolution) == "function" then
				a.onsolution(sln)
			end
			generatefiles(sln, a.solutiontemplates)			
			for prj in premake.eachproject(sln) do
				if type(a.onproject) == "function" then
					a.onproject(prj)
				end
				generatefiles(prj, a.projecttemplates)
			end
		end
		
		-- call execute() to perform general processing
		if type(a.execute) == "function" then
			a.execute()
		end
	end


--
-- Iterator for the list of actions.
--

	function premake.action.each()
		-- sort the list by trigger
		local keys = { }
		for _, action in pairs(premake.action.list) do
			table.insert(keys, action.trigger)
		end
		table.sort(keys)
		
		local i = 0
		return function()
			i = i + 1
			return premake.action.list[keys[i]]
		end
	end

--
-- premake.lua
-- Main (top level) application logic for Premake.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Check the specified tools (/cc, /csc, etc.) against the current action
-- to make sure they are compatible and supported.
--

	function premake.checktools()
		local action = premake.actions[_ACTION]
		
		if (not action.valid_tools) then 
			return true 
		end
		
		for tool, values in pairs(action.valid_tools) do
			if (_OPTIONS[tool]) then
				if (not table.contains(values, _OPTIONS[tool])) then
					return nil, "the " .. action.shortname .. " action does not support /" .. tool .. "=" .. _OPTIONS[tool]
				end
			else
				_OPTIONS[tool] = values[1]
			end
		end
		
		return true
	end
	
	
--
-- Check to see if the value exists in a list of values, using a 
-- case-insensitive match. If the value does exist, the canonical
-- version contained in the list is returned, so future tests can
-- use case-sensitive comparisions.
--

	function premake.checkvalue(value, allowed)
		if (allowed) then
			for _,v in ipairs(allowed) do
				if (value:lower() == v:lower()) then
					return v
				end
			end
		else
			return value
		end
	end



--
-- Fire a particular action. Generates the output files from the templates
-- listed in the action descriptor, and calls any registered handler functions.
--

	function premake.doaction(name)
		local action = premake.actions[name]
		
		-- walk the session objects and generate files from the templates
		local function generatefiles(this, templates)
			if (templates) then
				for _,tmpl in ipairs(templates) do
					local fname = premake.getoutputname(this, tmpl[1])
					premake.template.generate(tmpl[2], fname, this)
				end
			end
		end

		for _,sln in ipairs(_SOLUTIONS) do
			generatefiles(sln, action.solutiontemplates)			
			for prj in premake.project.projects(sln) do
				generatefiles(prj, action.projecttemplates)
			end
		end
		
		if (action.execute) then
			action.execute()
		end
	end


--
-- Returns a list of all of the active terms from the current environment.
--

	local _terms
	function premake.getactiveterms()
		if (not _terms) then
			_terms = { }
			table.insert(_terms, _ACTION)
			table.insert(_terms, _OS)
			for k,_ in pairs(_OPTIONS) do
				table.insert(_terms, k)
			end
		end
		return _terms
	end
	
	
--
-- Converts a project object and a template filespec (the first value in an
-- action's template reference) into a filename for that template's output.
-- The filespec may be either a file extension, or a function.
--
		
	function premake.getoutputname(this, namespec)
		local fname
		if (type(namespec) == "function") then
			fname = namespec(this)
		else
			fname = this.name .. namespec
		end		
		return path.join(this.location, fname)
	end




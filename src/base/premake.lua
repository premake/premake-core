--
-- premake.lua
-- Main (top level) application logic for Premake.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Check the specified tools (/cc, /dotnet, etc.) against the current action
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
					return nil, "the " .. action.shortname .. " action does not support /" .. tool .. "=" .. _OPTIONS[tool] .. " (yet)"
				end
			else
				_OPTIONS[tool] = values[1]
			end
		end
		
		return true
	end
	


--
-- Validate the command-line options.
--

	function premake.checkoptions()
		for key, value in pairs(_OPTIONS) do
			-- is this a valid option?
			local opt = premake.options[key]
			if (not opt) then
				return false, "invalid option '" .. key .. "'"
			end
			
			-- does it need a value?
			if (opt.value and value == "") then
				return false, "no value specified for option '" .. key .. "'"
			end
			
			-- is the value allowed?
			if (opt.allowed) then
				for _, match in ipairs(opt.allowed) do
					if (match[1] == value) then return true end
				end
				return false, "invalid value '" .. value .. "' for option '" .. key .. "'"
			end
		end
		return true
	end
	
		
--
-- Check to see if a value exists in a list of values, using a 
-- case-insensitive match. If the value does exist, the canonical
-- version contained in the list is returned, so future tests can
-- use case-sensitive comparisions.
--

	function premake.checkvalue(value, allowed)
		if (allowed) then
			if (type(allowed) == "function") then
				return allowed(value)
			else
				for _,v in ipairs(allowed) do
					if (value:lower() == v:lower()) then
						return v
					end
				end
				return nil, "invalid value '" .. value .. "'"
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
			if (not templates) then return end
			for _,tmpl in ipairs(templates) do
				local output = true
				if (tmpl[3]) then
					output = tmpl[3](this)
				end
				if (output) then
					local fname = premake.getoutputname(this, tmpl[1])
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
			generatefiles(sln, action.solutiontemplates)			
			for prj in premake.eachproject(sln) do
				generatefiles(prj, action.projecttemplates)
			end
		end
		
		if (action.execute) then
			action.execute()
		end
	end



--
-- Apply XML escaping to a value.
--

	function premake.esc(value)
		if (type(value) == "table") then
			local result = { }
			for _,v in ipairs(value) do
				table.insert(result, premake.esc(v))
			end
			return result
		else
			value = value:gsub('&',  "&amp;")
			value = value:gsub('"',  "&quot;")
			value = value:gsub("'",  "&apos;")
			value = value:gsub('<',  "&lt;")
			value = value:gsub('>',  "&gt;")
			value = value:gsub('\r', "&#x0D;")
			value = value:gsub('\n', "&#x0A;")
			return value
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




--
-- validate.lua
-- Tests to validate the run-time environment before starting the action.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


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
-- Performs a sanity check all all of the solutions and projects 
-- in the session to be sure they meet some minimum requirements.
--

	function premake.checkprojects()
		local action = premake.actions[_ACTION]
		
		for _, sln in ipairs(_SOLUTIONS) do
		
			-- every solution must have at least one project
			if (#sln.projects == 0) then
				return nil, "solution '" .. sln.name .. "' needs at least one project"
			end
			
			-- every solution must provide a list of configurations
			if (#sln.configurations == 0) then
				return nil, "solution '" .. sln.name .. "' needs configurations"
			end
			
			for prj in premake.eachproject(sln) do

				-- every project must have a language
				if (not prj.language) then
					return nil, "project '" ..prj.name .. "' needs a language"
				end
				
				-- and the action must support it
				if (action.valid_languages) then
					if (not table.contains(action.valid_languages, prj.language)) then
						return nil, "the " .. action.shortname .. " action does not support " .. prj.language .. " projects"
					end
				end

				for cfg in premake.eachconfig(prj) do								
					
					-- every config must have a kind
					if (not cfg.kind) then
						return nil, "project '" ..prj.name .. "' needs a kind in configuration '" .. cfg.name .. "'"
					end
				
					-- and the action must support it
					if (action.valid_kinds) then
						if (not table.contains(action.valid_kinds, cfg.kind)) then
							return nil, "the " .. action.shortname .. " action does not support " .. cfg.kind .. " projects"
						end
					end
					
				end
			end
		end		
		return true
	end


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

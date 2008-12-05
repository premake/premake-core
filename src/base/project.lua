--
-- project.lua
-- Support functions for working with projects and project data.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Performs a sanity check all all of the solutions and projects 
-- in the session to be sure they meet some minimum requirements.
--

	function premake.checkprojects()
		local action = premake.actions[_ACTION]
		
		for _,sln in ipairs(_SOLUTIONS) do
			-- every solution must have at least one project
			if (#sln.projects == 0) then
				return nil, "solution '" .. sln.name .. "' needs at least one project"
			end
			
			-- every solution must list configurations
			if (not sln.configurations or #sln.configurations == 0) then
				return nil, "solution '" .. sln.name .. "' needs configurations"
			end
			
			for _,prj in ipairs(sln.projects) do
				local cfg = premake.getconfig(prj)

				-- every project must have a language
				if (not cfg.language) then
					return nil, "project '" ..prj.name .. "' needs a language"
				end
				
				-- and the action must support it
				if (action.valid_languages) then
					if (not table.contains(action.valid_languages, cfg.language)) then
						return nil, "the " .. action.shortname .. " action does not support " .. cfg.language .. " projects"
					end
				end
								
				for _,cfgname in ipairs(sln.configurations) do
					cfg = premake.getconfig(prj, cfgname)
					
					-- every config must have a kind
					if (not cfg.kind) then
						return nil, "project '" ..prj.name .. "' needs a kind in configuration '" .. cfgname .. "'"
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
-- Returns an iterator for a solution's projects.
--

	function premake.eachproject(sln)
		local i = 0
		return function ()
			i = i + 1
			if (i <= #sln.projects) then
				local prj = sln.projects[i]
				
				-- merge solution and project values
				local merged = premake.getconfig(prj)
				setmetatable(merged, getmetatable(prj))
				merged.name = prj.name
				merged.blocks = prj.blocks
				return merged
			end
		end
	end
	
	

-- 
-- Locate a project by name; case insensitive.
--

	function premake.findproject(name)
		name = name:lower()
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				if (prj.name:lower() == name) then
					return prj
				end
			end
		end
	end
	
	

--
-- Locate a file in a project with a given extension; used locate "special"
-- items such as Windows .def files.
--

	function premake.findfile(prj, extension)
		for _, fname in ipairs(prj.files) do
			if (path.getextension(fname) == extension) then
				return fname
			end
		end
	end



--
-- Retrieve the current object of the a particular type from the session.
-- The type may be "solution", "container" (the last activated solution or
-- project), or "config" (the last activated configuration). Returns the
-- requested container, or nil and an error message.
--

	function premake.getobject(t)
		local container
		
		if (t == "container" or t == "solution") then
			container = premake.CurrentContainer
		else
			container = premake.CurrentConfiguration
		end
		
		if (t == "solution" and type(container) ~= "solution") then
			container = nil
		end
		
		local msg
		if (not container) then
			if (t == "container") then
				msg = "no active solution or project"
			elseif (t == "solution") then
				msg = "no active solution"
			else
				msg = "no active solution, project, or configuration"
			end
		end
		
		return container, msg
	end
	
	
	
--
-- Determines if a field value is unique across all configurations of
-- all projects in the session. Used to create unique output targets.
--

	function premake.isuniquevalue(fieldname, value, fn)
		local count = 0
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				for _, cfgname in ipairs(sln.configurations) do
					local cfg = premake.getconfig(prj, cfgname)

					local tst
					if (fn) then
						tst = fn(cfg)
					else
						tst = cfg[fieldname]
					end
					
					if (tst == value) then 
						count = count + 1 
						if (count > 1) then return false end
					end
				end
			end
		end
		return true
	end

	

--
-- Adds values to an array field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setarray(ctype, fieldname, value, allowed)
		local container, err = premake.getobject(ctype)
		if (not container) then
			error(err, 3)
		end

		if (not container[fieldname]) then
			container[fieldname] = { }
		end

		local function doinsert(value, depth)
			if (type(value) == "table") then
				for _,v in ipairs(value) do
					doinsert(v, depth + 1)
				end
			else
				value, err = premake.checkvalue(value, allowed)
				if (not value) then
					error(err, depth)
				end
				table.insert(container[fieldname], value)
			end
		end

		if (value) then
			doinsert(value, 5)
		end
		
		return container[fieldname]
	end

	

--
-- Adds values to an array-of-directories field of a solution/project/configuration. 
-- `ctype` specifies the container type (see premake.getobject) for the field. All
-- values are converted to absolute paths before being stored.
--

	local function domatchedarray(ctype, fieldname, value, matchfunc)
		local result = { }
		
		function makeabsolute(value)
			if (type(value) == "table") then
				for _,item in ipairs(value) do
					makeabsolute(item)
				end
			else
				if value:find("*") then
					makeabsolute(matchfunc(value))
				else
					table.insert(result, path.getabsolute(value))
				end
			end
		end
		
		makeabsolute(value)
		return premake.setarray(ctype, fieldname, result)
	end
	
	function premake.setdirarray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchdirs)
	end
	
	function premake.setfilearray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchfiles)
	end
	
	
	
--
-- Set a new value for a string field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setstring(ctype, fieldname, value, allowed)
		-- find the container for this value
		local container, err = premake.getobject(ctype)
		if (not container) then
			error(err, 4)
		end
	
		-- if a value was provided, set it
		if (value) then
			value, err = premake.checkvalue(value, allowed)
			if (not value) then 
				error(err, 4)
			end
			
			container[fieldname] = value
		end
		
		return container[fieldname]	
	end
	
	
	
--
-- Walk the list of source code files, breaking them into "groups" based
-- on the directory hierarchy.
--

	local function walksources(prj, files, fn, group, nestlevel, finished)
		local grouplen = group:len()
		local gname = iif(group:endswith("/"), group:sub(1,-2), group)
		
		-- open this new group
		if (nestlevel >= 0) then
			fn(prj, gname, "GroupStart", nestlevel)
		end
		
		-- scan the list of files for items which belong in this group
		for _,fname in ipairs(files) do
			if (fname:startswith(group)) then

				-- is there a subgroup within this item?
				local _,split = fname:find("[^\.]/", grouplen + 1)
				if (split) then
					local subgroup = fname:sub(1, split)
					if (not finished[subgroup]) then
						finished[subgroup] = true
						walksources(prj, files, fn, subgroup, nestlevel + 1, finished)
					end
				end
				
			end			
		end

		-- process all files that belong in this group
		for _,fname in ipairs(files) do
			if (fname:startswith(group) and not fname:find("/", grouplen + 1, true)) then
				fn(prj, fname, "GroupItem", nestlevel + 1)
			end
		end

		-- close the group
		if (nestlevel >= 0) then
			fn(prj, gname, "GroupEnd", nestlevel)
		end
	end
	
	
	function premake.walksources(prj, files, fn)
		walksources(prj, files, fn, "", -1, {})
	end

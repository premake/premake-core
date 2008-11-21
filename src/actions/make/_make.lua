--
-- _make.lua
-- Define the makefile action(s).
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	_MAKE = { }
	

--
-- Escape a string so it can be written to a makefile.
--

	function _MAKE.esc(value)
		if (type(value) == "table") then
			local result = { }
			for _,v in ipairs(value) do
				table.insert(result, _MAKE.esc(v))
			end
			return result
		else
			local result = value:gsub(" ", "\\ ")
			return result
		end
	end
	


--
-- Get the target dependencies for a particular project configuration.
--

	function _MAKE.gettargetdeps(cfg)
		local result = { }
		local deps = premake.getdependencies(cfg)
		for _, prj in ipairs(deps) do
			local prjcfg = premake.getconfig(prj, cfg.name)
			local target = premake.gettargetfile(prjcfg, "target", nil, true)
			target = path.rebase(target, prjcfg.location, cfg.location)
			table.insert(result, _MAKE.esc(target))
		end
		return result
	end
	
	
			
--
-- Get the makefile file name for a solution or a project. If this object is the
-- only one writing to a location then I can use "Makefile". If more than one object
-- writes to the same location I use name + ".make" to keep it unique.
--

	function _MAKE.getmakefilename(this, searchprjs)
		-- how many projects/solutions use this location?
		local count = 0
		for _,sln in ipairs(_SOLUTIONS) do
			if (sln.location == this.location) then count = count + 1 end
			if (searchprjs) then
				for _,prj in ipairs(sln.projects) do
					if (prj.location == this.location) then count = count + 1 end
				end
			end
		end
		
		if (count == 1) then
			return "Makefile"
		else
			return this.name .. ".make"
		end
	end
	

--
-- Returns a list of object names, properly escaped to be included in the makefile.
--

	function _MAKE.getnames(tbl)
		local result = table.extract(tbl, "name")
		for k,v in pairs(result) do
			result[k] = _MAKE.esc(v)
		end
		return result
	end
	
		
--
-- Register the "gmake" action
--

	premake.actions["gmake"] = {
		shortname       = "GNU Make",
		description     = "GNU makefiles for POSIX, MinGW, and Cygwin",
	
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc   = { "gcc" },
			csc  = { "mcs" },
		},
		
		solutiontemplates = {
			{ function(this) return _MAKE.getmakefilename(this, false) end,  _TEMPLATES.make_solution },
		},
		
		projecttemplates = {
			{ function(this) return _MAKE.getmakefilename(this, true) end,   _TEMPLATES.make_cpp },
		},
	}

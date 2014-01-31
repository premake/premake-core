--
-- premake.lua
-- High-level helper functions for the project exporters.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--

	local solution = premake.solution
	local project = premake.project
	local config = premake.config


	premake.indentation = 0


---
-- Call the io.esc() value escaping function a value, or a list
-- of values.
--
-- @param value
--    Either a single string value, or an array of string values.
--    If an array, it may contain nested sub-arrays.
-- @return
--    Either a single, esacaped string value, or a new array of
--    escaped string values.
---

	function premake.esc(value)
		if not io.esc then
			return value
		end

		if type(value) == "table" then
			local result = {}
			table.foreachi(value, function(v)
				table.insert(result, premake.esc(v))
			end)
			return result
		else
			if io.esc then
				value = io.esc(value)
			end
			return value
		end
	end


--
-- Open a file for output, and call a function to actually do the writing.
-- Used by the actions to generate solution and project files.
--
-- @param obj
--    A solution or project object; will be based to the callback function.
-- @param ext
--    An optional extension for the generated file, with the leading dot.
-- @param callback
--    The function responsible for writing the file, should take a solution
--    or project as a parameters.
--

	function premake.generate(obj, ext, callback)
		local fn = premake.project.getfilename(obj, ext)
		printf("Generating %s...", path.getrelative(os.getcwd(), fn))

		local f, err = io.open(fn, "wb")
		if (not f) then
			error(err, 0)
		end

		premake.indentation = 0

		io.output(f)
		callback(obj)
		f:close()
	end



---
-- Write a formatted string to the exported file, after decreasing the
-- indentation level by one.
--
-- @param i
--    If set to a number, the indentation level will be decreased by
--    this amount. If nil, the indentation level is decremented and
--    no output is written. Otherwise, pass to premake.w() as the
--    formatting string, followed by any additional arguments.
---

	function premake.pop(i, ...)
		if i == nil or type(i) == "number" then
			premake.indentation = premake.indentation - (i or 1)
		else
			premake.indentation = premake.indentation - 1
			premake.w(i, ...)
		end
	end



---
-- Write a formatted string to the exported file, and increase the
-- indentation level by one.
--
-- @param i
--    If set to a number, the indentation level will be increased by
--    this amount. If nil, the indentation level is incremented and
--    no output is written. Otherwise, pass to premake.w() as the
--    formatting string, followed by any additional arguments.
---

	function premake.push(i, ...)
		if i == nil or type(i) == "number" then
			premake.indentation = premake.indentation + (i or 1)
		else
			premake.w(i, ...)
			premake.indentation = premake.indentation + 1
		end
	end



--
-- Wrap the provided value in double quotes if it contains spaces, or
-- if it contains a shell variable of the form $(...).
--

	function premake.quoted(value)
		local q = value:find(" ", 1, true)
		if not q then
			q = value:find("$%(.-%)", 1)
		end
		if q then
			value = '"' .. value .. '"'
		end
		return value
	end


--
-- Sanity check the project information loaded from the scripts, to
-- make sure it all meets some minimum requirements. Raises an error if
-- an insane state is detected.
--

	function premake.validate()
		local ctx = {}

		for sln in solution.each() do
			premake.validateSolution(sln, ctx)

			for prj in solution.eachproject(sln) do
				premake.validateProject(prj, ctx)

				for cfg in project.eachconfig(prj) do
					premake.validateConfig(cfg, ctx)
				end
			end
		end
	end


--
-- Sanity check the settings of a specific solution. Raises an error if
-- an insane state is detected.
--
-- @param sln
--    The solution to be checked.
-- @param ctx
--    The validation context; keeps track of what has already been checked.
--

	function premake.validateSolution(sln, ctx)
		-- there must be at least one build configuration
		if not sln.configurations or #sln.configurations == 0 then
			premake.error("solution '%s' does not contain any configurations", sln.name)
		end

		-- all project UUIDs must be unique
		local uuids = {}
		for prj in solution.eachproject(sln) do
			if uuids[prj.uuid] then
				premake.error("projects '%s' and '%s' have the same UUID", uuids[prj.uuid], prj.name)
			end
			uuids[prj.uuid] = prj.name
		end
	end


--
-- Sanity check the settings of a specific project. Raises an error if
-- an insane state is detected.
--
-- @param prj
--    The project to be checked.
-- @param ctx
--    The validation context; keeps track of what has already been checked.
--

	function premake.validateProject(prj, ctx)
		-- must have a language
		if not prj.language then
			premake.error("project '%s' does not have a language", prj.name)
		end

		-- check for out of scope fields
		premake.validateScopes(prj, "project", ctx)
	end


--
-- Sanity check the settings of a specific configuration. Raises an error
-- if an insane state is detected.
--
-- @param cfg
--    The configuration to be checked.
-- @param ctx
--    The validation context; keeps track of what has already been checked.
--

	function premake.validateConfig(cfg, ctx)
		-- must have a kind
		if not cfg.kind then
			premake.error("project '%s' needs a kind in configuration '%s'", cfg.project.name, cfg.name)
		end

		-- makefile configuration can only appear in C++ projects; this is the
		-- default now, so should only be a problem if overridden.
		if (cfg.kind == premake.MAKEFILE or cfg.kind == premake.NONE) and not project.iscpp(cfg.project) then
			premake.error("project '%s' uses %s kind in configuration '%s'; language must be C++", cfg.project.name, cfg.kind, cfg.name)
		end

		-- check for out of scope fields
		premake.validateScopes(cfg, "config", ctx)
	end


--
-- Check the values stored in a configuration object (solution, project, or
-- configuration) for values that might have been set out of scope.
--
-- @param cfg
--    The configuration object to validate.
-- @param expected
--    The expected scope of values in this object; one of "project" or "config".
-- @param ctx
--    The validation context; used to prevent multiple warnings on same field.
--

	function premake.validateScopes(cfg, expected, ctx)
		for name, field in pairs(premake.fields) do
			local okay = false

			-- skip fields that are at or below the expected scope
			if field.scope == "config" or field.scope == expected then
				okay = true
			end

			-- this one needs to checked
			if not okay then
				okay = premake.api.comparevalues(field, cfg[field.scope][name], cfg[name])
			end

			-- found a problem?
			if not okay then
				local key = "validate." .. field.name
				premake.warnOnce(key, "'%s' on %s '%s' differs from %s '%s'; may be set out of scope", name, expected, cfg.name, field.scope, cfg[field.scope].name)
			end

		end
	end



---
-- Write a formatted string to the exported file (the indentation
-- level is not changed). This gets called quite a lot, hence the
-- very short name.
---

	function premake.w(...)
		if select("#",...) > 0 then
			_p(premake.indentation, ...)
		else
			_p('')
		end
	end



---
-- Write a formatted string to the exported file, after passing all
-- arguments (except for the first, which is the formatting string)
-- through premake.esc().
---

	function premake.x(msg, ...)
		for i = 1, #arg do
			arg[i] = premake.esc(arg[i])
		end
		premake.w(msg, unpack(arg))
	end

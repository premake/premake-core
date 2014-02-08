--
-- premake.lua
-- High-level helper functions for the project exporters.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local solution = premake.solution
	local project = premake.project
	local config = premake.config


-- Store captured output text for later testing

	local _captured

-- The string escaping function.

	local _esc = function(v) return v end

-- The output settings and defaults

	local _eol = "\n"
	local _indentString = "\t"
	local _indentLevel = 0



---
-- Capture and store everything sent through the output stream functions
-- premake.w(), premake.x(), and premake.out(). Retrieve the captured
-- text using the premake.captured() function.
--
-- @param fn
--    A function to execute. Any output calls made during the execution
--    of the function will be captured.
-- @return
--    The captured output.
---

	function premake.capture(fn)
		-- start a new capture without forgetting the old one
		local old = _captured
		_captured = {}

		-- capture
		fn()

		-- build the result
		local captured = premake.captured()

		-- restore the old capture and done
		_captured = old
		return captured
	end



--
-- Returns the captured text and stops capturing.
--

	function premake.captured()
		if _captured then
			return table.concat(_captured, _eol)
		else
			return ""
		end
	end



---
-- Set the output stream end-of-line sequence.
--
-- @param s
--    The string to use to mark line ends, or nil to keep the existing
--    EOL sequence.
-- @return
--    The new EOL sequence.
---

	function premake.eol(s)
		_eol = s or _eol
		return _eol
	end



---
-- Handle escaping of strings for various outputs.
--
-- @param value
--    If this is a string: escape it and return the new value. If it is an
--    array, return a new array of escaped values.
-- @return
--    If the input was a single string, returns the escaped version. If it
--    was an array, returns an corresponding array of escaped strings.
---

	function premake.esc(value)
		if type(value) == "table" then
			local result = {}
			local n = #value
			for i = 1, n do
				table.insert(result, premake.esc(value[i]))
			end
			return result
		end

		return _esc(value or "")
	end



---
-- Set a new string escaping function.
--
-- @param func
--    The new escaping function, which should take a single string argument
--    and return the escaped version of that string. If nil, uses a default
--    no-op function.
---

	function premake.escaper(func)
		_esc = func
		if not _esc then
			_esc = function (value) return value end
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

		io.output(f)
		callback(obj)
		f:close()
	end



---
-- Sets the output indentation parameters.
--
-- @param s
--    The indentation string.
-- @param i
--    The new indentation level, or nil to reset to zero.
---

	function premake.indent(s, i)
		_indentString = s or "\t"
		_indentLevel = i or 0
	end



---
-- Write a simple, unformatted string to the output stream, with no indentation
-- or end of line sequence.
---

	function premake.out(s)
		if not _captured then
			io.write(s)
		else
			table.insert(_captured, s)
		end
	end



---
-- Write a simple, unformatted string to the output stream, with no indentation,
-- and append the current EOL sequence.
---

	function premake.outln(s)
		if not _captured then
			io.write(s)
			io.write(_eol or "\n")
		else
			table.insert(_captured, s)
		end
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
			_indentLevel = _indentLevel - (i or 1)
		else
			_indentLevel = _indentLevel - 1
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
			_indentLevel = _indentLevel + (i or 1)
		else
			premake.w(i, ...)
			_indentLevel = _indentLevel + 1
		end
	end



---
-- Wrap the provided value in double quotes if it contains spaces, or
-- if it contains a shell variable of the form $(...).
---

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
-- Write a formatted string to the exported file, at the current
-- level of indentation, and appends an end of line sequence.
-- This gets called quite a lot, hence the very short name.
---

	function premake.w(...)
		if select("#",...) > 0 then
			premake.outln(string.rep(_indentString or "\t", _indentLevel) .. string.format(...))
		else
			premake.outln('');
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



--
-- These are the output shortcuts that I used before switching to the
-- indentation-aware calls above. They are still in use all over the
-- place, including lots of community code, so let's keep them around.
--
-- @param i
--    This will either be a printf-style formatting string suitable
--    for passing to string.format(), OR an integer number indicating
--    the desired level of indentation. If the latter, the formatting
--    string should be the next argument in the list.
-- @param ...
--    The values necessary to fill out the formatting string tokens.
--

	function _p(i, ...)
		if type(i) == "number" then
			_indentLevel = i
			premake.w(...)
		else
			_indentLevel = 0
			premake.w(i, ...)
		end
	end

	function _x(i, ...)
		for i = 2, #arg do
			arg[i] = premake.esc(arg[i])
		end
		_p(i, unpack(arg))
	end

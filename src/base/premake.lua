--
-- premake.lua
-- High-level processing functions.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--

	local solution = premake.solution
	local project = premake5.project
	local config = premake5.config


---
-- Add a namespace for extensions to use.
---

	premake.extensions = {}


--
-- Define some commonly used symbols, for future-proofing.
--

	premake.C           = "C"
	premake.C7          = "c7"
	premake.CLANG       = "clang"
	premake.CONSOLEAPP  = "ConsoleApp"
	premake.CPP         = "C++"
	premake.CSHARP      = "C#"
	premake.GCC         = "gcc"
	premake.HAIKU       = "haiku"
	premake.LINUX       = "linux"
	premake.MACOSX      = "macosx"
	premake.MAKEFILE    = "Makefile"
	premake.POSIX       = "posix"
	premake.PS3         = "ps3"
	premake.SHAREDLIB   = "SharedLib"
	premake.STATICLIB   = "StaticLib"
	premake.UNIVERSAL   = "universal"
	premake.WINDOWEDAPP = "WindowedApp"
	premake.WINDOWS     = "windows"
	premake.X32         = "x32"
	premake.X64         = "x64"
	premake.XBOX360     = "xbox360"


---
-- Call a list of functions to generate a block of project file elements.
-- This follows a particular convention for where the list of element
-- names and the implementation functions should be stored; read the
-- parameter descriptions for more information.
--
-- @param namespace
--    The namespace table that contains the functions to be called.
-- @param elements
--    The name of the element list. This list should be contained within
--    a namespace called "elements", enclosed in the namespace provided
--    above. So if namespace is "vs2010", and elements is "header", the
--    list variable will be accessed as vs2010.elements.header.
-- @param ...
--    An optional set of arguments to be passed to each of the functions
--    that are called.
---

	function premake.callarray(namespace, array, ...)
		local n = #array
		for i = 1, n do
			local fn = namespace[array[i]]
			if not fn then
				error(string.format("Unable to find function '%s'", name))
			end
			fn(...)
		end

	end


--
-- Raises an error, with a formatted message built from the provided
-- arguments.
--
-- @param message
--    The error message, which may contain string formatting tokens.
-- @param ...
--    Values to fill in the string formatting tokens.
--

	function premake.error(message, ...)
		error(string.format("** Error: " .. message, ...), 0)
	end


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
		local fn = premake5.project.getfilename(obj, ext)
		printf("Generating %s...", path.getrelative(os.getcwd(), fn))

		local f, err = io.open(fn, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		callback(obj)
		f:close()
	end


--
-- Override an existing function with a new one; the original function
-- is passed as the first argument to the replacement when called.
--
-- @param scope
--    The table containing the function to be overridden. Use _G for
--    global functions.
-- @param name
--    The name of the function to override.
-- @param repl
--    The replacement function. The first argument to the function
--    will be the original implementation.
--

	function premake.override(scope, name, repl)
		local original = scope[name]
		scope[name] = function(...)
			return repl(original, ...)
		end
	end


--
-- Sanity check the project information loaded from the scripts, to
-- make sure it all meets some minimum requirements. Raises an error if
-- an insane state is detected.
--

	function premake.validate()
		local ctx = {}
		ctx.warnings = {}

		for sln in solution.each() do
			premake.validateSolution(sln, ctx)

			for prj in solution.eachproject_ng(sln) do
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
		for prj in solution.eachproject_ng(sln) do
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

		-- makefile configuration can only appear in C++ projects
		if cfg.kind == premake.MAKEFILE and not project.iscpp(cfg.project) then
			premake.error("project '%s' uses Makefile kind in configuration '%s'; language must be C++", cfg.project.name, cfg.name)
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

			-- already warned about this field?
			if ctx.warnings[field.name] then
				okay = true
			end

			-- this one needs to checked
			if not okay then
				okay = premake.api.comparevalues(field, cfg[field.scope][name], cfg[name])
			end

			-- found a problem?
			if not okay then
				ctx.warnings[field.name] = true
				premake.warn("'%s' on %s '%s' differs from %s '%s'; may be set out of scope", name, expected, cfg.name, field.scope, cfg[field.scope].name)
			end

		end
	end


--
-- Display a warning, with a formatted message built from the provided
-- arguments.
--
-- @param message
--    The warning message, which may contain string formatting tokens.
-- @param ...
--    Values to fill in the string formatting tokens.
--

	function premake.warn(message, ...)
		io.stderr:write(string.format("** Warning: " .. message .. "\n", ...))
	end


--
-- Displays a warning just once per run.
--
-- @param message
--    The warning message, which may contain string formatting tokens.
-- @param ...
--    Values to fill in the string formatting tokens.
--

	function premake.warnOnce(ctx, message, ...)
		if not ctx.warnings[message] then
			ctx.warnings[message] = true
			premake.warn(message, ...)
		end
	end

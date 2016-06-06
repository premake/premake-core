---
-- Base definitions required by all the other scripts.
-- @copyright 2002-2015 Jason Perkins and the Premake project
---

	premake = premake or {}
	premake._VERSION = _PREMAKE_VERSION
	package.loaded["premake"] = premake

	premake.modules = {}
	premake.extensions = premake.modules

	local semver = dofile('semver.lua')
	local p = premake


-- Keep track of warnings that have been shown, so they don't get shown twice

	local _warnings = {}

-- Keep track of aliased functions, so I can resolve to canonical names

	local _aliases = {}

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
	premake.MBCS        = "MBCS"
	premake.NONE        = "None"
	premake.DEFAULT     = "Default"
	premake.ON          = "On"
	premake.OFF         = "Off"
	premake.POSIX       = "posix"
	premake.PS3         = "ps3"
	premake.SHAREDLIB   = "SharedLib"
	premake.STATICLIB   = "StaticLib"
	premake.UNICODE     = "Unicode"
	premake.UNIVERSAL   = "universal"
	premake.UTILITY     = "Utility"
	premake.WINDOWEDAPP = "WindowedApp"
	premake.WINDOWS     = "windows"
	premake.X86         = "x86"
	premake.X86_64      = "x86_64"
	premake.XBOX360     = "xbox360"



---
-- Provide an alias for a function in a namespace. Calls to the alias will
-- invoke the canonical function, and attempts to override the alias will
-- instead override the canonical call.
--
-- @param scope
--    The table containing the function to be overridden. Use _G for
--    global functions.
-- @param canonical
--    The name of the function to be aliased (a string value)
-- @param alias
--    The new alias for the function (another string value).
---

	function p.alias(scope, canonical, alias)
		scope, canonical = p.resolveAlias(scope, canonical)
		if not scope[canonical] then
			error("unable to alias '" .. canonical .. "'; no such function", 2)
		end

		_aliases[scope] = _aliases[scope] or {}
		_aliases[scope][alias] = canonical

		scope[alias] = function(...)
			return scope[canonical](...)
		end
	end



---
-- Call a list of functions.
--
-- @param funcs
--    The list of functions to be called, or a function that can be called
--    to build and return the list. If this is a function, it will be called
--    with all of the additional arguments (below).
-- @param ...
--    An optional set of arguments to be passed to each of the functions as
--    as they are called.
---

	function premake.callArray(funcs, ...)
		if type(funcs) == "function" then
			funcs = funcs(...)
		end
		if funcs then
			for i = 1, #funcs do
				funcs[i](...)
			end
		end
	end


	-- TODO: THIS IMPLEMENTATION IS GOING AWAY

	function premake.callarray(namespace, array, ...)
		local n = #array
		for i = 1, n do
			local fn = namespace[array[i]]
			if not fn then
				error(string.format("Unable to find function '%s'", array[i]))
			end
			fn(...)
		end

	end



---
-- Compare a version string that uses semver semantics against a
-- version comparision string. Comparisions take the form of ">=5.0" (5.0 or
-- later), "5.0" (5.0 or later), ">=5.0 <6.0" (5.0 or later but not 6.0 or
-- later).
--
-- @param version
--    The version to be tested.
-- @param checks
--    The comparision string to be evaluated.
-- @return
--    True if the comparisions pass, false if any fail.
---

	function p.checkVersion(version, checks)
		if not version then
			return false
		end

		local function eq(a, b) return a == b end
		local function le(a, b) return a <= b end
		local function lt(a, b) return a < b  end
		local function ge(a, b) return a >= b end
		local function gt(a, b) return a > b  end
		local function compat(a, b) return a ^ b  end

		version = semver(version)
		checks = string.explode(checks, " ", true)
		for i = 1, #checks do
			local check = checks[i]
			local func
			if check:startswith(">=") then
				func = ge
				check = check:sub(3)
			elseif check:startswith(">") then
				func = gt
				check = check:sub(2)
			elseif check:startswith("<=") then
				func = le
				check = check:sub(3)
			elseif check:startswith("<") then
				func = lt
				check = check:sub(2)
			elseif check:startswith("=") then
				func = eq
				check = check:sub(2)
			elseif check:startswith("^") then
				func = compat
				check = check:sub(2)
			else
				func = ge
			end

			check = semver(check)
			if not func(version, check) then
				return false
			end
		end

		return true
	end



	function premake.clearWarnings()
		_warnings = {}
	end



--
-- Raise an error, with a formatted message built from the provided
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


--
-- Finds the correct premake script filename to be run.
--
-- @param fname
--    The filename of the script to run.
-- @return
--    The correct location and filename of the script to run.
--

	function premake.findProjectScript(fname)
		return os.locate(fname, fname .. ".lua", path.join(fname, "premake5.lua"), path.join(fname, "premake4.lua"))
	end


---
-- "Immediate If" - returns one of the two values depending on the value
-- of the provided condition. Note that both the true and false expressions
-- will be evaluated regardless of the condition, even if only one result
-- is returned.
--
-- @param condition
--    A boolean condition, determining which value gets returned.
-- @param trueValue
--    The value to return if the condition is true.
-- @param falseValue
--    The value to return if the condition is false.
-- @return
--    One of trueValue or falseValue.
---

	function iif(condition, trueValue, falseValue)
		if condition then
			return trueValue
		else
			return falseValue
		end
	end



---
-- Override an existing function with a new implementation; the original
-- function is passed as the first argument to the replacement when called.
--
-- @param scope
--    The table containing the function to be overridden. Use _G for
--    global functions.
-- @param name
--    The name of the function to override (a string value).
-- @param repl
--    The replacement function. The first argument to the function
--    will be the original implementation, followed by the arguments
--    passed to the original call.
---

	function premake.override(scope, name, repl)
		scope, name = p.resolveAlias(scope, name)

		local original = scope[name]
		if not original then
			error("unable to override '" .. name .. "'; no such function", 2)
		end

		scope[name] = function(...)
			return repl(original, ...)
		end

		-- Functions from premake.main are special in that they are fetched
		-- from an array, which can be modified by system and project scripts,
		-- instead of a function which would have already been called before
		-- those scripts could have run. Since the array will have already
		-- been evaluated by the time override() is called, the new value
		-- won't be picked up as it would with the function-fetched call
		-- lists. Special case the workaround for that here so everyone else
		-- can just override without having to think about the difference.
		if scope == premake.main then
			table.replace(premake.main.elements, original, scope[name])
		end
	end



---
-- Find the canonical name and scope of a function, resolving any aliases.
--
-- @param scope
--    The table containing the function to be overridden. Use _G for
--    global functions.
-- @param name
--    The name of the function to resolve.
-- @return
--    The canonical scope and function name (a string value).
---

	function p.resolveAlias(scope, name)
		local aliases = _aliases[scope]
		if aliases then
			while aliases[name] do
				name = aliases[name]
			end
		end
		return scope, name
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
		message = string.format(message, ...)
		if _OPTIONS.fatal then
			error(message)
		else
			io.stderr:write(string.format("** Warning: " .. message .. "\n", ...))
		end
	end


--
-- Displays a warning just once per run.
--
-- @param key
--    A unique key to identify this warning. Subsequent warnings messages
--    using the same key will not be shown.
-- @param message
--    The warning message, which may contain string formatting tokens.
-- @param ...
--    Values to fill in the string formatting tokens.
--

	function premake.warnOnce(key, message, ...)
		if not _warnings[key] then
			_warnings[key] = true
			premake.warn(message, ...)
		end
	end



--
-- A shortcut for printing formatted output.
--

	function printf(msg, ...)
		print(string.format(msg, ...))
	end

--
-- A shortcut for printing formatted output in verbose mode.
--
	function verbosef(msg, ...)
		if _OPTIONS.verbose then
			print(string.format(msg, ...))
		end
	end

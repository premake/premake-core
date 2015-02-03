---
-- Base definitions required by all the other scripts.
-- @copyright 2002-2013 Jason Perkins and the Premake project
---

	premake = {}
	premake.modules = {}
	premake.tools = {}

	premake.extensions = premake.modules


-- Keep track of warnings that have been shown, so they don't get shown twice

	local _warnings = {}


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
	premake.NONE        = "None"
	premake.OFF         = "Off"
	premake.POSIX       = "posix"
	premake.PS3         = "ps3"
	premake.SHAREDLIB   = "SharedLib"
	premake.STATICLIB   = "StaticLib"
	premake.UNIVERSAL   = "universal"
	premake.UTILITY     = "Utility"
	premake.WINDOWEDAPP = "WindowedApp"
	premake.WINDOWS     = "windows"
	premake.X32         = "x32"
	premake.X64         = "x64"
	premake.XBOX360     = "xbox360"



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
		for i = 1, #funcs do
			funcs[i](...)
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
-- Clears the list of already fired warning messages, allowing them
-- to be fired again.
---

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
		local original = scope[name]
		if not original then
			error("unable to override '" .. name .. "'; no such function", 2)
		end
		scope[name] = function(...)
			return repl(original, ...)
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
		print(string.format(msg, unpack(arg)))
	end

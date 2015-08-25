--
-- premake.lua
-- High-level helper functions for the project exporters.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

	local p = premake



-- Store captured output text for later testing

	local _captured

-- The string escaping function.

	local _esc = function(v) return v end

-- The output settings and defaults

	local _eol = "\n"
	local _indentString = "\t"
	local _indentLevel = 0

-- Set up the global configuration scope. There can be only one.

	global("root")



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
		_captured = buffered.new()

		-- capture
		fn()

		-- build the result
		local captured = premake.captured()

		-- free the capture buffer.
		buffered.close(_captured)

		-- restore the old capture and done
		_captured = old
		return captured
	end



--
-- Returns the captured text and stops capturing.
--

	function premake.captured()
		if _captured then
			return buffered.tostring(_captured)
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
-- Used by the actions to generate workspace and project files.
--
-- @param obj
--    A workspace or project object; will be passed to the callback function.
-- @param ext
--    An optional extension for the generated file, with the leading dot.
-- @param callback
--    The function responsible for writing the file, should take a workspace
--    or project as a parameters.
--

	function premake.generate(obj, ext, callback)
		local output = premake.capture(function ()
			_indentLevel = 0
			callback(obj)
			_indentLevel = 0
		end)

		local fn = premake.filename(obj, ext)

		-- make sure output folder exists.
		local dir = path.getdirectory(fn)
		ok, err = os.mkdir(dir)
		if not ok then
			error(err, 0)
		end

		local f, err = os.writefile_ifnotequal(output, fn);

		if (f < 0) then
			error(err, 0)
		elseif (f > 0) then
			printf("Generated %s...", path.getrelative(os.getcwd(), fn))
		end
	end



---
-- Returns the full path a file generated from any of the project
-- objects (project, workspace, rule).
--
-- @param obj
--    The project object being generated.
-- @param ext
--    An optional extension for the generated file, with the leading dot.
---

function premake.filename(obj, ext)
	local fname = obj.location or obj.basedir
	if ext and not ext:startswith(".") then
		fname = path.join(fname, ext)
	else
		fname = path.join(fname, obj.filename)
		if ext then
			fname = fname .. ext
		end
	end
	return path.getabsolute(fname)
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
			buffered.write(_captured, s)
		end
	end



---
-- Write a simple, unformatted string to the output stream, with no indentation,
-- and append the current EOL sequence.
---

	function premake.outln(s)
		premake.out(s)
		premake.out(_eol or "\n")
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
-- Output a UTF-8 BOM to the exported file.
--

	function p.utf8()
		p.out('\239\187\191')
	end



---
-- Write a formatted string to the exported file, at the current
-- level of indentation, and appends an end of line sequence.
-- This gets called quite a lot, hence the very short name.
---

	function premake.w(...)
		if select("#", ...) > 0 then
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
		local arg = {...}
		for i = 1, #arg do
			arg[i] = premake.esc(arg[i])
		end
		premake.w(msg, unpack(arg))
	end



---
-- Write a opening XML element for a UTF-8 encoded file. Used by
-- several different files for different actions, so makes sense
-- to have a common call for it.
--
-- @param upper
--    If true, the encoding is written in uppercase.
---

	function premake.xmlUtf8(upper)
		local encoding = iif(upper, "UTF-8", "utf-8")
		premake.w('<?xml version="1.0" encoding="%s"?>', encoding)
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
		local arg = {...}
		for i = 2, #arg do
			arg[i] = premake.esc(arg[i])
		end
		_p(i, unpack(arg))
	end

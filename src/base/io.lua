--
-- io.lua
-- Additions to the I/O namespace.
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--


--
-- Prepare to capture the output from all subsequent calls to io.printf(),
-- used for automated testing of the generators.
--

	function io.capture(fn)
		-- start a new capture without forgetting the old one
		local old = io._captured
		io._captured = {}

		-- capture
		fn()

		-- build the result
		local captured = io.captured()

		-- restore the old capture and done
		io._captured = old
		io._captured_string = nil
		return captured
	end



--
-- Returns the captured text and stops capturing.
--

	function io.captured()
		if io._captured then
			if not io._captured_string then
				io._captured_string = table.concat(io._captured, io.eol)
			end
			return io._captured_string
		end
	end


--
-- Open an overload of the io.open() function, which will create any missing
-- subdirectories in the filename if "mode" is set to writeable.
--

	local builtin_open = io.open
	function io.open(fname, mode)
		if (mode) then
			if (mode:find("w")) then
				local dir = path.getdirectory(fname)
				ok, err = os.mkdir(dir)
				if (not ok) then
					error(err, 0)
				end
			end
		end
		return builtin_open(fname, mode)
	end



--
-- A shortcut for printing formatted output to an output stream.
--

	function io.printf(msg, ...)
		if type(msg) == "number" then
			local str, fmt, x = unpack(arg)
			s = string.rep(io.indent or "\t", msg) .. string.format(unpack(arg))
		else
			s = string.format(msg, unpack(arg))
		end

		if not io._captured then
			io.write(s)
		else
			table.insert(io._captured, s)
			io._captured_string = nil
		end
	end


--
-- Output a UTF-8 signature.
--

	function io.utf8()
		io.write('\239\187\191')
	end


--
-- Because I use io.printf() so often in the generators, create a terse shortcut
-- for it. This saves me typing, and also reduces the size of the executable.
--

	function _p(msg, ...)
		io.printf(msg, unpack(arg))
		if not io._captured then
			io.write(io.eol or "\n")
		end
	end


--
-- Another variation that calls io.esc() on all of its arguments before
-- write out the formatting string.
--

	function _x(msg, ...)
		for i = 2, #arg do
			arg[i] = premake.esc(arg[i])
		end
		_p(msg, unpack(arg))
	end

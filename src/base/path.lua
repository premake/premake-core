--
-- path.lua
-- Path manipulation functions.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--


--
-- Appends a file extension to the path. Verifies that the extension
-- isn't already present, and adjusts quotes as necessary.
--

	function path.appendExtension(p, ext)
		-- if the extension is nil or empty, do nothing
		if not ext or ext == "" then
			return p
		end

		-- if the path ends with a quote, pull it off
		local endquote
		if p:endswith('"') then
			p = p:sub(1, -2)
			endquote = '"'
		end

		-- add the extension if it isn't there already
		if not path.hasextension(p, ext) then
			p = p .. ext
		end

		-- put the quote back if necessary
		if endquote then
			p = p .. endquote
		end

		return p
	end

	path.appendextension = path.appendExtension



--
-- Retrieve the filename portion of a path, without any extension.
--

	function path.getbasename(p)
		local name = path.getname(p)
		local i = name:findlast(".", true)
		if (i) then
			return name:sub(1, i - 1)
		else
			return name
		end
	end


--
-- Retrieve the directory portion of a path, or an empty string if
-- the path does not include a directory.
--

	function path.getdirectory(p)
		local i = p:findlast("/", true)
		if (i) then
			if i > 1 then i = i - 1 end
			return p:sub(1, i)
		else
			return "."
		end
	end


--
-- Retrieve the drive letter, if a Windows path.
--

	function path.getdrive(p)
		local ch1 = p:sub(1,1)
		local ch2 = p:sub(2,2)
		if ch2 == ":" then
			return ch1
		end
	end



--
-- Retrieve the file extension.
--

	function path.getextension(p)
		p = path.getname(p)
		local i = p:findlast(".", true)
		if (i) then
			return p:sub(i)
		else
			return ""
		end
	end



--
-- Remove extension from path.
--

	function path.removeextension(p)
		local i = p:findlast(".", true)
		if (i) then
		if i > 1 then i = i - 1 end
			return p:sub(1, i)
		else
			return ""
		end
	end


--
-- Retrieve the filename portion of a path.
--

	function path.getname(p)
		local i = p:findlast("[/\\]")
		if (i) then
			return p:sub(i + 1)
		else
			return p
		end
	end




--
-- Returns true if the filename has a particular extension.
--
-- @param fname
--    The file name to test.
-- @param extensions
--    The extension(s) to test. Maybe be a string or table.
--

	function path.hasextension(fname, extensions)
		local fext = path.getextension(fname):lower()
		if type(extensions) == "table" then
			for _, extension in pairs(extensions) do
				if fext == extension then
					return true
				end
			end
			return false
		else
			return (fext == extensions)
		end
	end


--
-- Returns true if the filename represents various source languages.
--

	function path.isasmfile(fname)
		return path.hasextension(fname, { ".s" })
	end

	function path.iscfile(fname)
		return path.hasextension(fname, { ".c" })
			or path.isasmfile(fname)	-- is this really right?
			or path.isobjcfile(fname)	-- there is code that depends on this behaviour, which would need to change
	end

	function path.iscppfile(fname)
		return path.hasextension(fname, { ".cc", ".cpp", ".cxx", ".c++" })
			or path.isobjcppfile(fname)	-- is this really right?
			or path.iscfile(fname)
	end

	function path.isobjcfile(fname)
		return path.hasextension(fname, { ".m" })
	end

	function path.isobjcppfile(fname)
		return path.hasextension(fname, { ".mm" })
	end

	function path.iscppheader(fname)
		return path.hasextension(fname, { ".h", ".hh", ".hpp", ".hxx" })
	end


--
-- Returns true if the filename represents a native language source file.
-- These checks are used to prevent passing non-code files to the compiler
-- in makefiles. It is not foolproof, but it has held up well. I'm open to
-- better suggestions.
--

	function path.isnativefile(fname)
		return path.iscfile(fname)
			or path.iscppfile(fname)
			or path.isasmfile(fname)
			or path.isobjcfile(fname)
			or path.isobjcppfile(fname)
	end


--
-- Returns true if the filename represents an OS X framework.
--

	function path.isframework(fname)
		return path.hasextension(fname, ".framework")
	end


---
-- Is this a type of file that can be linked?
---

	function path.islinkable(fname)
		return path.hasextension(fname, { ".o", ".obj", ".a", ".lib", ".so" })
	end



--
-- Returns true if the filename represents an object file.
--

	function path.isobjectfile(fname)
		return path.hasextension(fname, { ".o", ".obj" })
	end


--
-- Returns true if the filename represents a Windows resource file. This check
-- is used to prevent passing non-resources to the compiler in makefiles.
--

	function path.isresourcefile(fname)
		return path.hasextension(fname, ".rc")
	end

--
-- Returns true if the filename represents a Windows idl file.
--

	function path.isidlfile(fname)
		return path.hasextension(fname, ".idl")
	end


--
-- Returns true if the filename represents a hlsl shader file.
--

	function path.ishlslfile(fname)
		return path.hasextension(fname, ".hlsl")
	end


--
-- Takes a path which is relative to one location and makes it relative
-- to another location instead.
--

	function path.rebase(p, oldbase, newbase)
		p = path.getabsolute(path.join(oldbase, p))
		p = path.getrelative(newbase, p)
		return p
	end



--
-- Replace the file extension.
--

	function path.replaceextension(p, newext)
		local ext = path.getextension(p)

		if not ext then
			return p
		end

		if #newext > 0 and not newext:findlast(".", true) then
			newext = "."..newext
		end

		return p:match("^(.*)"..ext.."$")..newext
	end

--
-- Get the default seperator for path.translate
--

	function path.getDefaultSeparator()
		if os.istarget('windows') then
			return '\\'
		else
			return '/'
		end
	end

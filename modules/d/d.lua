
--
-- Create a D namespace to isolate the additions
--
	premake.extensions.d = {}
	local project = premake5.project

	local d = premake.extensions.d
	d.support_url = "https://bitbucket.org/premakeext/d/wiki/Home"

	d.printf = function( msg, ... )
		printf( "[premake-d] " .. msg, ...)
	end

	d.printf( "Premake D Extension (" .. d.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]; 
	package.path = this_dir .. "tools/?.lua;" .. this_dir .. "actions/?.lua;".. package.path
--	d.printf( "Added D tools/actions directories to LUA_PATH: %s", package.path )

--
-- Register the D extension
--
	premake.D = "D"

	local lang = premake.fields["language"];
	if lang ~= nil and lang.allowed.D == nil then
		table.insert( lang.allowed, premake.D )
	end

--
-- Provide information for the help output
--
	newoption
	{
		trigger	 = "dc",
		value	   = "VALUE",
		description = "Choose a D compiler",
		allowed = {
			{ "dmd", "Digital Mars (dmd)" },
			{ "gdc", "GNU GDC (gdc)" },
			{ "ldc", "LLVM LDC (ldc2)" },
		}
	}

--
-- Return the appropriate tool interface, based on the target language and
-- any relevant command-line options.
--

	premake.override(premake, "gettool", function(oldfn, cfg)
		if project.iscpp(cfg) then
			if _OPTIONS.cc then
				return premake[_OPTIONS.cc]
			end
			local action = premake.action.current()
			if action.valid_tools then
				return premake[action.valid_tools.cc[1]]
			end
			return premake.gcc
		elseif project.isd(cfg) then
			if _OPTIONS.dc then
				return premake[_OPTIONS.dc]
			end
			local action = premake.action.current()
			if action.valid_tools then
				return premake[action.valid_tools.dc[1]]
			end
			return premake.dmd
		else
			return premake.dotnet
		end
	end)

--
-- Patch the project structure to allow the determination of project type
-- This is then used in the override of gmake.onproject() in the
-- extension files
--

	function project.isd(prj)
		return string.lower( prj.language ) == string.lower( premake.D )
	end

--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d", ".di" })
	end

--
-- Returns true if the project uses the D language.
--

	function premake.isdproject(prj)
		local language = prj.language or prj.solution.language
		return language == "D"
	end

--
-- Add our valid actions/tools to the predefined action(s)
-- For each of the nominated allowed toolsets in the 'dc' options above,
-- we require a similarly named tools file in 'd/tools/<dc>.lua
--

	local toolsets = premake.fields[ "toolset" ]
	for k,v in pairs({"dmd", "gdc", "ldc"}) do
		require( v )
		d.printf( "Loaded D tool '%s.lua'", v )
		if toolsets ~= nil then
			table.insert( toolsets.allowed, v )
		end
	end

--
-- For each registered premake <action>, we can simply add a file to the
-- 'd/actions/' extension subdirectory named 'd/actions/<action>.lua' and the following
-- iteration will 'require' it into the system.  Hence we can patch any/all
-- pre-defined actions by adding a named file.  This eases development as
-- we don't need to cram make stuff in with VS stuff etc.
--
	for k,v in pairs({ "gmake", "vstudio" }) do
		require( v )
		d.printf( "Loaded D action '%s.lua'", v )
	end


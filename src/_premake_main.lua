--
-- _premake_main.lua
-- Script-side entry point for the main program logic.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	local shorthelp     = "Type 'premake4 --help' for help"
	local versionhelp   = "premake4 (Premake Build Script Generator) %s"
	local scriptfile    = "premake4.lua"
	


--
-- Display the help text
--

	local function showhelp()
		actions = { }
		for name,_ in pairs(premake.actions) do table.insert(actions, name) end
		table.sort(actions)
		
		printf("Premake %s, a build script generator", _PREMAKE_VERSION)
		printf(_PREMAKE_COPYRIGHT)
		printf("%s %s", _VERSION, _COPYRIGHT)
		printf("")
		printf("Usage: premake4 [options] action [arguments]")
		printf("")

		printf("ACTIONS")
		printf("")
		for _,name in ipairs(actions) do
			printf("  %-17s %s", name, premake.actions[name].description)
		end
		printf("")

		printf("OPTIONS")
		printf("")
		printf(" --file=name       Process the specified Premake script file")
		printf(" --help            Display this information")
		printf(" --scripts=path    Search for additional scripts on the given path")
		printf(" --version         Display version information")
		printf("")

		printf("For additional information, see http://industriousone.com/premake")
	end


--
-- Script-side program entry point.
--

	function _premake_main(scriptpath)
		
		-- if running off the disk (in debug mode), load everything 
		-- listed in _manifest.lua; the list divisions make sure
		-- everything gets initialized in the proper order.
		
		if (scriptpath) then
			-- core code first
			local s, t, a  = dofile(scriptpath .. "/_manifest.lua")
			for i = 1, #s - 1 do
				dofile(scriptpath.."/"..s[i])
			end
			
			-- then the templates
			for _,v in ipairs(t) do
				local n = path.getbasename(v)
				_TEMPLATES[n] = premake.loadtemplatefile(scriptpath.."/"..v)
			end
			
			-- finally the actions
			for _,v in ipairs(a) do
				dofile(scriptpath.."/"..v)
			end
		end
		
		
		-- If there is a project script available, run it to get the
		-- project information, available options and actions, etc.
		
		local fname = _OPTIONS["file"] or scriptfile
		if (os.isfile(fname)) then
			dofile(fname)
		end
		
		
		-- Process special options like /version and /help
		
		if (_OPTIONS["version"]) then
			printf(versionhelp, _PREMAKE_VERSION)
			return 1
		end
		
		if (_OPTIONS["help"]) then
			showhelp()
			return 1
		end
		
			
		-- If no action was specified, show a short help message
		
		if (not _ACTION) then
			print(shorthelp)
			return 1
		end

		
		-- If there wasn't a project script I've got to bail now
		
		if (not os.isfile(fname)) then
			error("No Premake script ("..scriptfile..") found!", 2)
		end

		
		-- Prep the session, and then hand off control to the action
		local action = premake.actions[name]
		if (not premake.actions[_ACTION]) then
			error("Error: No such action '".._ACTION.."'", 0)
		end

		ok, err = premake.checktools()
		if (not ok) then error("Error: " .. err, 0) end
		
		ok, err = premake.checkprojects()
		if (not ok) then error("Error: " .. err, 0) end
		
		premake.doaction(_ACTION)		
		return 0

	end
	
--
-- _premake_main.lua
-- Script-side entry point for the main program logic.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--


	local scriptfile    = "premake4.lua"
	local shorthelp     = "Type 'premake4 --help' for help"
	local versionhelp   = "premake4 (Premake Build Script Generator) %s"
	
	_WORKING_DIR        = os.getcwd()


--
-- Script-side program entry point.
--

	function _premake_main(scriptpath)
		
		-- if running off the disk (in debug mode), load everything 
		-- listed in _manifest.lua; the list divisions make sure
		-- everything gets initialized in the proper order.
		
		if (scriptpath) then
			local scripts  = dofile(scriptpath .. "/_manifest.lua")
			for _,v in ipairs(scripts) do
				dofile(scriptpath .. "/" .. v)
			end
		end
		

		-- Now that the scripts are loaded, I can use path.getabsolute() to properly
		-- canonicalize the executable path.
		
		_PREMAKE_COMMAND = path.getabsolute(_PREMAKE_COMMAND)


		-- The "next-gen" actions have now replaced their deprecated counterparts. 
		-- Provide a warning for a little while before I remove them entirely.
		if _ACTION:endswith("ng") then
			_ACTION = _ACTION:sub(1, -3)
			print(string.format("** Warning: '%sng' has been deprecated; use '%s' instead", _ACTION, _ACTION))
		end

		-- Set up the environment for the chosen action early, so side-effects
		-- can be picked up by the scripts.

		premake.action.set(_ACTION)

		
		-- Seed the random number generator so actions don't have to do it themselves
		
		math.randomseed(os.time())
		
		
		-- If there is a project script available, run it to get the
		-- project information, available options and actions, etc.
		
		local fname = _OPTIONS["file"] or scriptfile
		if (os.isfile(fname)) then
			dofile(fname)
		end


		-- Process special options
		
		if (_OPTIONS["version"]) then
			printf(versionhelp, _PREMAKE_VERSION)
			return 1
		end
		
		if (_OPTIONS["help"]) then
			premake.showhelp()
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

		
		-- Validate the command-line arguments. This has to happen after the
		-- script has run to allow for project-specific options
		
		action = premake.action.current()
		if (not action) then
			error("Error: no such action '" .. _ACTION .. "'", 0)
		end

		ok, err = premake.option.validate(_OPTIONS)
		if (not ok) then error("Error: " .. err, 0) end
		

		-- Sanity check the current project setup

		ok, err = premake.checktools()
		if (not ok) then error("Error: " .. err, 0) end
		
		
		-- "Bake" the project information, preparing it for use by the action

		print("Building configurations...")
		premake.solution.bakeall()

		
		-- Hand over control to the action
		printf("Running action '%s'...", action.trigger)
		premake.action.call(action.trigger)

		print("Done.")
		return 0

	end
	

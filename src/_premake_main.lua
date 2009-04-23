--
-- _premake_main.lua
-- Script-side entry point for the main program logic.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	local scriptfile    = "premake4.lua"
	local shorthelp     = "Type 'premake4 --help' for help"
	local versionhelp   = "premake4 (Premake Build Script Generator) %s"
	


--
-- Fire a particular action. Generates the output files from the templates
-- listed in the action descriptor, and calls any registered handler functions.
--

	local function doaction(name)
		local action = premake.actions[name]
		
		-- walk the session objects and generate files from the templates
		local function generatefiles(this, templates)
			if (not templates) then return end
			for _,tmpl in ipairs(templates) do
				local output = true
				if (tmpl[3]) then
					output = tmpl[3](this)
				end
				if (output) then
					local fname = path.getrelative(os.getcwd(), premake.getoutputname(this, tmpl[1]))
					printf("Generating %s...", fname)
					local f, err = io.open(fname, "wb")
					if (not f) then
						error(err, 0)
					end
					io.output(f)
					
					-- call the template function to generate the output
					tmpl[2](this)

					io.output():close()
				end
			end
		end

		for _,sln in ipairs(_SOLUTIONS) do
			generatefiles(sln, action.solutiontemplates)			
			for prj in premake.eachproject(sln) do
				generatefiles(prj, action.projecttemplates)
			end
		end
		
		if (action.execute) then
			action.execute()
		end
	end



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
		
		if (not premake.actions[_ACTION]) then
			error("Error: no such action '".._ACTION.."'", 0)
		end

		ok, err = premake.checkoptions()
		if (not ok) then error("Error: " .. err, 0) end
		

		-- Sanity check the current project setup

		ok, err = premake.checktools()
		if (not ok) then error("Error: " .. err, 0) end
		
		-- work-in-progress: build the configurations
		print("Building configurations...")
		premake.buildconfigs()
		
		ok, err = premake.checkprojects()
		if (not ok) then error("Error: " .. err, 0) end
		
		
		-- Hand over control to the action
		printf("Running action '%s'...", _ACTION)
		doaction(_ACTION)

		print("Done.")
		return 0

	end
	
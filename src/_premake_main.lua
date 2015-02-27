--
-- _premake_main.lua
-- Script-side entry point for the main program logic.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

	local shorthelp     = "Type 'premake5 --help' for help"
	local versionhelp   = "premake5 (Premake Build Script Generator) %s"


-- Load the collection of core scripts, required for everything else to work

	local manifest = dofile("_manifest.lua")
	for i = 1, #manifest do
		dofile(manifest[i])
	end


-- Create namespaces for myself

	local p = premake
	p.main = {}

	local m = p.main


--
-- Script-side program entry point.
--

	m.elements = function()
		return {
			m.installModuleLoader,
			m.prepareEnvironment,
			m.runSystemScript,
			m.locateUserScript,
			m.prepareAction,
			m.runUserScript,
			m.checkInteractive,
			m.processCommandLine,
			m.preBake,
			m.bake,
			m.postBake,
			m.validate,
			m.preAction,
			m.callAction,
			m.postAction,
		}
	end

	function _premake_main()
		p.callArray(p.main.elements)
		return 0
	end


---
-- Add a new module loader that knows how to use the Premake paths like
-- PREMAKE_PATH and the --scripts option, and follows the module/module.lua
-- naming convention.
---

	function m.installModuleLoader()
		table.insert(package.loaders, 2, m.moduleLoader)
	end

	function m.moduleLoader(name)
		local dir = path.getdirectory(name)
		local base = path.getname(name)

		if dir ~= "." then
			dir = dir .. "/" .. base
		else
			dir = base
		end

		-- Premake standard is moduleName/moduleName.lua
		local relPath = dir .. "/" .. base .. ".lua"

		local chunk = loadfile("modules/" .. relPath)
		if not chunk then
			chunk = loadfile(relPath)
		end
		if not chunk then
			chunk = loadfile(name .. ".lua")
		end

		if not chunk then
			return "\n\tno file " .. name .. " on module paths"
		end

		return chunk
	end


---
-- Prepare the script environment; anything that should be done
-- before the system script gets a chance to run.
---

	function m.prepareEnvironment()
		math.randomseed(os.time())
		_PREMAKE_DIR = path.getdirectory(_PREMAKE_COMMAND)
		premake.path = premake.path .. ";" .. _PREMAKE_DIR
	end


---
-- Look for and run the system-wide configuration script; make sure any
-- configuration scoping gets cleared before continuing.
---

	function m.runSystemScript()
		dofileopt(_OPTIONS["systemscript"] or { "premake5-system.lua", "premake-system.lua" })
		filter {}
	end


---
-- Look for a user project script, and set up the related global
-- variables if I can find one.
---

	function m.locateUserScript()
		local defaults = { "premake5.lua", "premake4.lua" }
		for i = 1, #defaults do
			if os.isfile(defaults[i]) then
				_MAIN_SCRIPT = defaults[i]
				break
			end
		end

		if not _MAIN_SCRIPT then
			_MAIN_SCRIPT = defaults[1]
		end

		if _OPTIONS.file then
			_MAIN_SCRIPT = _OPTIONS.file
		end

		_MAIN_SCRIPT = path.getabsolute(_MAIN_SCRIPT)
		_MAIN_SCRIPT_DIR = path.getdirectory(_MAIN_SCRIPT)
	end


---
-- Set the action to be performed from the command line arguments.
---

	function m.prepareAction()
		-- The "next-gen" actions have now replaced their deprecated counterparts.
		-- Provide a warning for a little while before I remove them entirely.
		if _ACTION and _ACTION:endswith("ng") then
			premake.warnOnce(_ACTION, "'%s' has been deprecated; use '%s' instead", _ACTION, _ACTION:sub(1, -3))
		end
		premake.action.set(_ACTION)
	end


---
-- If there is a project script available, run it to get the
-- project information, available options and actions, etc.
---

	function m.runUserScript()
		if os.isfile(_MAIN_SCRIPT) then
			dofile(_MAIN_SCRIPT)
		end
	end


---
-- Run the interactive prompt, if requested.
---

	function m.checkInteractive()
		if _OPTIONS.interactive then
			debug.prompt()
		end
	end


---
-- Validate and process the command line options and arguments.
---

	function m.processCommandLine()
		-- Process special options
		if (_OPTIONS["version"]) then
			printf(versionhelp, _PREMAKE_VERSION)
			os.exit(0)
		end

		if (_OPTIONS["help"]) then
			premake.showhelp()
			os.exit(1)
		end

		-- Validate the command-line arguments. This has to happen after the
		-- script has run to allow for project-specific options
		ok, err = premake.option.validate(_OPTIONS)
		if not ok then
			print("Error: " .. err)
			os.exit(1)
		end

		-- If no further action is possible, show a short help message
		if not _OPTIONS.interactive then
			if not _ACTION then
				print(shorthelp)
				os.exit(1)
			end

			local action = premake.action.current()
			if not action then
				print("Error: no such action '" .. _ACTION .. "'")
				os.exit(1)
			end

			if not os.isfile(_MAIN_SCRIPT) then
				print(string.format("No Premake script (%s) found!", path.getname(_MAIN_SCRIPT)))
				os.exit(1)
			end
		end
	end


---
-- Override point, for logic that should run before baking.
---

	function m.preBake()
		print("Building configurations...")
	end


---
-- "Bake" the project information, preparing it for use by the action.
---

	function m.bake()
		premake.oven.bake()
	end


---
-- Override point, for logic that should run after baking but before
-- the configurations are validated.
---

	function m.postBake()
	end


---
-- Sanity check the current project setup.
---

	function m.validate()
		p.container.validate(p.api.rootContainer())
	end


---
-- Override point, for logic that should run after validation and
-- before the action takes control.
---

	function m.preAction()
		local action = premake.action.current()
		printf("Running action '%s'...", action.trigger)
	end


---
-- Hand over control to the action.
---

	function m.callAction()
		local action = premake.action.current()
		premake.action.call(action.trigger)
	end


---
-- Processing is complete.
---

	function m.postAction()
		print("Done.")
	end

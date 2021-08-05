--
-- _premake_main.lua
-- Script-side entry point for the main program logic.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

	local shorthelp     = "Type 'premake5 --help' for help"
	local versionhelp   = "premake5 (Premake Build Script Generator) %s"
	local startTime     = os.clock()

-- set a global.
	_PREMAKE_STARTTIME = startTime

-- Load the collection of core scripts, required for everything else to work

	local modules = dofile("_modules.lua")
	local manifest = dofile("_manifest.lua")
	for i = 1, #manifest do
		dofile(manifest[i])
	end


-- Create namespaces for myself

	local p = premake
	p.main = {}

	local m = p.main


-- Keep a table of modules that have been preloaded, and their associated
-- "should load" test functions.

	m._preloaded = {}


---
-- Add a new module loader that knows how to use the Premake paths like
-- PREMAKE_PATH and the --scripts option, and follows the module/module.lua
-- naming convention.
---

	function m.installModuleLoader()
		if not os.ishost('windows') then
			local premakeDir = path.getdirectory(_PREMAKE_COMMAND)
			package.cpath = package.cpath .. ';' .. premakeDir .. '/?.so'
		end
		table.insert(package.searchers, 2, m.moduleLoader)
	end

	function m.moduleLoader(name)
		local dir = path.getdirectory(name)
		local base = path.getname(name)

		if dir ~= "." then
			dir = dir .. "/" .. base
		else
			dir = base
		end

		local full = dir .. "/" .. base .. ".lua"

		-- list of paths where to look for the module
		local paths = {
			".modules/" .. full,
			"modules/" .. full,
			full,
			name .. ".lua"
		}

		-- If this module is being requested by an embedded script, favor embedded modules.
		-- This helps prevent local scripts from interfering with release build bootstrapping.
		if string.startswith(_SCRIPT_DIR, '$/') then
			table.insert(paths, 1, '$/' .. full)
		end

		-- try to locate the module
		for _, p in ipairs(paths) do
			local file = os.locate(p)
			if file then
				local chunk, err = loadfile(file)
				if chunk then
					return chunk
				end
				if err then
					return "\n\tload error " .. err
				end
			end
		end

		-- didn't find the module in supported paths, try the embedded scripts
		for _, p in ipairs(paths) do
			local chunk, err = loadfile("$/" .. p)
			if chunk then
				return chunk
			end
		end
	end


---
-- Prepare the script environment; anything that should be done
-- before the system script gets a chance to run.
---

	function m.prepareEnvironment()
		math.randomseed(os.time())
		_PREMAKE_DIR = path.getdirectory(_PREMAKE_COMMAND)
		p.path = p.path .. ";" .. _PREMAKE_DIR .. ";" .. _MAIN_SCRIPT_DIR
	end


---
-- Load the required core modules that are shipped as part of Premake and
-- expected to be present at startup. If a _preload.lua script is present,
-- that script is run and the return value (a "should load" test) is cached
-- to be called after baking is complete. Otherwise the module's main script
-- is run immediately.
---

	function m.preloadModules()
		for i = 1, #modules do
			local name = modules[i]
			local preloader = name .. "/_preload.lua"
			preloader = os.locate("modules/" .. preloader) or os.locate(preloader)
			if preloader then
				local modulePath = path.getdirectory(preloader)
				m._preloaded[modulePath] = include(preloader)
				if not m._preloaded[modulePath] then
					p.warn("module '%s' should return function from _preload.lua", name)
				end
			else
				require(name)
			end
		end
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
		p.action.set(_ACTION)

		-- Allow the action to initialize stuff.
		local action = p.action.current()
		if action then
			p.action.initialize(action.trigger)
		end
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
			p.showhelp()
			os.exit(1)
		end

		-- Validate the command-line arguments. This has to happen after the
		-- script has run to allow for project-specific options
		ok, err = p.option.validate(_OPTIONS)
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

			local action = p.action.current()
			if not action then
				print("Error: no such action '" .. _ACTION .. "'")
				os.exit(1)
			end

			if p.action.isConfigurable() and not os.isfile(_MAIN_SCRIPT) then
				print(string.format("No Premake script (%s) found!", path.getname(_MAIN_SCRIPT)))
				os.exit(1)
			end
		end
	end

---
-- Start up MobDebug and try to hook up with ZeroBrane
---

	function m.tryHookDebugger()

		if (_OPTIONS["debugger"]) then
			print("Loading luasocket...")
			require('luasocket')
			print("Starting debugger...")
			local mobdebug = require('mobdebug')
			mobdebug.start()

		end
	end

---
-- Override point, for logic that should run before baking.
---

	function m.preBake()
		if p.action.isConfigurable() then
			print("Building configurations...")
		end
	end


---
-- "Bake" the project information, preparing it for use by the action.
---

	function m.bake()
		if p.action.isConfigurable() then
			p.oven.bake()
		end
	end


---
-- Override point, for logic that should run after baking but before
-- the configurations are validated.
---

	function m.postBake()
		local function shouldLoad(func)
			for wks in p.global.eachWorkspace() do
				for prj in p.workspace.eachproject(wks) do
					for cfg in p.project.eachconfig(prj) do
						if func(cfg) then
							return true
						end
					end
				end
			end
		end

		-- any modules need to load to support this project?
		for modulePath, func in pairs(m._preloaded) do
			local moduleName = path.getbasename(modulePath)
			if not package.loaded[moduleName] and shouldLoad(func) then
				_SCRIPT_DIR = modulePath
				require(moduleName)
			end
		end
	end


---
-- Sanity check the current project setup.
---

	function m.validate()
		if p.action.isConfigurable() then
			p.container.validate(p.api.rootContainer())
		end
	end


---
-- Override point, for logic that should run after validation and
-- before the action takes control.
---

	function m.preAction()
		local action = p.action.current()
		printf("Running action '%s'...", action.trigger)
	end


---
-- Hand over control to the action.
---

	function m.callAction()
		local action = p.action.current()
		p.action.call(action.trigger)
	end


---
-- Processing is complete.
---

	function m.postAction()
		if p.action.isConfigurable() then
			local duration = math.floor((os.clock() - startTime) * 1000);
			printf("Done (%dms).", duration)
		end
	end



--
-- Script-side program entry point.
--

	m.elements = {
		m.tryHookDebugger,
		m.installModuleLoader,
		m.locateUserScript,
		m.prepareEnvironment,
		m.preloadModules,
		m.runSystemScript,
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

	function _premake_main()
		p.callArray(m.elements)
		return 0
	end

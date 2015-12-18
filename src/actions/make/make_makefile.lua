--
-- make_makefile.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local p = premake
	p.make.makefile = {}

	local make       = p.make
	local makefile   = p.make.makefile
	local project    = p.project
	local config     = p.config
	local fileconfig = p.fileconfig

---
-- Add namespace for element definition lists for premake.callarray()
---
	makefile.elements = {}

--
-- Generate a GNU make makefile project makefile.
--

	makefile.elements.makefile = {
		"header",
		"phonyRules",
		"makefileConfigs",
		"makefileTargetRules"
	}

	function make.makefile.generate(prj)
		premake.eol("\n")
		premake.callarray(make, makefile.elements.makefile, prj)
	end


	makefile.elements.configuration = {
		"target",
		"buildCommands",
		"cleanCommands",
	}

	function make.makefileConfigs(prj)
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset = premake.tools[cfg.toolset or "gcc"]
			if not toolset then
				error("Invalid toolset '" .. cfg.toolset .. "'")
			end

			_x('ifeq ($(config),%s)', cfg.shortname)
			premake.callarray(make, makefile.elements.configuration, cfg, toolset)
			_p('endif')
			_p('')
		end
	end

	function make.makefileTargetRules(prj)
		_p('$(TARGET):')
		_p('\t$(BUILDCMDS)')
		_p('')
		_p('clean:')
		_p('\t$(CLEANCMDS)')
		_p('')
	end


	function make.buildCommands(cfg)
		_p('  define BUILDCMDS')
		local steps = cfg.buildcommands
		if #steps > 0 then
			steps = os.translateCommands(steps)
			_p('\t@echo Running build commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


	function make.cleanCommands(cfg)
		_p('  define CLEANCMDS')
		local steps = cfg.cleancommands
		if #steps > 0 then
			steps = os.translateCommands(steps)
			_p('\t@echo Running clean commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


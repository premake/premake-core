--
-- make_makefile.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2014 Jess Perkins and the Premake project
--

	local p = premake
	p.makelegacy.makefile = {}

	local make       = p.makelegacy
	local makefile   = p.makelegacy.makefile
	local project    = p.project
	local config     = p.config
	local fileconfig = p.fileconfig

---
-- Add namespace for element definition lists for p.callarray()
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
		p.eol("\n")
		p.callarray(make, makefile.elements.makefile, prj)
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

			local toolset, version = p.tools.canonical(cfg.toolset or p.GCC)
			if not toolset then
				error("Invalid toolset '" .. cfg.toolset .. "'")
			end

			_x('ifeq ($(config),%s)', cfg.shortname)
			p.callarray(make, makefile.elements.configuration, cfg, toolset)
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
			steps = os.translateCommandsAndPaths(steps, cfg.project.basedir, cfg.project.location)
			_p('\t@echo Running build commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


	function make.cleanCommands(cfg)
		_p('  define CLEANCMDS')
		local steps = cfg.cleancommands
		if #steps > 0 then
			steps = os.translateCommandsAndPaths(steps, cfg.project.basedir, cfg.project.location)
			_p('\t@echo Running clean commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


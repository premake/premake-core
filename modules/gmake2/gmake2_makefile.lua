--
-- gmake2_makefile.lua
-- Generate a C/C++ project makefile.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local gmake2 = p.modules.gmake2

	gmake2.makefile  = {}
	local makefile   = gmake2.makefile

	local project    = p.project
	local config     = p.config
	local fileconfig = p.fileconfig

---
-- Add namespace for element definition lists for p.callArray()
---
	makefile.elements = {}

--
-- Generate a GNU make makefile project makefile.
--

	makefile.elements.makefile = function(prj)
		return {
			gmake2.header,
			gmake2.phonyRules,
			makefile.configs,
			makefile.targetRules
		}
	end

	function makefile.generate(prj)
		p.eol("\n")
		p.callArray(makefile.elements.makefile, prj)
	end


	makefile.elements.configuration = function(cfg)
		return {
			gmake2.target,
			gmake2.buildCommands,
			gmake2.cleanCommands,
		}
	end

	function makefile.configs(prj)
		local first = true
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset, version = p.tools.canonical(cfg.toolset or p.GCC)
			if not toolset then
				error("Invalid toolset '" .. cfg.toolset .. "'")
			end

			if first then
				_x('ifeq ($(config),%s)', cfg.shortname)
				first = false
			else
				_x('else ifeq ($(config),%s)', cfg.shortname)
			end

			p.callArray(makefile.elements.configuration, cfg, toolset)
			_p('')
		end

		if not first then
			_p('else')
			_p('  $(error "invalid configuration $(config)")')
			_p('endif')
			_p('')
		end
	end

	function makefile.targetRules(prj)
		_p('$(TARGET):')
		_p('\t$(BUILDCMDS)')
		_p('')
		_p('clean:')
		_p('\t$(CLEANCMDS)')
		_p('')
	end


	function gmake2.buildCommands(cfg)
		_p('  define BUILDCMDS')
		local steps = cfg.buildcommands
		if #steps > 0 then
			steps = os.translateCommandsAndPaths(steps, cfg.project.basedir, cfg.project.location)
			_p('\t@echo Running build commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


	function gmake2.cleanCommands(cfg)
		_p('  define CLEANCMDS')
		local steps = cfg.cleancommands
		if #steps > 0 then
			steps = os.translateCommandsAndPaths(steps, cfg.project.basedir, cfg.project.location)
			_p('\t@echo Running clean commands')
			_p('\t%s', table.implode(steps, "", "", "\n\t"))
		end
		_p('  endef')
	end


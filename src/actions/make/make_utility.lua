--
-- make_utility.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local p = premake
	p.make.utility = {}

	local make       = p.make
	local utility    = p.make.utility
	local project    = p.project
	local config     = p.config
	local fileconfig = p.fileconfig

---
-- Add namespace for element definition lists for premake.callarray()
---
	utility.elements = {}

--
-- Generate a GNU make utility project makefile.
--

	utility.elements.makefile = {
		"header",
		"phonyRules",
		"utilityConfigs",
		"utilityTargetRules"
	}

	function make.utility.generate(prj)
		premake.eol("\n")
		premake.callarray(make, utility.elements.makefile, prj)
	end


	utility.elements.configuration = {
		"target",
		"preBuildCmds",
		"postBuildCmds",
	}

	function make.utilityConfigs(prj)
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset = premake.tools[cfg.toolset or "gcc"]
			if not toolset then
				error("Invalid toolset '" .. cfg.toolset .. "'")
			end

			_x('ifeq ($(config),%s)', cfg.shortname)
			premake.callarray(make, utility.elements.configuration, cfg, toolset)
			_p('endif')
			_p('')
		end
	end

	function make.utilityTargetRules(prj)
		_p('$(TARGET):')
		_p('\t$(PREBUILDCMDS)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
	end


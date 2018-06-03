--
-- d/actions/gmake.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake
	local m = p.modules.d

	m.make = {}

	local dmake = m.make

	require ("gmake")

	local make = p.make
	local cpp = p.make.cpp
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig

-- This check may be unnecessary as we only 'require' this file from d.lua
-- IFF the action already exists, however this may help if this file is
-- directly required, rather than d.lua itself.
	local gmake = p.action.get( 'gmake' )
	if gmake == nil then
		error( "Failed to locate prequisite action 'gmake'" )
	end

--
-- Patch the gmake action with the allowed tools...
--
	gmake.valid_languages = table.join(gmake.valid_languages, { p.D } )
	gmake.valid_tools.dc = { "dmd", "gdc", "ldc" }

	function m.make.separateCompilation(prj)
		local some = false
		local all = true
		for cfg in project.eachconfig(prj) do
			if cfg.compilationmodel == "File" then
				some = true
			else
				all = false
			end
		end
		return iif(all, "all", iif(some, "some", "none"))
	end


--
-- Override the GMake action 'onProject' funtion to provide
-- D knowledge...
--
	p.override( gmake, "onProject", function(oldfn, prj)
		p.escaper(make.esc)
		if project.isd(prj) then
			local makefile = make.getmakefilename(prj, true)
			p.generate(prj, makefile, m.make.generate)
			return
		end
		oldfn(prj)
	end)

	p.override( make, "objdir", function(oldfn, cfg)
		if cfg.project.language ~= "D" or cfg.compilationmodel == "File" then
			oldfn(cfg)
		end
	end)

	p.override( make, "objDirRules", function(oldfn, prj)
		if prj.language ~= "D" or m.make.separateCompilation(prj) ~= "none" then
			oldfn(prj)
		end
	end)


---
-- Add namespace for element definition lists for p.callarray()
---

	m.elements = {}

--
-- Generate a GNU make C++ project makefile, with support for the new platforms API.
--

	m.elements.makefile = function(prj)
		return {
			make.header,
			make.phonyRules,
			m.make.configs,
			m.make.objects,		-- TODO: This is basically identical to make.cppObjects(), and should ideally be merged/shared
			make.shellType,
			m.make.targetRules,
			make.targetDirRules,
			make.objDirRules,
			make.cppCleanRules,	-- D clean code is identical to C/C++
			make.preBuildRules,
			make.preLinkRules,
			m.make.dFileRules,
		}
	end

	function m.make.generate(prj)
		p.callArray(m.elements.makefile, prj)
	end


	function m.make.buildRule(prj)
		_p('$(TARGET): $(SOURCEFILES) $(LDDEPS)')
		_p('\t@echo Building %s', prj.name)
		_p('\t$(SILENT) $(BUILDCMD)')
		_p('\t$(POSTBUILDCMDS)')
	end

	function m.make.linkRule(prj)
		_p('$(TARGET): $(OBJECTS) $(LDDEPS)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
	end

	function m.make.targetRules(prj)
		local separateCompilation = m.make.separateCompilation(prj)
		if separateCompilation == "all" then
			m.make.linkRule(prj)
		elseif separateCompilation == "none" then
			m.make.buildRule(prj)
		else
			for cfg in project.eachconfig(prj) do
				_x('ifeq ($(config),%s)', cfg.shortname)
				if cfg.compilationmodel == "File" then
					m.make.linkRule(prj)
				else
					m.make.buildRule(prj)
				end
				_p('endif')
			end
		end
		_p('')
	end

	function m.make.dFileRules(prj)
		local separateCompilation = m.make.separateCompilation(prj)
		if separateCompilation ~= "none" then
			make.cppFileRules(prj)
		end
	end

--
-- Override the 'standard' file rule to support D source files
--

	p.override(cpp, "standardFileRules", function(oldfn, prj, node)
		-- D file
		if path.isdfile(node.abspath) then
			_p('\t$(SILENT) $(DC) $(ALL_DFLAGS) $(OUTPUTFLAG) -c $<')
		else
			oldfn(prj, node)
		end
	end)

--
-- Let make know it can compile D source files
--

	p.override(make, "fileType", function(oldfn, node)
		if path.isdfile(node.abspath) then
			return "objects"
		else
			return oldfn(node)
		end
	end)


--
-- Write out the settings for a particular configuration.
--

	m.elements.makeconfig = function(cfg)
		return {
			m.make.dTools,
			make.target,
			m.make.target,
			make.objdir,
			m.make.versions,
			m.make.debug,
			m.make.imports,
			m.make.stringImports,
			m.make.dFlags,
			make.libs,
			make.ldDeps,
			make.ldFlags,
			m.make.linkCmd,
			make.preBuildCmds,
			make.preLinkCmds,
			make.postBuildCmds,
			m.make.allRules,
			make.settings,
		}
	end

	function m.make.configs(prj)
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset = p.tools[_OPTIONS.dc or cfg.toolset or "dmd"]
			if not toolset then
				error("Invalid toolset '" + (_OPTIONS.dc or cfg.toolset) + "'")
			end

			_x('ifeq ($(config),%s)', cfg.shortname)
			p.callArray(m.elements.makeconfig, cfg, toolset)
			_p('endif')
			_p('')
		end
	end

	function m.make.dTools(cfg, toolset)
		local tool = toolset.gettoolname(cfg, "dc")
		if tool then
			_p('  DC = %s', tool)
		end
	end

	function m.make.target(cfg, toolset)
		if cfg.compilationmodel == "File" then
			_p('  OUTPUTFLAG = %s', toolset.gettarget('"$@"'))
		end
	end

	function m.make.versions(cfg, toolset)
		_p('  VERSIONS +=%s', make.list(toolset.getversions(cfg.versionconstants, cfg.versionlevel)))
	end

	function m.make.debug(cfg, toolset)
		_p('  DEBUG +=%s', make.list(toolset.getdebug(cfg.debugconstants, cfg.debuglevel)))
	end

	function m.make.imports(cfg, toolset)
		local imports = p.esc(toolset.getimportdirs(cfg, cfg.importdirs))
		_p('  IMPORTS +=%s', make.list(imports))
	end

	function m.make.stringImports(cfg, toolset)
		local stringImports = p.esc(toolset.getstringimportdirs(cfg, cfg.stringimportdirs))
		_p('  STRINGIMPORTS +=%s', make.list(stringImports))
	end

	function m.make.dFlags(cfg, toolset)
		_p('  ALL_DFLAGS += $(DFLAGS)%s $(VERSIONS) $(DEBUG) $(IMPORTS) $(STRINGIMPORTS) $(ARCH)', make.list(table.join(toolset.getdflags(cfg), cfg.buildoptions)))
	end

	function m.make.linkCmd(cfg, toolset)
		if cfg.compilationmodel == "File" then
			_p('  LINKCMD = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(ALL_LDFLAGS) $(LIBS) $(OBJECTS)')

--			local cc = iif(p.languages.isc(cfg.language), "CC", "CXX")
--			_p('  LINKCMD = $(%s) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)', cc)
		else
			_p('  BUILDCMD = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(ALL_DFLAGS) $(ALL_LDFLAGS) $(LIBS) $(SOURCEFILES)')
		end
	end

	function m.make.allRules(cfg, toolset)
		-- TODO: The C++ version has some special cases for OSX and Windows... check whether they should be here too?
		if cfg.compilationmodel == "File" then
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
		else
			_p('all: $(TARGETDIR) prebuild prelink $(TARGET)')
		end
		_p('\t@:')
--		_p('')
	end


--
-- List the objects file for the project, and each configuration.
--

-- TODO: This is basically identical to make.cppObjects(), and should ideally be merged/shared

	function m.make.objects(prj)
		-- create lists for intermediate files, at the project level and
		-- for each configuration
		local root = { sourcefiles={}, objects={} }
		local configs = {}
		for cfg in project.eachconfig(prj) do
			configs[cfg] = { sourcefiles={}, objects={} }
		end

		-- now walk the list of files in the project
		local tr = project.getsourcetree(prj)
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				-- figure out what configurations contain this file, and
				-- if it uses custom build rules
				local incfg = {}
				local inall = true
				local custom = false
				for cfg in project.eachconfig(prj) do
					local filecfg = fileconfig.getconfig(node, cfg)
					if filecfg and not filecfg.flags.ExcludeFromBuild then
						incfg[cfg] = filecfg
						custom = fileconfig.hasCustomBuildRule(filecfg)
					else
						inall = false
					end
				end

				if not custom then
					-- skip files that aren't compiled
					if not path.isdfile(node.abspath) then
						return
					end

					local sourcename = node.relpath

					-- TODO: assign a unique object file name to avoid collisions
					local objectname = "$(OBJDIR)/" .. node.objname .. ".o"

					-- if this file exists in all configurations, write it to
					-- the project's list of files, else add to specific cfgs
					if inall then
						table.insert(root.sourcefiles, sourcename)
						table.insert(root.objects, objectname)
					else
						for cfg in project.eachconfig(prj) do
							if incfg[cfg] then
								table.insert(configs[cfg].sourcefiles, sourcename)
								table.insert(configs[cfg].objects, objectname)
							end
						end
					end

				else
					for cfg in project.eachconfig(prj) do
						local filecfg = incfg[cfg]
						if filecfg then
							-- if the custom build outputs an object file, add it to
							-- the link step automatically to match Visual Studio
							local output = project.getrelative(prj, filecfg.buildoutputs[1])
							if path.isobjectfile(output) then
								table.insert(configs[cfg].objects, output)
							end
						end
					end
				end

			end
		})

		local separateCompilation = m.make.separateCompilation(prj)

		-- now I can write out the lists, project level first...
		function listobjects(var, list)
			_p('%s \\', var)
			for _, objectname in ipairs(list) do
				_x('\t%s \\', objectname)
			end
			_p('')
		end

		if separateCompilation ~= "all" then
			listobjects('SOURCEFILES :=', root.sourcefiles)
		end
		if separateCompilation ~= "none" then
			listobjects('OBJECTS :=', root.objects, 'o')
		end

		-- ...then individual configurations, as needed
		for cfg in project.eachconfig(prj) do
			local files = configs[cfg]
			if (#files.sourcefiles > 0 and separateCompilation ~= "all") or (#files.objects > 0 and separateCompilation ~= "none") then
				_x('ifeq ($(config),%s)', cfg.shortname)
				if #files.sourcefiles > 0 and separateCompilation ~= "all" then
					listobjects('  SOURCEFILES +=', files.sourcefiles)
				end
				if #files.objects > 0 and separateCompilation ~= "none" then
					listobjects('  OBJECTS +=', files.objects)
				end
				_p('endif')
			end
		end
		_p('')
	end

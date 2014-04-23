--
-- d/actions/gmake.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2014 Andrew Gough, Manu Evans, and the Premake project
--

	premake.extensions.d.make = { }

	local d = premake.extensions.d
	local make = premake.make
	local cpp = premake.make.cpp
	local dmake = d.make
	local project = premake.project
	local config = premake.config
	local fileconfig = premake.fileconfig

-- This check may be unnecessary as we only 'require' this file from d.lua
-- IFF the action already exists, however this may help if this file is
-- directly required, rather than d.lua itself.
	local gmake = premake.action.get( 'gmake' )
	if gmake == nil then
		error( "Failed to locate prequisite action 'gmake'" )
	end

--
-- Patch the gmake action with the allowed tools...
--
	gmake.valid_languages = table.join(gmake.valid_languages, { premake.D } )
	gmake.valid_tools.dc = { "dmd", "gdc", "ldc" }


	function dmake.separateCompilation(prj)
		local some = false
		local all = true
		for cfg in project.eachconfig(prj) do
			if cfg.flags.SeparateCompilation then
				some = true
			else
				all = false
			end
		end
		return iif(all, "all", iif(some, "some", "none"))
	end


--
-- Override the GMake action 'onproject' funtion to provide
-- D knowledge...
--
	premake.override( gmake, "onproject", function(oldfn, prj)
		io.esc = make.esc
		if project.isd(prj) then
			local makefile = make.getmakefilename(prj, true)
			premake.generate(prj, makefile, dmake.generate)
			return
		end
		oldfn(prj)
	end)

	premake.override( make, "objdir", function(oldfn, cfg)
		if cfg.project.language ~= "D" or cfg.flags.SeparateCompilation then
			oldfn(cfg)
		end
	end)

	premake.override( make, "objDirRules", function(oldfn, prj)
		if prj.language ~= "D" or dmake.separateCompilation(prj) ~= "none" then
			oldfn(prj)
		end
	end)


---
-- Add namespace for element definition lists for premake.callarray()
---

	dmake.elements = {}

--
-- Generate a GNU make C++ project makefile, with support for the new platforms API.
--

	dmake.elements.makefile = {
		"dHeaderMessage",
		"header",
		"phonyRules",
		"dConfigs",
		"dObjects",			-- TODO: This is basically identical to make.cppObjects(), and should ideally be merged/shared
		"shellType",
		"dTargetRules",
		"targetDirRules",
		"objDirRules",
		"cppCleanRules",	-- D clean code is identical to C/C++
		"preBuildRules",
		"preLinkRules",
		"dFileRules",
	}

	function dmake.generate(prj)
		premake.callarray(make, dmake.elements.makefile, prj)
	end


	function make.dHeaderMessage(prj)
		_p( "# Premake D extension generated file. See %s", d.support_url )
		_p('')
	end

	function dmake.buildRule(prj)
		_p('$(TARGET): $(LDDEPS)')
		_p('\t@echo Building %s', prj.name)
		_p('\t$(SILENT) $(BUILDCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
	end

	function dmake.linkRule(prj)
		_p('$(TARGET): $(OBJECTS) $(LDDEPS)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
	end

	function make.dTargetRules(prj)
		local separateCompilation = dmake.separateCompilation(prj)
		if separateCompilation == "all" then
			dmake.linkRule(prj)
		elseif separateCompilation == "none" then
			dmake.buildRule(prj)
		else
			for cfg in project.eachconfig(prj) do
				_x('ifeq ($(config),%s)', cfg.shortname)
				if cfg.flags.SeparateCompilation then
					dmake.linkRule(prj)
				else
					dmake.buildRule(prj)
				end
				_p('endif')
				_p('')
			end
		end
	end

	function make.dFileRules(prj)
		local separateCompilation = dmake.separateCompilation(prj)
		if separateCompilation ~= "none" then
			make.cppFileRules(prj)
		end
	end

--
-- Override the 'standard' file rule to support D source files
--

	premake.override( cpp, "standardFileRules", function(oldfn, prj, node)
		-- D file
		if path.isdfile(node.abspath) then
			_x('$(OBJDIR)/%s.o: %s', node.objname, node.relpath)
			_p('\t@echo $(notdir $<)')
			_p('\t$(SILENT) $(DC) $(ALL_DFLAGS) $(OUTPUTFLAG) -c $<')
		else
	 		oldfn(prj, node)
	 	end
	end)


--
-- Write out the settings for a particular configuration.
--

	dmake.elements.configuration = {
		"dTools",
		"target",
		"dTarget",
		"objdir",
		"versions",
		"debug",
		"imports",
		"dFlags",
		"libs",
		"ldDeps",
		"ldFlags",
		"dLinkCmd",
		"preBuildCmds",
		"preLinkCmds",
		"postBuildCmds",
		"dAllRules",
		"settings",
	}

	function make.dConfigs(prj)
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset = premake.tools[_OPTIONS.dc or cfg.toolset or "dmd"]
			if not toolset then
				error("Invalid toolset '" + (_OPTIONS.dc or cfg.toolset) + "'")
			end

			_x('ifeq ($(config),%s)', cfg.shortname)
			premake.callarray(make, dmake.elements.configuration, cfg, toolset)
			_p('endif')
			_p('')
		end
	end

	function make.dTools(cfg, toolset)
		local tool = toolset.gettoolname(cfg, "dc")
		if tool then
			_p('  DC = %s', tool)
		end
	end

	function make.dTarget(cfg, toolset)
		if cfg.flags.SeparateCompilation then
			_p('  OUTPUTFLAG = %s', toolset.gettarget('"$@"'))
		end
	end

	function make.versions(cfg, toolset)
		_p('  VERSIONS +=%s', make.list(toolset.getversions(cfg.versionconstants, cfg.versionlevel)))
	end

	function make.debug(cfg, toolset)
		_p('  DEBUG +=%s', make.list(toolset.getdebug(cfg.debugconstants, cfg.debuglevel)))
	end

	function make.imports(cfg, toolset)
		local includes = premake.esc(toolset.getimportdirs(cfg, cfg.includedirs))
		_p('  IMPORTS +=%s', make.list(includes))
	end

	function make.dFlags(cfg, toolset)
		_p('  ALL_DFLAGS += $(DFLAGS)%s $(VERSIONS) $(DEBUG) $(IMPORTS) $(ARCH)', make.list(table.join(toolset.getdflags(cfg), cfg.buildoptions)))
	end

	function make.dLinkCmd(cfg, toolset)
		if cfg.flags.SeparateCompilation then
			_p('  LINKCMD = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(ALL_LDFLAGS) $(LIBS) $(OBJECTS)')

--			local cc = iif(cfg.language == "C", "CC", "CXX")
--			_p('  LINKCMD = $(%s) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)', cc)
		else
			_p('  BUILDCMD = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(ALL_DFLAGS) $(ALL_LDFLAGS) $(LIBS) $(SOURCEFILES)')
		end
	end

	function make.dAllRules(cfg, toolset)
		-- TODO: The C++ version has some special cases for OSX and Windows... check whether they should be here too?
		if cfg.flags.SeparateCompilation then
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

	function make.dObjects(prj)
		-- create lists for intermediate files, at the project level and
		-- for each configuration
		local root = { sourcefiles={}, objects={} }
		local configs = {}
		for cfg in project.eachconfig(prj) do
			configs[cfg] = { sourcefiles={}, objects={} }
		end

		-- now walk the list of files in the project
		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
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

		local separateCompilation = dmake.separateCompilation(prj)

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
				_p('')
			end
		end
	end

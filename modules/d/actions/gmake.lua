--
-- d/actions/gmake.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2014 Andrew Gough, Manu Evans, and the Premake project
--

	premake.extensions.d.make = { }

	local d = premake.extensions.d
	local make = premake.make
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
		"dFileRules",		-- TODO: there is probably opportunity for sharing here
	}

	function dmake.generate(prj)
		premake.callarray(make, dmake.elements.makefile, prj)
	end


	function make.dHeaderMessage(prj)
		_p( "# Premake D extension generated file. See %s", d.support_url )
		_p('')
	end

	function make.dTargetRules(prj)
		_p('$(TARGET): $(OBJECTS) $(LDDEPS)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
	end

	function make.dFileRules(prj)
		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node, depth)
				-- check to see if this file has custom rules
				dmake.standardFileRules(prj, node, toolset)
			end
		})
		_p('')
	end

	function dmake.standardFileRules(prj, node, toolset)
		_x('$(OBJDIR)/%s.o: %s', node.objname, node.relpath)
		_p('\t@echo $(notdir $<)')
		_p('\t$(SILENT) $(DC) $(ALL_DFLAGS) $(OUTPUTFLAG) -c $<')
	end


--
-- Write out the settings for a particular configuration.
--

	dmake.elements.configuration = {
		"dTools",
		"target",
		"dTarget",
		"objdir",
		"defines",
		"includes",
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
		_p('  OUTPUTFLAG = %s', toolset.gettarget("$@"))
	end

	function make.dFlags(cfg, toolset)
		_p('  ALL_DFLAGS += $(DFLAGS) $(ARCH) $(DEFINES) $(INCLUDES) %s', table.concat(table.join(toolset.getflags(cfg), cfg.buildoptions), " "))
	end

-- TODO: These are the C++ flags, dFlags() should probably be more like these...
--	function make.cppFlags(cfg, toolset)
--		_p('  ALL_CPPFLAGS += $(CPPFLAGS)%s $(DEFINES) $(INCLUDES)', make.list(toolset.getcppflags(cfg)))
--	end
--	function make.cFlags(cfg, toolset)
--		_p('  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH)%s', make.list(table.join(toolset.getcflags(cfg), cfg.buildoptions)))
--	end
--	function make.cxxFlags(cfg, toolset)
--		_p('  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CFLAGS)%s', make.list(toolset.getcxxflags(cfg)))
--	end

	function make.dLinkCmd(cfg, toolset)
		_p('  LINKCMD   = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(ALL_LDFLAGS) $(LIBS) $(OBJECTS)')

-- TODO: this is the C++ version, we should more carefully verify that the D version is correct...
--		if cfg.kind == premake.STATICLIB then
--			if cfg.architecture == premake.UNIVERSAL then
--				_p('  LINKCMD = libtool -o $(TARGET) $(OBJECTS)')
--			else
--				_p('  LINKCMD = $(AR) -rcs $(TARGET) $(OBJECTS)')
--			end
--		else
			-- this was $(TARGET) $(LDFLAGS) $(OBJECTS)
			--   but had trouble linking to certain static libs; $(OBJECTS) moved up
			-- $(LDFLAGS) moved to end (http://sourceforge.net/p/premake/patches/107/)
			-- $(LIBS) moved to end (http://sourceforge.net/p/premake/bugs/279/)

--			local cc = iif(cfg.language == "C", "CC", "CXX")
--			_p('  LINKCMD = $(%s) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)', cc)
--		end
	end

	function make.dAllRules(cfg, toolset)
		-- TODO: The C++ version has some special cases for OSX and Windows... check whether they should be here too?
		_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
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
		local root = { objects={}, resources={} }
		local configs = {}
		for cfg in project.eachconfig(prj) do
			configs[cfg] = { objects={}, resources={} }
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
					-- identify the file type
					local kind
					if path.isdfile(node.abspath) then
						kind = "objects"
					end

					-- skip files that aren't compiled
					if not custom and not kind then
						return
					end

					-- assign a unique object file name to avoid collisions
					local objectname = "$(OBJDIR)/" .. node.objname .. ".o"

					-- if this file exists in all configurations, write it to
					-- the project's list of files, else add to specific cfgs
					if inall then
						table.insert(root[kind], objectname)
					else
						for cfg in project.eachconfig(prj) do
							if incfg[cfg] then
								table.insert(configs[cfg][kind], objectname)
							end
						end
					end

				else
					error("No support for custom build rules in D")
				end

			end
		})

		-- now I can write out the lists, project level first...
		function listobjects(var, list)
			_p('%s \\', var)
			for _, objectname in ipairs(list) do
				_x('\t%s \\', objectname)
			end
			_p('')
		end

		listobjects('OBJECTS :=', root.objects, 'o')

		-- ...then individual configurations, as needed
		for cfg in project.eachconfig(prj) do
			local files = configs[cfg]
			if #files.objects > 0 then
				_x('ifeq ($(config),%s)', cfg.shortname)
				if #files.objects > 0 then
					listobjects('  OBJECTS +=', files.objects)
				end
				_p('endif')
				_p('')
			end
		end
	end

--
-- make_cpp.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local p = premake

	p.make.cpp = {}

	local make = p.make
	local cpp = p.make.cpp
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig


---
-- Add namespace for element definition lists for p.callarray()
---

	cpp.elements = {}


--
-- Generate a GNU make C++ project makefile, with support for the new platforms API.
--

	cpp.elements.makefile = function(prj)
		return {
			make.header,
			make.phonyRules,
			make.cppConfigs,
			make.cppObjects,
			make.shellType,
			make.cppTargetRules,
			make.cppCustomFilesRules,
			make.cppTargetDirRules,
			make.cppObjDirRules,
			make.cppCleanRules,
			make.preBuildRules,
			make.preLinkRules,
			make.pchRules,
			make.cppFileRules,
			make.cppDependencies,
	}
	end

	-- should be part of the toolset?
	function make.fileTypeExtensions()
		return {
			["objects"] = "o",
			["resources"] = "res",
		}
	end

	-- should be part of the toolset?
	function make.fileType(node)
		local kind
		if path.iscppfile(node.abspath) then
			kind = "objects"
		elseif path.isresourcefile(node.abspath) then
			kind = "resources"
		end

		return kind
	end

	function make.fileDependency(prj, node)
		local filetype = make.fileType(node)
		_x('$(OBJDIR)/%s.%s: %s', node.objname, make.fileTypeExtensions()[filetype], node.relpath)
		_p('\t@echo $(notdir $<)')
	end

	function make.cpp.generate(prj)
		p.eol("\n")
		p.callArray(cpp.elements.makefile, prj)
	end

--
-- Write out the commands for compiling a file
--

	cpp.elements.standardFileRules = function(prj, node)
		return {
			make.fileDependency,
			cpp.standardFileRules,
		}
	end

	cpp.elements.customFileRules = function(prj, node)
		return {
			make.fileDependency,
			cpp.customFileRules,
		}
	end

	cpp.elements.customBuildRules = function(prj, node)
		return {
			cpp.customFileRules
		}
	end

--
-- Write out the settings for a particular configuration.
--

	cpp.elements.configuration = function(cfg, toolset)
		return {
			make.configBegin,
			make.cppTools,
			make.target,
			make.objdir,
			make.pch,
			make.defines,
			make.includes,
			make.forceInclude,
			make.cppFlags,
			make.cFlags,
			make.cxxFlags,
			make.resFlags,
			make.libs,
			make.ldDeps,
			make.ldFlags,
			make.linkCmd,
			make.exePaths,
			make.preBuildCmds,
			make.preLinkCmds,
			make.postBuildCmds,
			make.cppAllRules,
			make.settings,
			make.configEnd,
	}
	end

	function make.cppConfigs(prj)
		for cfg in project.eachconfig(prj) do
			-- identify the toolset used by this configurations (would be nicer if
			-- this were computed and stored with the configuration up front)

			local toolset = p.tools[_OPTIONS.cc or cfg.toolset or "gcc"]
			if not toolset then
				error("Invalid toolset '" .. cfg.toolset .. "'")
			end

			p.callArray(cpp.elements.configuration, cfg, toolset)
			_p('')
		end
	end


	function make.exePaths(cfg)
		local dirs = project.getrelative(cfg.project, cfg.bindirs)
		if #dirs > 0 then
			_p('  EXECUTABLE_PATHS = "%s"', table.concat(dirs, ":"))
			_p('  EXE_PATHS = export PATH=$(EXECUTABLE_PATHS):$$PATH;')
		end
	end

--
-- Return the start of the compilation string that corresponds to the 'compileas' enum if set
--

	function cpp.compileas(prj, node)
		local result
		if node["compileas"] then
			if p.languages.isc(node.compileas) or node.compileas == p.OBJECTIVEC then
				result = '$(CC) $(ALL_CFLAGS)'
			elseif p.languages.iscpp(node.compileas) or node.compileas == p.OBJECTIVECPP then
				result = '$(CXX) $(ALL_CXXFLAGS)'
			end
		end

		return result
	end

--
-- Build command for a single file.
--

	function cpp.buildcommand(prj, objext, node)
		local flags = cpp.compileas(prj, node)
		if not flags then
			local iscfile = node and path.iscfile(node.abspath) or false
			flags = iif(prj.language == "C" or iscfile, '$(CC) $(ALL_CFLAGS)', '$(CXX) $(ALL_CXXFLAGS)')
		end
		_p('\t$(SILENT) %s $(FORCE_INCLUDE) -o "$@" -MF "$(@:%%.%s=%%.d)" -c "$<"', flags, objext)
	end


--
-- Output the list of file building rules.
--

	function make.cppFileRules(prj)
		local tr = project.getsourcetree(prj)
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				-- check to see if this file has custom rules
				local rules
				for cfg in project.eachconfig(prj) do
					local filecfg = fileconfig.getconfig(node, cfg)
					if fileconfig.hasCustomBuildRule(filecfg) then
						rules = cpp.elements.customBuildRules(prj, node)
						break
					end

					if fileconfig.hasFileSettings(filecfg) then
						rules = cpp.elements.customFileRules(prj, node)
						break
					end
				end

				if not rules and make.fileType(node) then
					rules = cpp.elements.standardFileRules(prj, node)
				end

				if rules then
					p.callArray(rules, prj, node)
				end
			end
		})
		_p('')
	end

	function cpp.standardFileRules(prj, node)
		local kind = make.fileType(node)

		-- C/C++ file
		if kind == "objects" then
			cpp.buildcommand(prj, make.fileTypeExtensions()[kind], node)
		-- resource file
		elseif kind == "resources" then
			_p('\t$(SILENT) $(RESCOMP) $< -O coff -o "$@" $(ALL_RESFLAGS)')
		end
	end

	function cpp.customFileRules(prj, node)
		for cfg in project.eachconfig(prj) do
			local filecfg = fileconfig.getconfig(node, cfg)
			if filecfg then
				make.configBegin(cfg)

if fileconfig.hasCustomBuildRule(filecfg) then
				local output = project.getrelative(prj, filecfg.buildoutputs[1])
				local dependencies = filecfg.relpath
				if filecfg.buildinputs and #filecfg.buildinputs > 0 then
					local inputs = project.getrelative(prj, filecfg.buildinputs)
					dependencies = dependencies .. " " .. table.concat(p.esc(inputs), " ")
				end
				_p('%s: %s', output, dependencies)
				_p('\t@echo "%s"', filecfg.buildmessage or ("Building " .. filecfg.relpath))

				local cmds = os.translateCommandsAndPaths(filecfg.buildcommands, cfg.project.basedir, cfg.project.location)
				for _, cmd in ipairs(cmds) do
					if cfg.bindirs and #cfg.bindirs > 0 then
						_p('\t$(SILENT) $(EXE_PATHS) %s', cmd)
					else
						_p('\t$(SILENT) %s', cmd)
					end
				end
else
				cpp.standardFileRules(prj, filecfg)
end
				make.configEnd(cfg)
			end
		end
	end


--
-- List the objects file for the project, and each configuration.
--

	function make.cppObjects(prj)
		-- create lists for intermediate files, at the project level and
		-- for each configuration
		local root = { objects={}, resources={}, customfiles={} }
		local configs = {}
		for cfg in project.eachconfig(prj) do
			configs[cfg] = { objects={}, resources={}, customfiles={} }
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
					-- identify the file type
					local kind
					if path.iscppfile(node.abspath) then
						kind = "objects"
					elseif path.isresourcefile(node.abspath) then
						kind = "resources"
					end

					-- skip files that aren't compiled
					if not custom and not kind then
						return
					end

					-- assign a unique object file name to avoid collisions
					objectname = "$(OBJDIR)/" .. node.objname .. iif(kind == "objects", ".o", ".res")

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
					for cfg in project.eachconfig(prj) do
						local filecfg = incfg[cfg]
						if filecfg then
							local output = project.getrelative(prj, filecfg.buildoutputs[1])
							if path.isobjectfile(output) and (filecfg.linkbuildoutputs == true or filecfg.linkbuildoutputs == nil) then
								table.insert(configs[cfg].objects, output)
							else
								table.insert(configs[cfg].customfiles, output)
							end
						end
					end
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
		listobjects('RESOURCES :=', root.resources, 'res')
		listobjects('CUSTOMFILES :=', root.customfiles)

		-- ...then individual configurations, as needed
		for cfg in project.eachconfig(prj) do
			local files = configs[cfg]
			if #files.objects > 0 or #files.resources > 0 or #files.customfiles > 0 then
				make.configBegin(cfg, toolset)
				if #files.objects > 0 then
					listobjects('  OBJECTS +=', files.objects)
				end
				if #files.resources > 0 then
					listobjects('  RESOURCES +=', files.resources)
				end
				if #files.customfiles > 0 then
					listobjects('  CUSTOMFILES +=', files.customfiles)
				end
				make.configEnd(cfg, toolset)
				_p('')
			end
		end
	end


---------------------------------------------------------------------------
--
-- Handlers for individual makefile elements
--
---------------------------------------------------------------------------

	function make.configBegin(cfg, toolset)
		if cfg then
			_x('ifeq ($(config),%s)', cfg.shortname)
		end
	end

	function make.configEnd(cfg, toolset)
		if cfg then
			_p('endif')
		end
	end

	function make.cFlags(cfg, toolset)
		_p('  ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)%s', make.list(table.join(toolset.getcflags(cfg), cfg.buildoptions)))
	end


	function make.cppAllRules(cfg, toolset)
		if cfg.system == p.MACOSX and cfg.kind == p.WINDOWEDAPP then
			_p('all: prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist')
			_p('\t@:')
			_p('')
			_p('$(dir $(TARGETDIR))PkgInfo:')
			_p('$(dir $(TARGETDIR))Info.plist:')
		else
			_p('all: prebuild prelink $(TARGET)')
			_p('\t@:')
		end
	end


	function make.cppFlags(cfg, toolset)
		_p('  ALL_CPPFLAGS += $(CPPFLAGS)%s $(DEFINES) $(INCLUDES)', make.list(toolset.getcppflags(cfg)))
	end


	function make.cxxFlags(cfg, toolset)
		_p('  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)%s', make.list(table.join(toolset.getcxxflags(cfg), cfg.buildoptions)))
	end


	function make.cppCleanRules(prj)
		_p('clean:')
		_p('\t@echo Cleaning %s', prj.name)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) rm -f  $(TARGET)')
		_p('\t$(SILENT) rm -rf $(OBJDIR)')
		_p('else')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(TARGET)) del $(subst /,\\\\,$(TARGET))')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(OBJDIR)) rmdir /s /q $(subst /,\\\\,$(OBJDIR))')
		_p('endif')
		_p('')
	end


	function make.cppDependencies(prj)
		-- include the dependencies, built by GCC (with the -MMD flag)
		_p('-include $(OBJECTS:%%.o=%%.d)')
		_p('ifneq (,$(PCH))')
			_p('  -include $(OBJDIR)/$(notdir $(PCH)).d')
		_p('endif')
	end


	function make.cppTargetRules(prj)
		_p('$(TARGET): $(GCH) ${CUSTOMFILES} $(OBJECTS) $(LDDEPS) $(RESOURCES) | $(TARGETDIR)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
	end

	function make.cppCustomFilesRules(prj)
		_p('$(CUSTOMFILES): | $(OBJDIR)')
		_p('')
	end

	function make.cppTargetDirRules(prj)
		_p('$(TARGETDIR):')
		_p('\t@echo Creating $(TARGETDIR)')
		make.mkdir('$(TARGETDIR)')
		_p('')
	end

	function make.cppObjDirRules(prj)
		_p('$(OBJDIR):')
		_p('\t@echo Creating $(OBJDIR)')
		make.mkdir('$(OBJDIR)')
		_p('')
	end

	function make.cppTools(cfg, toolset)
		local tool = toolset.gettoolname(cfg, "cc")
		if tool then
			_p('  ifeq ($(origin CC), default)')
			_p('    CC = %s', tool)
			_p('  endif' )
		end

		tool = toolset.gettoolname(cfg, "cxx")
		if tool then
			_p('  ifeq ($(origin CXX), default)')
			_p('    CXX = %s', tool)
			_p('  endif' )
		end

		tool = toolset.gettoolname(cfg, "ar")
		if tool then
			_p('  ifeq ($(origin AR), default)')
			_p('    AR = %s', tool)
			_p('  endif' )
		end

		tool = toolset.gettoolname(cfg, "rc")
		if tool then
			_p('  RESCOMP = %s', tool)
		end
	end


	function make.defines(cfg, toolset)
		_p('  DEFINES +=%s', make.list(table.join(toolset.getdefines(cfg.defines, cfg), toolset.getundefines(cfg.undefines))))
	end


	function make.forceInclude(cfg, toolset)
		local includes = toolset.getforceincludes(cfg)
		if not cfg.flags.NoPCH and cfg.pchheader then
			table.insert(includes, 1, "-include $(OBJDIR)/$(notdir $(PCH))")
		end
		_x('  FORCE_INCLUDE +=%s', make.list(includes))
	end


	function make.includes(cfg, toolset)
		local includes = toolset.getincludedirs(cfg, cfg.includedirs, cfg.sysincludedirs, cfg.frameworkdirs)
		_p('  INCLUDES +=%s', make.list(includes))
	end


	function make.ldDeps(cfg, toolset)
		local deps = config.getlinks(cfg, "siblings", "fullpath")
		_p('  LDDEPS +=%s', make.list(p.esc(deps)))
	end


	function make.ldFlags(cfg, toolset)
		local flags = table.join(toolset.getLibraryDirectories(cfg), toolset.getrunpathdirs(cfg, table.join(cfg.runpathdirs, config.getsiblingtargetdirs(cfg))), toolset.getldflags(cfg), cfg.linkoptions)
		_p('  ALL_LDFLAGS += $(LDFLAGS)%s', make.list(flags))
	end


	function make.libs(cfg, toolset)
		local flags = toolset.getlinks(cfg)
		_p('  LIBS +=%s', make.list(flags, true))
	end


	function make.linkCmd(cfg, toolset)
		if cfg.kind == p.STATICLIB then
			if cfg.architecture == p.UNIVERSAL then
				_p('  LINKCMD = libtool -o "$@" $(OBJECTS)')
			else
				_p('  LINKCMD = $(AR) ' .. (toolset.arargs or '-rcs') ..' "$@" $(OBJECTS)')
			end
		elseif cfg.kind == p.UTILITY then
			-- Empty LINKCMD for Utility (only custom build rules)
			_p('  LINKCMD =')
		else
			-- this was $(TARGET) $(LDFLAGS) $(OBJECTS)
			--   but had trouble linking to certain static libs; $(OBJECTS) moved up
			-- $(LDFLAGS) moved to end (http://sourceforge.net/p/premake/patches/107/)
			-- $(LIBS) moved to end (http://sourceforge.net/p/premake/bugs/279/)

			local cc = iif(p.languages.isc(cfg.language), "CC", "CXX")
			_p('  LINKCMD = $(%s) -o "$@" $(OBJECTS) $(RESOURCES) $(ALL_LDFLAGS) $(LIBS)', cc)
		end
	end


	function make.pch(cfg, toolset)
		local pch = p.tools.gcc.getpch(cfg)
		-- If there is no header, or if PCH has been disabled, I can early out
		if pch == nil then
			return
		end

		_x('  PCH = %s', pch)
		_p('  GCH = $(OBJDIR)/$(notdir $(PCH)).gch')
	end

	function make.pchRules(prj)
		_p('ifneq (,$(PCH))')
		_p('$(OBJECTS): $(GCH) $(PCH) | $(OBJDIR)')
		_p('$(GCH): $(PCH) | $(OBJDIR)')
		_p('\t@echo $(notdir $<)')

		local cmd = iif(prj.language == "C", "$(CC) -x c-header $(ALL_CFLAGS)", "$(CXX) -x c++-header $(ALL_CXXFLAGS)")
		_p('\t$(SILENT) %s -o "$@" -MF "$(@:%%.gch=%%.d)" -c "$<"', cmd)

		_p('else')
		_p('$(OBJECTS): | $(OBJDIR)')
		_p('endif')
		_p('')
	end


	function make.resFlags(cfg, toolset)
		local resflags = table.join(toolset.getdefines(cfg.resdefines), toolset.getincludedirs(cfg, cfg.resincludedirs), cfg.resoptions)
		_p('  ALL_RESFLAGS += $(RESFLAGS) $(DEFINES) $(INCLUDES)%s', make.list(resflags))
	end

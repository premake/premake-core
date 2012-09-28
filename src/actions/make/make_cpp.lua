--
-- make_cpp.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2011 Jason Perkins and the Premake project
--

	premake.make.cpp = {}
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake5.project
	local config = premake5.config


--
-- Generate a GNU make C++ project makefile, with support for the new platforms API.
--

	function make.cpp.generate(prj)
		make.header(prj)

		-- main build rule(s)
		_p('.PHONY: clean prebuild prelink')
		_p('')

		for cfg in project.eachconfig(prj) do
			cpp.config(cfg)
		end
		
		-- list intermediate files
		cpp.objects(prj)
		
		-- identify the shell type
		_p('SHELLTYPE := msdos')
		_p('ifeq (,$(ComSpec)$(COMSPEC))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('ifeq (/bin,$(findstring /bin,$(SHELL)))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('')

		-- common build target rules
		_p('$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')

		make.mkdirrule("$(TARGETDIR)")
		make.mkdirrule("$(OBJDIR)")
	
		-- clean target
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

		-- custom build step targets
		_p('prebuild:')
		_p('\t$(PREBUILDCMDS)')
		_p('')

		_p('prelink:')
		_p('\t$(PRELINKCMDS)')
		_p('')

		-- precompiler header rule
		cpp.pchrules(prj)

		-- file building rules
		cpp.filerules(prj)
		
		-- include the dependencies, built by GCC (with the -MMD flag)
		_p('-include $(OBJECTS:%%.o=%%.d)')
		_p('ifneq (,$(PCH))')
			_p('  -include $(OBJDIR)/$(notdir $(PCH)).d')
		_p('endif')
	end


--
-- Write out the settings for a particular configuration.
--

	function cpp.config(cfg)
		-- identify the toolset used by this configurations
		local toolset = premake.tools[cfg.toolset or "gcc"]
		if not toolset then
			error("Invalid toolset '" + cfg.toolset + "'")
		end
	
		_p('ifeq ($(config),%s)', make.esc(cfg.shortname))

		-- write toolset specific configurations
		cpp.toolconfig(cfg, toolset)

		-- write target information (target dir, name, obj dir)
		make.targetconfig(cfg)
		
		-- write flags
		cpp.flags(cfg, toolset)

		-- set up precompiled headers
		cpp.pchconfig(cfg)

		-- write the link step
		cpp.linkconfig(cfg, toolset)

		-- write the custom build commands		
		_p('  define PREBUILDCMDS')
		if #cfg.prebuildcommands > 0 then
			_p('\t@echo Running pre-build commands')
			_p('\t%s', table.implode(cfg.prebuildcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define PRELINKCMDS')
		if #cfg.prelinkcommands > 0 then
			_p('\t@echo Running pre-link commands')
			_p('\t%s', table.implode(cfg.prelinkcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define POSTBUILDCMDS')
		if #cfg.postbuildcommands > 0 then
			_p('\t@echo Running post-build commands')
			_p('\t%s', table.implode(cfg.postbuildcommands, "", "", "\n\t"))
		end
		_p('  endef')
		_p('')
		
		-- write the target building rule
		cpp.targetrules(cfg)
		
		-- write out config-level makesettings blocks
		make.settings(cfg, toolset)

		_p('endif')
		_p('')	
	end


--
-- Build command for a single file.
--

	function cpp.buildcommand(prj, objext)
		local flags = iif(prj.language == "C", '$(CC) $(CFLAGS)', '$(CXX) $(CXXFLAGS)')
		_p('\t$(SILENT) %s -o "$@" -MF $(@:%%.%s=%%.d) -c "$<"', flags, objext)
	end


--
-- Output the list of file building rules.
--

	function cpp.filerules(prj)
		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node, depth)
				-- check to see if this file has custom rules
				local rules
				for cfg in project.eachconfig(prj) do
					local filecfg = config.getfileconfig(cfg, node.abspath)
					if filecfg and filecfg.buildrule then
						rules = true
						break
					end
				end

				-- if it has custom rules, need to break them out
				-- into individual configurations
				if rules then
					cpp.customfilerules(prj, node)
				else
					cpp.standardfilerules(prj, node)
				end
			end
		})
		_p('')
	end

	function cpp.standardfilerules(prj, node)
		-- C/C++ file
		if path.iscppfile(node.abspath) then
			local objectname = project.getfileobject(prj, node.abspath)
			_p('$(OBJDIR)/%s.o: %s', make.esc(objectname), make.esc(node.relpath))
			_p('\t@echo $(notdir $<)')
			cpp.buildcommand(prj, "o")
			
		-- resource file
		elseif path.isresourcefile(node.abspath) then
			local objectname = project.getfileobject(prj, node.abspath)
			_p('$(OBJDIR)/%s.res: %s', make.esc(objectname), make.esc(node.relpath))
			_p('\t@echo $(notdir $<)')
			_p('\t$(SILENT) $(RESCOMP) $< -O coff -o "$@" $(RESFLAGS)')
		end
	end

	function cpp.customfilerules(prj, node)
		for cfg in project.eachconfig(prj) do
			local filecfg = config.getfileconfig(cfg, node.abspath)
			if filecfg then
				local rule = filecfg.buildrule
	
				_p('ifeq ($(config),%s)', make.esc(cfg.shortname))
				_p('%s: %s', make.esc(rule.outputs[1]), make.esc(filecfg.relpath))
				_p('\t@echo "%s"', rule.description or ("Building " .. filecfg.relpath))
				for _, cmd in ipairs(rule.commands) do
					_p('\t$(SILENT) %s', cmd)
				end
				_p('endif')
			end
		end
	end
	

--
-- Compile flags
--

	function cpp.flags(cfg, toolset)
		_p('  DEFINES   += %s', table.concat(toolset.getdefines(cfg.defines), " "))
		
		local includes = make.esc(toolset.getincludedirs(cfg, cfg.includedirs))
		_p('  INCLUDES  += %s', table.concat(includes, " "))
		
		_p('  CPPFLAGS  += %s $(DEFINES) $(INCLUDES)', table.concat(toolset.getcppflags(cfg), " "))
		_p('  CFLAGS    += $(CPPFLAGS) $(ARCH) %s', table.concat(table.join(toolset.getcflags(cfg), cfg.buildoptions), " "))
		_p('  CXXFLAGS  += $(CFLAGS) %s', table.concat(toolset.getcxxflags(cfg), " "))
		_p('  LDFLAGS   += %s', table.concat(table.join(toolset.getldflags(cfg), cfg.linkoptions), " "))
	
		local resflags = table.join(toolset.getdefines(cfg.resdefines), toolset.getincludedirs(cfg, cfg.resincludedirs), cfg.resoptions)
		_p('  RESFLAGS  += $(DEFINES) $(INCLUDES) %s', table.concat(resflags, " "))
	end


--
-- Link step
--

	function cpp.linkconfig(cfg, toolset)
		local flags = toolset.getlinks(cfg)
		_p('  LIBS      += %s', table.concat(flags, " "))
		
		local deps = config.getlinks(cfg, "siblings", "fullpath")
		_p('  LDDEPS    += %s', table.concat(make.esc(deps), " "))

		if cfg.kind == premake.STATICLIB then
			if cfg.architecture == premake.UNIVERSAL then
				_p('  LINKCMD    = libtool -o $(TARGET) $(OBJECTS)')
			else
				_p('  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)')
			end
		else
			-- This started as: $(TARGET) $(LDFLAGS) $(OBJECTS).
			-- Had trouble linking to certain static libs, so $(OBJECTS) moved up.
			-- $(LDFLAGS) moved: https://sf.net/tracker/?func=detail&aid=3430158&group_id=71616&atid=531880
			local cc = iif(cfg.project.language == "C", "CC", "CXX")
			_p('  LINKCMD    = $(%s) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(LIBS) $(LDFLAGS)', cc)
		end
	end


--
-- List the objects file for the project, and each configuration.
--

	function cpp.objects(prj)
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
					local filecfg = config.getfileconfig(cfg, node.abspath)
					if filecfg then
						incfg[cfg] = filecfg
						custom = (filecfg.buildrule ~= nil)
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
					local objectname = project.getfileobject(prj, node.abspath)
					objectname = "$(OBJDIR)/" .. objectname .. iif(kind == "objects", ".o", ".res")
					
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
							-- if the custom build outputs an object file, add it to
							-- the link step automatically to match Visual Studio
							local output = filecfg.buildrule.outputs[1]
							if path.isobjectfile(output) then
								table.insert(configs[cfg].objects, output)
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
				_p('\t%s \\', make.esc(objectname))
			end
			_p('')
		end
		
		listobjects('OBJECTS :=', root.objects, 'o')
		listobjects('RESOURCES :=', root.resources, 'res')
		
		-- ...then individual configurations, as needed
		for cfg in project.eachconfig(prj) do
			local files = configs[cfg]
			if #files.objects > 0 or #files.resources > 0 then
				_p('ifeq ($(config),%s)', make.esc(cfg.shortname))
				if #files.objects > 0 then
					listobjects('  OBJECTS +=', files.objects)
				end
				if #files.resources > 0 then
					listobjects('  RESOURCES +=', files.resources)
				end
				_p('endif')
				_p('')
			end
		end
	end


--
-- Precompiled header support
--

	function cpp.pchconfig(cfg)
		if not cfg.flags.NoPCH and cfg.pchheader then
			-- Visual Studio needs the PCH path to match the way it appears in
			-- the project's #include statement. GCC needs the full path. Assume
			-- the #include path is given, is search the include dirs for it.
			local pchheader = cfg.pchheader
			for _, incdir in ipairs(cfg.includedirs) do
				local testname = path.join(incdir, cfg.pchheader)
				if os.isfile(testname) then
					pchheader = testname
					break
				end
			end

			local gch = make.esc(path.getname(pchheader))
			_p('  PCH        = %s', make.esc(project.getrelative(cfg.project, pchheader)))
			_p('  GCH        = $(OBJDIR)/%s.gch', gch)
			_p('  CPPFLAGS  += -I$(OBJDIR) -include $(OBJDIR)/%s', gch)
		end
	end

	function cpp.pchrules(prj)
		_p('ifneq (,$(PCH))')
		_p('$(GCH): $(PCH)')
		_p('\t@echo $(notdir $<)')
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t-$(SILENT) cp $< $(OBJDIR)')
		_p('else')
		_p('\t$(SILENT) xcopy /D /Y /Q "$(subst /,\\,$<)" "$(subst /,\\,$(OBJDIR))" 1>nul')
		_p('endif')
		cpp.buildcommand(prj, "gch")
		_p('endif')
		_p('')
	end


--
-- The main build target rules.
--

	function cpp.targetrules(cfg)
		local macapp = (cfg.system == premake.MACOSX and cfg.kind == premake.WINDOWEDAPP)
		
		if macapp then
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist')
		else
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
		end
		_p('\t@:')
		
		if macapp then
			_p('')
			_p('$(dir $(TARGETDIR))PkgInfo:')
			_p('$(dir $(TARGETDIR))Info.plist:')
		end
	end


--
-- System specific toolset configuration.
--

	function cpp.toolconfig(cfg, toolset)
		local tool = toolset.gettoolname(cfg, "cc")
		if tool then
			_p('  CC         = %s', tool)
		end

		tool = toolset.gettoolname(cfg, "cxx")
		if tool then
			_p('  CXX        = %s', tool)
		end

		tool = toolset.gettoolname(cfg, "ar")
		if tool then
			_p('  AR         = %s', tool)
		end
	end


-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------


	function premake.make_cpp(prj)
		-- create a shortcut to the compiler interface
		local cc = premake.gettool(prj)

		-- build a list of supported target platforms that also includes a generic build
		local platforms = premake.filterplatforms(prj.solution, cc.platforms, "Native")

		premake.gmake_cpp_header(prj, cc, platforms)

		for _, platform in ipairs(platforms) do
			for cfg in premake.eachconfig(prj, platform) do
				premake.gmake_cpp_config(cfg, cc)
			end
		end

		-- list intermediate files
		_p('OBJECTS := \\')
		for _, file in ipairs(prj.files) do
			if path.iscppfile(file) then
				_p('\t$(OBJDIR)/%s.o \\', _MAKE.esc(path.getbasename(file)))
			end
		end
		_p('')

		_p('RESOURCES := \\')
		for _, file in ipairs(prj.files) do
			if path.isresourcefile(file) then
				_p('\t$(OBJDIR)/%s.res \\', _MAKE.esc(path.getbasename(file)))
			end
		end
		_p('')

		-- identify the shell type
		_p('SHELLTYPE := msdos')
		_p('ifeq (,$(ComSpec)$(COMSPEC))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('ifeq (/bin,$(findstring /bin,$(SHELL)))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('')

		-- main build rule(s)
		_p('.PHONY: clean prebuild prelink')
		_p('')

		if os.is("MacOSX") and prj.kind == "WindowedApp" then
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist')
		else
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
		end
		_p('\t@:')
		_p('')

		-- target build rule
		_p('$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')

		-- Create destination directories. Can't use $@ for this because it loses the
		-- escaping, causing issues with spaces and parenthesis
		_p('$(TARGETDIR):')
		premake.make_mkdirrule("$(TARGETDIR)")

		_p('$(OBJDIR):')
		premake.make_mkdirrule("$(OBJDIR)")

		-- Mac OS X specific targets
		if os.is("MacOSX") and prj.kind == "WindowedApp" then
			_p('$(dir $(TARGETDIR))PkgInfo:')
			_p('$(dir $(TARGETDIR))Info.plist:')
			_p('')
		end

		-- clean target
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

		-- custom build step targets
		_p('prebuild:')
		_p('\t$(PREBUILDCMDS)')
		_p('')

		_p('prelink:')
		_p('\t$(PRELINKCMDS)')
		_p('')

		-- precompiler header rule
		cpp.pchrules(prj)

		-- per-file rules
		for _, file in ipairs(prj.files) do
			if path.iscppfile(file) then
				_p('$(OBJDIR)/%s.o: %s', _MAKE.esc(path.getbasename(file)), _MAKE.esc(file))
				_p('\t@echo $(notdir $<)')
				cpp.buildcommand_old(path.iscfile(file))
			elseif (path.getextension(file) == ".rc") then
				_p('$(OBJDIR)/%s.res: %s', _MAKE.esc(path.getbasename(file)), _MAKE.esc(file))
				_p('\t@echo $(notdir $<)')
				_p('\t$(SILENT) $(RESCOMP) $< -O coff -o "$@" $(RESFLAGS)')
			end
		end
		_p('')

		-- include the dependencies, built by GCC (with the -MMD flag)
		_p('-include $(OBJECTS:%%.o=%%.d)')
	end



--
-- Write the makefile header
--

	function premake.gmake_cpp_header(prj, cc, platforms)
		_p('# %s project makefile autogenerated by Premake', premake.action.current().shortname)

		-- set up the environment
		_p('ifndef config')
		_p('  config=%s', _MAKE.esc(premake.getconfigname(prj.solution.configurations[1], platforms[1], true)))
		_p('endif')
		_p('')

		_p('ifndef verbose')
		_p('  SILENT = @')
		_p('endif')
		_p('')

		_p('ifndef CC')
		_p('  CC = %s', cc.cc)
		_p('endif')
		_p('')

		_p('ifndef CXX')
		_p('  CXX = %s', cc.cxx)
		_p('endif')
		_p('')

		_p('ifndef AR')
		_p('  AR = %s', cc.ar)
		_p('endif')
		_p('')
		
		_p('ifndef RESCOMP')
		_p('  ifdef WINDRES')
		_p('    RESCOMP = $(WINDRES)')
		_p('  else')
		_p('    RESCOMP = windres')
		_p('  endif')
		_p('endif')
		_p('')	
	end

--
-- Write a block of configuration settings.
--

	function premake.gmake_cpp_config(cfg, cc)

		_p('ifeq ($(config),%s)', _MAKE.esc(cfg.shortname))

		-- if this platform requires a special compiler or linker, list it here
		cpp.platformtools_old(cfg, cc)

		_p('  OBJDIR     = %s', _MAKE.esc(cfg.objectsdir))
		_p('  TARGETDIR  = %s', _MAKE.esc(cfg.buildtarget.directory))
		_p('  TARGET     = $(TARGETDIR)/%s', _MAKE.esc(cfg.buildtarget.name))
		_p('  DEFINES   += %s', table.concat(cc.getdefines(cfg.defines), " "))
		_p('  INCLUDES  += %s', table.concat(cc.getincludedirs(cfg.includedirs), " "))

		-- CPPFLAGS, CFLAGS, CXXFLAGS, LDFLAGS, and RESFLAGS
		cpp.flags_old(cfg, cc)

		-- set up precompiled headers
		cpp.pchconfig_old(cfg)

		_p('  LIBS      += %s', table.concat(cc.getlinkflags(cfg), " "))
		_p('  LDDEPS    += %s', table.concat(_MAKE.esc(premake.getlinks(cfg, "siblings", "fullpath")), " "))

		if cfg.kind == "StaticLib" then
			if cfg.platform:startswith("Universal") then
				_p('  LINKCMD    = libtool -o $(TARGET) $(OBJECTS)')
			else
				_p('  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)')
			end
		else
			-- this was $(TARGET) $(LDFLAGS) $(OBJECTS)
			--  but had trouble linking to certain static libs so $(OBJECTS) moved up
			-- then $(LDFLAGS) moved to end
			--   https://sourceforge.net/tracker/?func=detail&aid=3430158&group_id=71616&atid=531880
			_p('  LINKCMD    = $(%s) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(LIBS) $(LDFLAGS)', iif(cfg.language == "C", "CC", "CXX"))
		end

		_p('  define PREBUILDCMDS')
		if #cfg.prebuildcommands > 0 then
			_p('\t@echo Running pre-build commands')
			_p('\t%s', table.implode(cfg.prebuildcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define PRELINKCMDS')
		if #cfg.prelinkcommands > 0 then
			_p('\t@echo Running pre-link commands')
			_p('\t%s', table.implode(cfg.prelinkcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define POSTBUILDCMDS')
		if #cfg.postbuildcommands > 0 then
			_p('\t@echo Running post-build commands')
			_p('\t%s', table.implode(cfg.postbuildcommands, "", "", "\n\t"))
		end
		_p('  endef')

		-- write out config-level makesettings blocks
		make.settings_old(cfg, cc)

		_p('endif')
		_p('')
	end


--
-- Platform support
--

	function cpp.platformtools_old(cfg, cc)
		local platform = cc.platforms[cfg.platform]
		if platform.cc then
			_p('  CC         = %s', platform.cc)
		end
		if platform.cxx then
			_p('  CXX        = %s', platform.cxx)
		end
		if platform.ar then
			_p('  AR         = %s', platform.ar)
		end
	end


--
-- Configurations
--

	function cpp.flags_old(cfg, cc)
		_p('  CPPFLAGS  += %s $(DEFINES) $(INCLUDES)', table.concat(cc.getcppflags(cfg), " "))
		_p('  CFLAGS    += $(CPPFLAGS) $(ARCH) %s', table.concat(table.join(cc.getcflags(cfg), cfg.buildoptions), " "))
		_p('  CXXFLAGS  += $(CFLAGS) %s', table.concat(cc.getcxxflags(cfg), " "))

		-- Patch #3401184 changed the order
		_p('  LDFLAGS   += %s', table.concat(table.join(cc.getlibdirflags(cfg), cc.getldflags(cfg), cfg.linkoptions), " "))

		_p('  RESFLAGS  += $(DEFINES) $(INCLUDES) %s',
		        table.concat(table.join(cc.getdefines(cfg.resdefines),
		                                cc.getincludedirs(cfg.resincludedirs), cfg.resoptions), " "))
	end


--
-- Precompiled header support
--

	function cpp.pchconfig_old(cfg)
		-- GCC needs the full path to the PCH, while Visual Studio needs
		-- only the name (or rather, the name as specified in the #include
		-- statement). Try to locate the PCH in the project.
		local pchheader = cfg.pchheader
		for _, incdir in ipairs(cfg.includedirs) do
			local testname = path.join(incdir, cfg.pchheader)
			if os.isfile(testname) then
				pchheader = testname
				break
			end
		end

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p('  PCH        = %s', _MAKE.esc(path.getrelative(cfg.location, cfg.pchheader)))
			_p('  GCH        = $(OBJDIR)/%s.gch', _MAKE.esc(path.getname(cfg.pchheader)))
			_p('  CPPFLAGS  += -I$(OBJDIR) -include $(OBJDIR)/%s', _MAKE.esc(path.getname(cfg.pchheader)))
		end
	end


--
-- Build command for a single file.
--

	function cpp.buildcommand_old(iscfile)
		local flags = iif(iscfile, '$(CC) $(CFLAGS)', '$(CXX) $(CXXFLAGS)')
		_p('\t$(SILENT) %s -o "$@" -MF $(@:%%.o=%%.d) -c "$<"', flags)
	end



--
-- make_csharp.lua
-- Generate a C# project makefile.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.make.cs = {}
	local make = premake.make
	local cs = premake.make.cs
	local project = premake5.project
	local config = premake5.config


--
-- Generate a GNU make C# project makefile, with support for the new platforms API.
--

	function make.generate_csharp(prj)
		-- I've only got one .NET toolset right now
		local toolset = premake.dotnet		
		
		make.header(prj)

		-- main build rule(s)
		_p('.PHONY: clean prebuild prelink')
		_p('')

		for cfg in project.eachconfig(prj) do
			cs.config(cfg, toolset)
		end

		local firstcfg = project.getfirstconfig(prj)
		cs.prj_config(firstcfg, toolset)

		-- list source files
		_p('SOURCES += \\')
		cs.listsources(prj, function(node)
			if toolset.getbuildaction(node) == "Compile" then
				return node.relpath
			end
		end)
		_p('')

		_p('EMBEDFILES += \\')
		cs.listsources(prj, function(node)
			if toolset.getbuildaction(node) == "EmbeddedResource" then
				return cs.getresourcefilename(firstcfg, node.relpath)
			end
		end)
		_p('')

		--[[
		_p('COPYFILES += \\')
		for target, source in pairs(cfgpairs[anycfg]) do
			_p('\t%s \\', target)
		end
		for target, source in pairs(copypairs) do
			_p('\t%s \\', target)
		end
		_p('')
		--]]
		
		make.detectshell()
		
		_p('all: $(TARGETDIR) $(OBJDIR) prebuild $(EMBEDFILES) $(COPYFILES) prelink $(TARGET)')
		_p('')
		
		_p('$(TARGET): $(SOURCES) $(EMBEDFILES) $(DEPENDS)')
		_p('\t$(SILENT) $(CSC) /nologo /out:$@ $(FLAGS) $(REFERENCES) $(SOURCES) $(patsubst %%,/resource:%%,$(EMBEDFILES))')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
		
		make.mkdirrule("$(TARGETDIR)")
		make.mkdirrule("$(OBJDIR)")
		
		-- clean target
		local target = firstcfg.buildtarget
		
		_p('clean:')
		_p('\t@echo Cleaning %s', prj.name)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) rm -f $(TARGETDIR)/%s.* $(COPYFILES)', target.basename)
		_p('\t$(SILENT) rm -rf $(OBJDIR)')
		_p('else')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(TARGETDIR)/%s) del $(subst /,\\\\,$(TARGETDIR)/%s.*)', target.name, target.basename)
		--[[
		for target, source in pairs(cfgpairs[anycfg]) do
			_p('\t$(SILENT) if exist $(subst /,\\\\,%s) del $(subst /,\\\\,%s)', target, target)
		end
		for target, source in pairs(copypairs) do
			_p('\t$(SILENT) if exist $(subst /,\\\\,%s) del $(subst /,\\\\,%s)', target, target)
		end
		--]]
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

		--[[
		-- per-file rules
		_p('# Per-configuration copied file rules')
		for cfg in premake.eachconfig(prj) do
			_p('ifneq (,$(findstring %s,$(config)))', _MAKE.esc(cfg.name:lower()))
			for target, source in pairs(cfgpairs[cfg]) do
				premake.make_copyrule(source, target)
			end
			_p('endif')
			_p('')
		end
		
		_p('# Copied file rules')
		for target, source in pairs(copypairs) do
			premake.make_copyrule(source, target)
		end

		_p('# Embedded file rules')
		for _, fname in ipairs(embedded) do 
			if path.getextension(fname) == ".resx" then
				_p('%s: %s', getresourcefilename(prj, fname), _MAKE.esc(fname))
				_p('\t$(SILENT) $(RESGEN) $^ $@')
			end
			_p('')
		end
		--]]
	end


--
-- Write out the settings for a particular configuration.
--

	function cs.config(cfg, toolset)
		_p('ifeq ($(config),%s)', make.esc(cfg.shortname))
	
		-- write toolset specific configurations
		cs.toolconfig(cfg, toolset)

		-- write target information (target dir, name, obj dir)
		make.targetconfig(cfg)
		
		-- write flags
		cs.flags(cfg, toolset)

		-- write the linking information
		cs.linking(cfg, toolset)

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
		
		-- write out config-level makesettings blocks
		make.settings(cfg, toolset)
		
		_p('endif')
		_p('')	
	end


--
-- Compile flags
--

	function cs.flags(cfg, toolset)
		local defines = table.implode(cfg.defines, "/d:", "", " ")
		local flags = table.join(defines, toolset.getflags(cfg), cfg.buildoptions)
		_p('  FLAGS      = %s', table.concat(flags, " "))
	end


--
-- Given a .resx resource file, builds the path to corresponding .resource
-- file, matching the behavior and naming of Visual Studio.
--
		
	function cs.getresourcefilename(cfg, fname)
		if path.getextension(fname) == ".resx" then
		    local name = cfg.buildtarget.basename .. "."
		    local dir = path.getdirectory(fname)
		    if dir ~= "." then 
				name = name .. path.translate(dir, ".") .. "."
			end
			return "$(OBJDIR)/" .. make.esc(name .. path.getbasename(fname)) .. ".resources"
		else
			return fname
		end
	end


--
-- Linker arguments
--

	function cs.linking(cfg, toolset)
		local deps = make.esc(config.getlinks(cfg, "dependencies", "fullpath"))
		_p('  DEPENDS    = %s', table.concat(deps))
		_p('  REFERENCES = %s', table.implode(deps, "/r:", "", " "))
	end


--
-- Iterate and output some selection of the source code files.
--

	function cs.listsources(prj, selector)
		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node, depth)
				local value = selector(node)
				if value then
					_p('\t%s \\', make.esc(path.translate(value)))
				end
			end
		})		
	end


--
-- To maintain compatibility with Visual Studio, these values must
-- be set on the project level, and not per-configuration.
--

	function cs.prj_config(cfg, toolset)
		local kindflag = "/t:" .. toolset.getkind(cfg):lower()
		local libdirs = table.implode(make.esc(cfg.libdirs), "/lib:", "", " ")		
		_p('FLAGS      += %s', table.concat(table.join(kindflag, libdirs), " "))
	
		local refs = make.esc(config.getlinks(cfg, "system", "fullpath"))
		_p('REFERENCES += %s', table.implode(refs, "/r:", "", " "))

		_p('')
	end


--
-- System specific toolset configuration.
--

	function cs.toolconfig(cfg, toolset)
		_p('  CSC        = %s', toolset.gettoolname(cfg, "csc"))
		_p('  RESGEN     = %s', toolset.gettoolname(cfg, "resgen"))
	end




-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------


--
-- Given a .resx resource file, builds the path to corresponding .resource
-- file, matching the behavior and naming of Visual Studio.
--
		
	local function getresourcefilename(cfg, fname)
		if path.getextension(fname) == ".resx" then
		    local name = cfg.buildtarget.basename .. "."
		    local dir = path.getdirectory(fname)
		    if dir ~= "." then 
				name = name .. path.translate(dir, ".") .. "."
			end
			return "$(OBJDIR)/" .. _MAKE.esc(name .. path.getbasename(fname)) .. ".resources"
		else
			return fname
		end
	end



--
-- Main function
--
	
	function premake.make_csharp(prj)
		local csc = premake.dotnet

		-- Do some processing up front: build a list of configuration-dependent libraries.
		-- Libraries that are built to a location other than $(TARGETDIR) will need to
		-- be copied so they can be found at runtime.
		local cfglibs = { }
		local cfgpairs = { }
		local anycfg
		for cfg in premake.eachconfig(prj) do
			anycfg = cfg
			cfglibs[cfg] = premake.getlinks(cfg, "siblings", "fullpath")
			cfgpairs[cfg] = { }
			for _, fname in ipairs(cfglibs[cfg]) do
				if path.getdirectory(fname) ~= cfg.buildtarget.directory then
					cfgpairs[cfg]["$(TARGETDIR)/" .. _MAKE.esc(path.getname(fname))] = _MAKE.esc(fname)
				end
			end
		end
		
		-- sort the files into categories, based on their build action
		local sources = {}
		local embedded = { }
		local copypairs = { }
		
		for fcfg in premake.project.eachfile(prj) do
			local action = csc.getbuildaction(fcfg)
			if action == "Compile" then
				table.insert(sources, fcfg.name)
			elseif action == "EmbeddedResource" then
				table.insert(embedded, fcfg.name)
			elseif action == "Content" then
				copypairs["$(TARGETDIR)/" .. _MAKE.esc(path.getname(fcfg.name))] = _MAKE.esc(fcfg.name)
			elseif path.getname(fcfg.name):lower() == "app.config" then
				copypairs["$(TARGET).config"] = _MAKE.esc(fcfg.name)
			end
		end

		-- Any assemblies that are on the library search paths should be copied
		-- to $(TARGETDIR) so they can be found at runtime
		local paths = table.translate(prj.libdirs, function(v) return path.join(prj.basedir, v) end)
		paths = table.join({prj.basedir}, paths)
		for _, libname in ipairs(premake.getlinks(prj, "system", "fullpath")) do
			local libdir = os.pathsearch(libname..".dll", unpack(paths))
			if (libdir) then
				local target = "$(TARGETDIR)/" .. _MAKE.esc(path.getname(libname))
				local source = path.getrelative(prj.basedir, path.join(libdir, libname))..".dll"
				copypairs[target] = _MAKE.esc(source)
			end
		end
		
		-- end of preprocessing --


		-- set up the environment
		_p('# %s project makefile autogenerated by Premake', premake.action.current().shortname)
		_p('')
		
		_p('ifndef config')
		_p('  config=%s', _MAKE.esc(prj.configurations[1]:lower()))
		_p('endif')
		_p('')
		
		_p('ifndef verbose')
		_p('  SILENT = @')
		_p('endif')
		_p('')
		
		_p('ifndef CSC')
		_p('  CSC=%s', csc.getcompilervar(prj))
		_p('endif')
		_p('')
		
		_p('ifndef RESGEN')
		_p('  RESGEN=resgen')
		_p('endif')
		_p('')

		-- Platforms aren't support for .NET projects, but I need the ability to match
		-- the buildcfg:platform identifiers with a block of settings. So enumerate the
		-- pairs the same way I do for C/C++ projects, but always use the generic settings
		local platforms = premake.filterplatforms(prj.solution, premake[_OPTIONS.cc].platforms)
		table.insert(platforms, 1, "")

		-- write the configuration blocks
		for cfg in premake.eachconfig(prj) do
			premake.gmake_cs_config(cfg, csc, cfglibs)
		end

		-- set project level values
		_p('# To maintain compatibility with VS.NET, these values must be set at the project level')
		_p('TARGET     := $(TARGETDIR)/%s', _MAKE.esc(prj.buildtarget.name))
		_p('FLAGS      += /t:%s %s', csc.getkind(prj):lower(), table.implode(_MAKE.esc(prj.libdirs), "/lib:", "", " "))
		_p('REFERENCES += %s', table.implode(_MAKE.esc(premake.getlinks(prj, "system", "basename")), "/r:", ".dll", " "))
		_p('')
		
		-- list source files
		_p('SOURCES := \\')
		for _, fname in ipairs(sources) do
			_p('\t%s \\', _MAKE.esc(path.translate(fname)))
		end
		_p('')
		
		_p('EMBEDFILES := \\')
		for _, fname in ipairs(embedded) do
			_p('\t%s \\', getresourcefilename(prj, fname))
		end
		_p('')

		_p('COPYFILES += \\')
		for target, source in pairs(cfgpairs[anycfg]) do
			_p('\t%s \\', target)
		end
		for target, source in pairs(copypairs) do
			_p('\t%s \\', target)
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
		
		_p('all: $(TARGETDIR) $(OBJDIR) prebuild $(EMBEDFILES) $(COPYFILES) prelink $(TARGET)')
		_p('')
		
		_p('$(TARGET): $(SOURCES) $(EMBEDFILES) $(DEPENDS)')
		_p('\t$(SILENT) $(CSC) /nologo /out:$@ $(FLAGS) $(REFERENCES) $(SOURCES) $(patsubst %%,/resource:%%,$(EMBEDFILES))')
		_p('\t$(POSTBUILDCMDS)')
		_p('')

		-- Create destination directories. Can't use $@ for this because it loses the
		-- escaping, causing issues with spaces and parenthesis
		_p('$(TARGETDIR):')
		premake.make_mkdirrule("$(TARGETDIR)")
		
		_p('$(OBJDIR):')
		premake.make_mkdirrule("$(OBJDIR)")

		-- clean target
		_p('clean:')
		_p('\t@echo Cleaning %s', prj.name)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) rm -f $(TARGETDIR)/%s.* $(COPYFILES)', prj.buildtarget.basename)
		_p('\t$(SILENT) rm -rf $(OBJDIR)')
		_p('else')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(TARGETDIR)/%s.*) del $(subst /,\\\\,$(TARGETDIR)/%s.*)', prj.buildtarget.basename, prj.buildtarget.basename)
		for target, source in pairs(cfgpairs[anycfg]) do
			_p('\t$(SILENT) if exist $(subst /,\\\\,%s) del $(subst /,\\\\,%s)', target, target)
		end
		for target, source in pairs(copypairs) do
			_p('\t$(SILENT) if exist $(subst /,\\\\,%s) del $(subst /,\\\\,%s)', target, target)
		end
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

		-- per-file rules
		_p('# Per-configuration copied file rules')
		for cfg in premake.eachconfig(prj) do
			_p('ifneq (,$(findstring %s,$(config)))', _MAKE.esc(cfg.name:lower()))
			for target, source in pairs(cfgpairs[cfg]) do
				premake.make_copyrule(source, target)
			end
			_p('endif')
			_p('')
		end
		
		_p('# Copied file rules')
		for target, source in pairs(copypairs) do
			premake.make_copyrule(source, target)
		end

		_p('# Embedded file rules')
		for _, fname in ipairs(embedded) do 
			if path.getextension(fname) == ".resx" then
				_p('%s: %s', getresourcefilename(prj, fname), _MAKE.esc(fname))
				_p('\t$(SILENT) $(RESGEN) $^ $@')
			end
			_p('')
		end
		
	end


--
-- Write a block of configuration settings.
--

	function premake.gmake_cs_config(cfg, csc, cfglibs)
			
		_p('ifneq (,$(findstring %s,$(config)))', _MAKE.esc(cfg.name:lower()))
		_p('  TARGETDIR  := %s', _MAKE.esc(cfg.buildtarget.directory))
		_p('  OBJDIR     := %s', _MAKE.esc(cfg.objectsdir))
		_p('  DEPENDS    := %s', table.concat(_MAKE.esc(premake.getlinks(cfg, "dependencies", "fullpath")), " "))
		_p('  REFERENCES := %s', table.implode(_MAKE.esc(cfglibs[cfg]), "/r:", "", " "))
		_p('  FLAGS      += %s %s', table.implode(cfg.defines, "/d:", "", " "), table.concat(table.join(csc.getflags(cfg), cfg.buildoptions), " "))
		
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
		
		_p('endif')
		_p('')

	end

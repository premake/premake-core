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

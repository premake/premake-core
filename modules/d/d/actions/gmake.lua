
--
-- d/actions/gmake.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013 Andrew Gough and the Premake project
--

    premake.make.d = { }

    local make = premake.make
    local d = premake.make.d
    local project = premake5.project
    local config = premake5.config

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
    --table.print( gmake )

--
-- Override the GMake action 'onproject' funtion to provide 
-- D knowledge...
--
    premake.override( gmake, "onproject", function(oldfn, prj)
 
		local makefile = make.getmakefilename(prj, true)
        if project.isd(prj) then
            premake.generate(prj, makefile, make.d.generate)
            return
        end

        oldfn(prj)
    end)

--
-- d/gmake.lua
-- Generate a D project makefile.
-- Copyright (c) 2002-2009 Andrew Gough and the Premake project
--

    local toolset
    function d.generate(prj)

        _p( "# Premake D extension generated file.  See %s", premake.extensions.d.support_url )
        make.header(prj)

        -- main build rule(s)
        _p('.PHONY: clean prebuild prelink')
        _p('')

        for cfg in project.eachconfig(prj) do
            d.config(cfg)
        end
        
        -- list intermediate files
        d.objects(prj)

        make.detectshell()

        _p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
        _p('\t@:')
        _p('')

		-- common build target rules
		_p('$(TARGET): $(OBJECTS) $(LDDEPS)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')

        -- Create destination directories. Can't use $@ for this because it loses the
        -- escaping, causing issues with spaces and parenthesis
        make.mkdirrule("$(TARGETDIR)")
        make.mkdirrule("$(OBJDIR)")

        -- clean target
        _p('clean:')
        _p('\t@echo Cleaning %s...', prj.name)
        _p('ifeq (posix,$(SHELLTYPE))')
        _p('\t$(SILENT) rm -f  $(TARGET)')
        _p('\t$(SILENT) rm -rf  $(OBJDIR)')
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
        
		-- file building rules
		d.filerules(prj)

    end

--
-- Write a block of configuration settings.
--

    function d.config(cfg)

        toolset = premake.tools[cfg.toolset or "dmd"]
        if not toolset then
            error("Invalid toolset '" + cfg.toolset + "'")
        end

        _p('ifeq ($(config),%s)', make.esc(cfg.shortname))

        -- write toolset specific configurations
        local sysflags = toolset.sysflags[cfg.architecture] or toolset.sysflags[cfg.system] or {}
        _p('  DC         = %s', toolset.dc)

        -- write target information (target dir, name, obj dir)
        d.targetconfig(cfg,toolset)
        d.linkconfig(cfg,toolset)

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

        -- write out config-level makesettings blocks
        make.settings(cfg, toolset)

        _p('endif')
        _p('')

    end

--
-- Target (name, dir) configuration.
--

    function d.targetconfig(cfg,toolset)
        local targetinfo = config.gettargetinfo(cfg)
        _p('  OBJDIR     = %s', make.esc(project.getrelative(cfg.project, cfg.objdir)))
        _p('  TARGETDIR  = %s', make.esc(targetinfo.directory))
        _p('  TARGET     = $(TARGETDIR)/%s', make.esc(targetinfo.name))
        _p('')
        _p('  DEFINES   += %s', table.concat(toolset.getdefines(cfg.defines), " "))
        _p('  INCLUDES  += %s', table.concat(toolset.getincludedirs(cfg), " "))
        _p('  DFLAGS    += $(ARCH) $(DEFINES) $(INCLUDES) %s', table.concat(table.join(toolset.getflags(cfg), cfg.buildoptions), " "))
        _p('  LDFLAGS   += %s', table.concat(table.join(toolset.getldflags(cfg), cfg.linkoptions), " "))
        _p('')
    end

--
-- Link Step
--

    function d.linkconfig(cfg, toolset)
        local flags = toolset.getlinks(cfg)
        _p('  LIBS      += %s', table.concat(flags, " "))

        local deps = config.getlinks(cfg, "siblings", "fullpath")
        _p('  LDDEPS    += %s', table.concat(make.esc(deps), " "))
        _p('  LINKCMD   = $(DC) ' .. toolset.gettarget("$(TARGET)") .. ' $(LDFLAGS) $(LIBS) $(OBJECTS)')
        _p('')
    end


	function d.filerules(prj)
		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node, depth)
				-- check to see if this file has custom rules
				d.standardfilerules(prj, node, toolset)
			end
		})
		_p('')
	end

	function d.standardfilerules(prj, node, toolset)
		local objectname = project.getfileobject(prj, node.abspath)
		_p('$(OBJDIR)/%s.o: %s', make.esc(objectname), make.esc(node.relpath))
		_p('\t@echo $(notdir $<)')
		_p('\t$(SILENT) $(DC) $(DFLAGS) %s -c $<', toolset.gettarget("$@"), objext)
	end

--
-- List the objects file for the project, and each configuration.
--

    function d.objects(prj)
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
                        custom = config.hasCustomBuildRule(filecfg)
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
					local objectname = project.getfileobject(prj, node.abspath)
					objectname = "$(OBJDIR)/" .. objectname .. ".o"

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
				_p('\t%s \\', make.esc(objectname))
			end
			_p('')
		end

		listobjects('OBJECTS :=', root.objects, 'o')

		-- ...then individual configurations, as needed
		for cfg in project.eachconfig(prj) do
			local files = configs[cfg]
			if #files.objects > 0 then
				_p('ifeq ($(config),%s)', make.esc(cfg.shortname))
				if #files.objects > 0 then
					listobjects('  OBJECTS +=', files.objects)
				end
				_p('endif')
				_p('')
			end
		end
    end




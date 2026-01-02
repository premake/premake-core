--
-- ninja_cpp.lua
-- Define the ninja cpp functionality
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local p = premake
local ninja = p.modules.ninja

local tree = p.tree
local project = p.project
local config = p.config
local fileconfig = p.fileconfig

p.modules.ninja.cpp = {}
local m = p.modules.ninja.cpp

m.elements = {}

m.elements.project = function(prj)
	return {
		ninja.header,
		m.rules,
		m.configurations,
		m.buildTargets,
		m.projectPhonies,
	}
end

function m.generate(prj)
	p.callArray(m.elements.project, prj)
	_p("") -- Empty line at end of file
end

function m.rules(prj)
	local rulesDone = {}
	
	for cfg in project.eachconfig(prj) do
		local toolset = ninja.gettoolset(cfg)
		local toolsetKey = tostring(toolset)
		
		if not rulesDone[toolsetKey] then
			m.ccrule(cfg, toolset)
			m.cxxrule(cfg, toolset)
			m.resourcerule(cfg, toolset)
			m.linkrule(cfg, toolset)
			m.pchrule(cfg, toolset)
			m.copyrule(cfg, toolset)
			m.prebuildcommandrule(cfg, toolset)
			m.prelinkcommandrule(cfg, toolset)
			m.postbuildcommandrule(cfg, toolset)
			m.customcommand(cfg, toolset)
			m.customrule(cfg, toolset, prj)
			
			rulesDone[toolsetKey] = true
		end
	end
end

function m.ccrule(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local ccname = toolset.gettoolname(cfg, "cc")
	_p("rule cc_%s", cfg.toolset)

	if toolset == p.tools.msc then
		_p("  command = %s $cflags /nologo /showIncludes -c /Tc$in /Fo$out", ccname)
		_p("  deps = msvc")
	else
		_p("  command = %s $cflags -c $in -o $out", ccname)
		_p("  deps = gcc")
		_p("  depfile = $out.d")
	end
	
	_p("  description = Compiling C source $in")

	_p("")
end

function m.cxxrule(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local cxxname = toolset.gettoolname(cfg, "cxx")
	_p("rule cxx_%s", cfg.toolset)
	
	if toolset == p.tools.msc then
		_p("  command = %s $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out", cxxname)
		_p("  deps = msvc")
	else
		_p("  command = %s $cxxflags -c $in -o $out", cxxname)
		_p("  deps = gcc")
		_p("  depfile = $out.d")
	end

	_p("  description = Compiling C++ source $in")

	_p("")
end

function m.resourcerule(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local rcname = toolset.gettoolname(cfg, "rc")

	_p("rule rc_%s", cfg.toolset)
	
	if toolset == p.tools.msc then
		_p("  command = %s /nologo /fo$out $in $resflags", rcname)
	else
		_p("  command = %s -i $in -o $out $resflags", rcname)
	end
	
	_p("  description = Compiling resource $in")
	_p("")
end

function m.linkrule(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)

	if toolset == p.tools.msc then
		if cfg.kind == p.STATICLIB then
			local arname = toolset.gettoolname(cfg, "ar")
			_p("rule ar_%s", cfg.toolset)
			_p("  command = %s $in /nologo -OUT:$out", arname)
			_p("  description = Archiving static library $out")
			_p("")
		else
			local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
			_p("rule link_%s", cfg.toolset)
			_p("  command = %s $in $links /link $ldflags /nologo /out:$out", ldname)
			_p("  description = Linking target $out")
			_p("")
		end
	else
		if cfg.kind == p.STATICLIB then
			local arname = toolset.gettoolname(cfg, "ar")
			_p("rule ar_%s", cfg.toolset)
			_p("  command = %s -rcs $out $in", arname)
			_p("  description = Archiving static library $out")
			_p("")
		else
			local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
			local commands = string.format("command = %s -o $out $in $links $ldflags", ldname);
			
			commands = commands:gsub("(.-)%s*$", "%1")
			commands = commands:gsub("%s+", " ")

			_p("rule link_%s", cfg.toolset)
			_p("  %s", commands)
			_p("  description = Linking target $out")
			_p("")
		end
	end
end

function m.pchrule(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local pchname = toolset.gettoolname(cfg, cfg.language == "C" and "cc" or "cxx")

	_p("rule pch_%s", cfg.toolset)
	if toolset == p.tools.msc then
		-- MSVC: /Yc creates the PCH, /Fp specifies output, /Fo specifies obj output
		_p("  command = %s /nologo /Yc$pchheader /Fp$out /Fo$objdir/ $cflags /c $in", pchname)
		_p("  description = Generating precompiled header $pchheader")
	else
		-- GCC/Clang: compile header as C or C++ header
		local headerType = iif(cfg.language == "C", "c-header", "c++-header")
		_p("  command = %s -x %s $cflags -o $out -MD -MF $out.d -c $in", pchname, headerType)
		_p("  description = Generating precompiled header $in")
		_p("  depfile = $out.d")
	end
	_p("")
end

function m.copyrule(cfg, toolset)
	_p("rule copy")
	_p(os.translateCommands("  command = {COPYFILE} $in $out"))
	_p("  description = Copying file $in to $out")
	_p("")
end

function m.prebuildcommandrule(cfg, toolset)
	_p("rule prebuild")
	_p("  command = $prebuildcommands")
	_p("  description = Running pre-build commands")
	_p("")
end

function m.prelinkcommandrule(cfg, toolset)
	_p("rule prelink")
	_p("  command = $prelinkcommands")
	_p("  description = Running pre-link commands")
	_p("")
end

function m.postbuildcommandrule(cfg, toolset)
	_p("rule postbuild")
	_p("  command = $postbuildcommands")
	_p("  description = Running post-build commands")
	_p("")
end

function m.customcommand(cfg, toolset)
	_p("rule custom")
	_p("  command = $customcommand")
	_p("  description = Running custom command: $customcommand")
	_p("")
end

function m.customrule(cfg, toolset, prj)
	if not prj.rules or #prj.rules == 0 then
		return
	end
	
	for _, ruleName in ipairs(prj.rules) do
		local rule = p.global.getRule(ruleName)
		if rule then
			local ruleNameEscaped = ruleName:gsub("[^%w_]", "_"):lower()
			_p("rule %s", ruleNameEscaped)
			_p("  command = $%s_command", ruleNameEscaped)
			_p("  description = $%s_description", ruleNameEscaped)
			_p("")
		end
	end
end

local function gatherDepTargets(cfg)
	local depTargets = {}
	for _, depname in ipairs(cfg.dependson) do
		local depprj = p.workspace.findproject(cfg.workspace, depname)
		if depprj then
			local depcfg = project.getconfig(depprj, cfg.buildcfg, cfg.platform)
			if depcfg then
				local depTarget = path.getrelative(cfg.workspace.location, depcfg.buildtarget.directory) .. "/" .. depcfg.buildtarget.name
				table.insert(depTargets, depTarget)
			end
		end
	end
	return depTargets
end

function m.buildDependsOnTarget(cfg)
	if not cfg.dependson or #cfg.dependson == 0 then
		return nil
	end
	
	local depTargets = gatherDepTargets(cfg)
	
	if #depTargets == 0 then
		return nil
	end
	
	return depTargets
end

function m.configurations(prj)
	for cfg in project.eachconfig(prj) do
		_p("# Configuration: %s", ninja.key(cfg))
		_p("")
		
		m.configurationVariables(cfg)
		
		local depsTargets = m.buildDependsOnTarget(cfg)
		cfg._dependsOnTargets = depsTargets
		
		m.buildFiles(cfg)
		m.linkTarget(cfg)
		
		_p("")
	end
end

function m.configurationVariables(cfg)
	local toolset = ninja.gettoolset(cfg)
	
	local cflags = m.getCFlags(cfg, toolset)
	if #cflags > 0 then
		_p("cflags_%s = %s", ninja.key(cfg), table.concat(cflags, " "))
	end
	
	local cxxflags = m.getCxxFlags(cfg, toolset)
	if #cxxflags > 0 then
		_p("cxxflags_%s = %s", ninja.key(cfg), table.concat(cxxflags, " "))
	end
	
	local ldflags = m.getLdFlags(cfg, toolset)
	if #ldflags > 0 then
		_p("ldflags_%s = %s", ninja.key(cfg), table.concat(ldflags, " "))
	end
	
	local links = toolset.getlinks(cfg)
	if #links > 0 then
		local wksLinks = {}
		for _, link in ipairs(links) do
			if not path.isabsolute(link) and link:match('[/\\]') then
				local absPath = path.join(cfg.project.location, link)
				link = path.getrelative(cfg.workspace.location, absPath)
			end
			table.insert(wksLinks, link)
		end
		_p("links_%s = %s", ninja.key(cfg), table.concat(wksLinks, " "))
	end
	
	_p("objdir_%s = %s", ninja.key(cfg), project.getrelative(cfg.project, cfg.objdir))
	_p("targetdir_%s = %s", ninja.key(cfg), project.getrelative(cfg.project, cfg.buildtarget.directory))
	_p("target_%s = %s", ninja.key(cfg), cfg.buildtarget.name)
	
	_p("")
end

function m.getCFlags(cfg, toolset)
	local flags = {}
	toolset = toolset or ninja.gettoolset(cfg)
	
	local toolFlags = toolset.getcflags(cfg)
	flags = table.join(flags, toolFlags)
	
	local escaper = p.escaper(p.quote)
	local defines = toolset.getdefines(cfg.defines)
	flags = table.join(flags, defines)
	
	local undefines = toolset.getundefines(cfg.undefines)
	flags = table.join(flags, undefines)
	
	local includedirs = toolset.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(cfg)
	flags = table.join(flags, forceincludes)
	
	local buildopts = cfg.buildoptions or {}
	flags = table.join(flags, buildopts)
	p.escaper(escaper)
	
	return flags
end

function m.getFileCFlags(cfg, filecfg, toolset)
	local flags = {}

	if filecfg.cdialect and filecfg.cdialect ~= cfg.cdialect then
		local toolFlags = toolset.getcflags(filecfg)
		flags = table.join(flags, toolFlags)
	else
		local toolFlags = toolset.getcflags(cfg)
		flags = table.join(flags, toolFlags)
	end
	
	local allDefines = table.join(cfg.defines or {}, filecfg.defines or {})
	local escaper = p.escaper(p.quote)
	local defines = toolset.getdefines(allDefines)
	flags = table.join(flags, defines)

	local allUndefines = table.join(cfg.undefines or {}, filecfg.undefines or {})
	local undefines = toolset.getundefines(allUndefines)
	flags = table.join(flags, undefines)
	
	local allIncludedirs = table.join(cfg.includedirs or {}, filecfg.includedirs or {})
	local allExternalIncludedirs = table.join(cfg.externalincludedirs or {}, filecfg.externalincludedirs or {})
	local allFrameworkdirs = table.join(cfg.frameworkdirs or {}, filecfg.frameworkdirs or {})
	local allIncludedirsafter = table.join(cfg.includedirsafter or {}, filecfg.includedirsafter or {})
	local includedirs = toolset.getincludedirs(cfg, allIncludedirs, allExternalIncludedirs, allFrameworkdirs, allIncludedirsafter)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(filecfg)
	flags = table.join(flags, forceincludes)

	local allBuildopts = table.join(cfg.buildoptions or {}, filecfg.buildoptions or {})
	flags = table.join(flags, allBuildopts)

	p.escaper(escaper)
	
	return flags
end

function m.getCxxFlags(cfg, toolset)
	local flags = {}
	toolset = toolset or ninja.gettoolset(cfg)
	
	local toolFlags = toolset.getcxxflags(cfg)
	flags = table.join(flags, toolFlags)

	local escaper = p.escaper(p.quote)
	local defines = toolset.getdefines(cfg.defines)
	flags = table.join(flags, defines)

	local undefines = toolset.getundefines(cfg.undefines)
	flags = table.join(flags, undefines)
	
	local includedirs = toolset.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(cfg)
	flags = table.join(flags, forceincludes)

	local buildopts = cfg.buildoptions or {}
	flags = table.join(flags, buildopts)

	p.escaper(escaper)
	
	return flags
end

function m.getFileCxxFlags(cfg, filecfg, toolset)
	local flags = {}

	if filecfg.cppdialect and filecfg.cppdialect ~= cfg.cppdialect then
		local toolFlags = toolset.getcxxflags(filecfg)
		flags = table.join(flags, toolFlags)
	else
		local toolFlags = toolset.getcxxflags(cfg)
		flags = table.join(flags, toolFlags)
	end
	
	local allDefines = table.join(cfg.defines or {}, filecfg.defines or {})
	local escaper = p.escaper(p.quote)
	local defines = toolset.getdefines(allDefines)
	flags = table.join(flags, defines)

	local allUndefines = table.join(cfg.undefines or {}, filecfg.undefines or {})
	local undefines = toolset.getundefines(allUndefines)
	flags = table.join(flags, undefines)
	
	local allIncludedirs = table.join(cfg.includedirs or {}, filecfg.includedirs or {})
	local allExternalIncludedirs = table.join(cfg.externalincludedirs or {}, filecfg.externalincludedirs or {})
	local allFrameworkdirs = table.join(cfg.frameworkdirs or {}, filecfg.frameworkdirs or {})
	local allIncludedirsafter = table.join(cfg.includedirsafter or {}, filecfg.includedirsafter or {})
	local includedirs = toolset.getincludedirs(cfg, allIncludedirs, allExternalIncludedirs, allFrameworkdirs, allIncludedirsafter)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(filecfg)
	flags = table.join(flags, forceincludes)

	local allBuildopts = table.join(cfg.buildoptions or {}, filecfg.buildoptions or {})
	flags = table.join(flags, allBuildopts)

	p.escaper(escaper)
	
	return flags
end

function m.hasPerFileConfiguration(cfg, filecfg)
	if filecfg.defines and #filecfg.defines > 0 then
		local parentDefines = cfg.defines or {}
		if #filecfg.defines ~= #parentDefines then
			return true
		end
		for i, define in ipairs(filecfg.defines) do
			if define ~= parentDefines[i] then
				return true
			end
		end
	end
	
	if filecfg.undefines and #filecfg.undefines > 0 then
		local parentUndefines = cfg.undefines or {}
		if #filecfg.undefines ~= #parentUndefines then
			return true
		end
		for i, undefine in ipairs(filecfg.undefines) do
			if undefine ~= parentUndefines[i] then
				return true
			end
		end
	end
	
	if filecfg.buildoptions and #filecfg.buildoptions > 0 then
		local parentBuildopts = cfg.buildoptions or {}
		if #filecfg.buildoptions ~= #parentBuildopts then
			return true
		end
		for i, opt in ipairs(filecfg.buildoptions) do
			if opt ~= parentBuildopts[i] then
				return true
			end
		end
	end
	
	if filecfg.includedirs and #filecfg.includedirs > 0 then
		local parentIncludedirs = cfg.includedirs or {}
		if #filecfg.includedirs ~= #parentIncludedirs then
			return true
		end
		for i, dir in ipairs(filecfg.includedirs) do
			if dir ~= parentIncludedirs[i] then
				return true
			end
		end
	end
	
	if filecfg.externalincludedirs and #filecfg.externalincludedirs > 0 then
		local parentExternalIncludedirs = cfg.externalincludedirs or {}
		if #filecfg.externalincludedirs ~= #parentExternalIncludedirs then
			return true
		end
		for i, dir in ipairs(filecfg.externalincludedirs) do
			if dir ~= parentExternalIncludedirs[i] then
				return true
			end
		end
	end
	
	if filecfg.cdialect and filecfg.cdialect ~= cfg.cdialect then
		return true
	end
	
	if filecfg.cppdialect and filecfg.cppdialect ~= cfg.cppdialect then
		return true
	end
	
	return false
end

function m.getLdFlags(cfg, toolset)
	local flags = {}
	toolset = toolset or ninja.gettoolset(cfg)
	
	local toolFlags = toolset.getldflags(cfg)
	flags = table.join(flags, toolFlags)

	local linkopts = cfg.linkoptions or {}
	flags = table.join(flags, linkopts)
	
	local libdirs = toolset.getLibraryDirectories(cfg)
	flags = table.join(flags, libdirs)
	
	if toolset.getrunpathdirs then
		local runpathdirs = table.join(cfg.runpathdirs, config.getsiblingtargetdirs(cfg))
		local rpaths = toolset.getrunpathdirs(cfg, runpathdirs)
		flags = table.join(flags, rpaths)
	end
	
	return flags
end

function m.getPchPath(cfg)
	if not cfg.pchheader or cfg.enablepch == p.OFF then
		return nil
	end
	
	local toolset = ninja.gettoolset(cfg)
	local objdir = path.getrelative(cfg.project.location, cfg.objdir)
	
	if toolset == p.tools.msc then
		return objdir .. "/" .. path.getbasename(cfg.pchheader) .. ".pch"
	else
		local pch = toolset.getpch and toolset.getpch(cfg)
		if pch then
			return objdir .. "/" .. path.getname(pch) .. ".gch"
		else
			return objdir .. "/" .. path.getbasename(cfg.pchheader) .. ".h.gch"
		end
	end
end

function m.buildPch(cfg)
	if not cfg.pchheader or cfg.enablepch == p.OFF then
		return nil
	end
	
	local toolset = ninja.gettoolset(cfg)
	local pchPath = m.getPchPath(cfg)
	local depfile = pchPath .. ".d"
	
	if not pchPath then
		return nil
	end
	
	local implicitDeps = ""
	if cfg._dependsOnTarget then
		implicitDeps = " | " .. cfg._dependsOnTarget
	end
	
	if toolset == p.tools.msc then
		local pchSource = cfg.pchsource
		if not pchSource then
			return nil
		end
		
		local relPath = path.getrelative(cfg.workspace.location, pchSource)
		local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
		local objFile = objdir .. "/" .. path.getbasename(pchSource) .. ".obj"
		
		local wksRelPchPath = path.getrelative(cfg.workspace.location, path.join(cfg.project.location, pchPath))
		
		_p("build %s | %s: pch_%s %s%s", wksRelPchPath, objFile, cfg.toolset, relPath, implicitDeps)
		_p("  pchheader = %s", cfg.pchheader)
		_p("  objdir = %s", objdir)
		if cfg.language == "C" then
			_p("  cflags = $cflags_%s", ninja.key(cfg))
		else
			_p("  cflags = $cxxflags_%s", ninja.key(cfg))
		end
		
		return wksRelPchPath
	else
		local pch = toolset.getpch(cfg)
		local relPath
		
		if pch then
			local headerPath = path.getabsolute(path.join(cfg.project.location, pch))
			relPath = path.getrelative(cfg.workspace.location, headerPath)
		else
			relPath = cfg.pchheader
		end
		
		local wksRelPchPath = path.getrelative(cfg.workspace.location, path.join(cfg.project.location, pchPath))
		local wksRelPchDepPath = path.getrelative(cfg.workspace.location, path.join(cfg.project.location, depfile))
		
		_p("build %s | %s: pch_%s %s%s", wksRelPchPath, wksRelPchDepPath, cfg.toolset, relPath, implicitDeps)
		
		if cfg.language == "C" then
			_p("  cflags = $cflags_%s", ninja.key(cfg))
			_p("  depfile = %s", wksRelPchDepPath)
		else
			_p("  cflags = $cxxflags_%s", ninja.key(cfg))
			_p("  depfile = %s", wksRelPchDepPath)
		end
		
		return wksRelPchPath
	end
end

function m.buildFiles(cfg)
	local tr = project.getsourcetree(cfg.project)
	local objList = {}
	local copyList = {}
	local pchFile = m.buildPch(cfg)
	
	local prebuildTarget = m.buildPreBuildEvents(cfg)
	cfg._hasPrebuild = (prebuildTarget ~= nil)
	
	if not cfg.project._ninja_output_tracking then
		cfg.project._ninja_output_tracking = {}
	end
	local outputTracking = cfg.project._ninja_output_tracking
	
	if not cfg._customRuleOutputs then
		cfg._customRuleOutputs = {}
	end
	
	tree.traverse(tr, {
		onleaf = function(node, depth)
			local filecfg = fileconfig.getconfig(node, cfg)
			if filecfg then
				if filecfg.buildaction == "None" or filecfg.excludefrombuild then
					return
				end
				
				local toolset = ninja.gettoolset(cfg)
				if not (cfg.pchsource and node.abspath == cfg.pchsource and toolset == p.tools.msc) then
					local customRuleFile = m.checkCustomRuleFile(cfg, node, filecfg, outputTracking)
					if customRuleFile and customRuleFile.outputs then
						for _, output in ipairs(customRuleFile.outputs) do
							table.insert(cfg._customRuleOutputs, output)
							
							if path.islinkable(output) then
								table.insert(objList, output)
							end
						end
					elseif filecfg.buildcommands and #filecfg.buildcommands > 0 and
					   filecfg.buildoutputs and #filecfg.buildoutputs > 0 then
						local outputs = m.buildCustomFile(cfg, node, filecfg, outputTracking)
						if outputs then
							for _, output in ipairs(outputs) do
								table.insert(cfg._customRuleOutputs, output)
							end
							
							local shouldLink = true
							if filecfg.linkbuildoutputs ~= nil then
								shouldLink = filecfg.linkbuildoutputs
							end
							
							if shouldLink then
								for _, output in ipairs(outputs) do
									if path.islinkable(output) then
										table.insert(objList, output)
									end
								end
							end
						end
					end
				end
			end
		end
	}, false, 1)
	
	tree.traverse(tr, {
		onleaf = function(node, depth)
			local filecfg = fileconfig.getconfig(node, cfg)
			if filecfg then
				if filecfg.buildaction == "None" or filecfg.excludefrombuild then
					return
				end
				
				local toolset = ninja.gettoolset(cfg)
				if not (cfg.pchsource and node.abspath == cfg.pchsource and toolset == p.tools.msc) then
					local rule = p.global.getRuleForFile(node.abspath, cfg.project.rules or {})
					local hasCustomBuild = filecfg.buildcommands and #filecfg.buildcommands > 0 and
					                       filecfg.buildoutputs and #filecfg.buildoutputs > 0
					
					if not rule and not hasCustomBuild then
						if filecfg.buildaction == "Copy" then
							local output = m.buildCopyFile(cfg, node, filecfg)
							if output then
								table.insert(copyList, output)
								
								local shouldLink = (filecfg.linkbuildoutputs ~= false)
								if shouldLink and path.islinkable(output) then
									table.insert(objList, output)
								end
							end
						else
							local objFile = m.objectFile(cfg, node, filecfg)
							if objFile then
								table.insert(objList, objFile)
								m.buildFile(cfg, node, filecfg, objFile, pchFile, prebuildTarget)
							end
						end
					end
				end
			end
		end
	}, false, 1)

	-- If there is a PCH and this is MSVC, make sure the PCH obj is in the object list
	if pchFile and ninja.gettoolset(cfg) == p.tools.msc then
		local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
		local pchObjFile = objdir .. "/" .. path.getbasename(cfg.pchsource) .. ".obj"
		table.insert(objList, 1, pchObjFile)
	end
	
	cfg._objectFiles = objList
	cfg._copyFiles = copyList
end

function m.objectFile(cfg, node, filecfg)
	local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
	local ext = path.getextension(node.abspath):lower()
	
	local shouldCompile = false
	
	if filecfg and filecfg.buildaction == "Compile" then
		shouldCompile = true
	elseif filecfg and filecfg.compileas and filecfg.compileas ~= "Default" then
		if p.languages.isc(filecfg.compileas) or p.languages.iscpp(filecfg.compileas) then
			shouldCompile = true
		end
	else
		if path.iscppfile(node.abspath) or path.iscfile(node.abspath) then
			shouldCompile = true
		end
	end
	
	if shouldCompile then
		local objname = filecfg.objname or path.getbasename(node.abspath)
		local toolset = ninja.gettoolset(cfg)
		local objext = toolset.gettooloutputext("cc")
		return objdir .. "/" .. objname .. objext
	end
	
	return nil
end

function m.buildFile(cfg, node, filecfg, objFile, pchFile, prebuildTarget)
	local ext = path.getextension(node.abspath):lower()
	local rule = nil
	local flags = ""
	local extraFlags = {}
	local toolset = ninja.gettoolset(cfg)
	local hasPerFileConfig = m.hasPerFileConfiguration(cfg, filecfg)
	
	if filecfg and filecfg.compileas and filecfg.compileas ~= "Default" then
		if p.languages.isc(filecfg.compileas) then
			rule = "cc"
			flags = "cflags_" .. ninja.key(cfg)
			
			if toolset.shared and toolset.shared.compileas and toolset.shared.compileas["C"] then
				table.insert(extraFlags, toolset.shared.compileas["C"])
			end
		elseif p.languages.iscpp(filecfg.compileas) then
			rule = "cxx"
			flags = "cxxflags_" .. ninja.key(cfg)
			
			if toolset.shared and toolset.shared.compileas and toolset.shared.compileas["C++"] then
				table.insert(extraFlags, toolset.shared.compileas["C++"])
			end
		end
	elseif filecfg and filecfg.buildaction == "Compile" then
		if p.languages.isc(cfg.language) then
			rule = "cc"
			flags = "cflags_" .. ninja.key(cfg)
		else
			rule = "cxx"
			flags = "cxxflags_" .. ninja.key(cfg)
		end
	else
		if path.iscfile(node.abspath) then
			rule = "cc"
			flags = "cflags_" .. ninja.key(cfg)
		elseif path.iscppfile(node.abspath) then
			rule = "cxx"
			flags = "cxxflags_" .. ninja.key(cfg)
		end
	end
	
	if rule then
		local relPath = path.getrelative(cfg.workspace.location, node.abspath)
		local implicitDeps = ""
		
		local usePch = cfg.pchheader and cfg.enablepch ~= p.OFF and (not filecfg or filecfg.enablepch ~= p.OFF)
		if pchFile and usePch then
			implicitDeps = implicitDeps .. " | " .. pchFile
		end
		
		if prebuildTarget then
			if implicitDeps == "" then
				implicitDeps = " |"
			end
			implicitDeps = implicitDeps .. " " .. prebuildTarget
		end
		
		if cfg._customRuleOutputs and #cfg._customRuleOutputs > 0 then
			if implicitDeps == "" then
				implicitDeps = " |"
			end
			for _, output in ipairs(cfg._customRuleOutputs) do
				implicitDeps = implicitDeps .. " " .. output
			end
		end
		
		if not prebuildTarget and (not cfg._customRuleOutputs or #cfg._customRuleOutputs == 0) then
			-- Use pre-computed dependency targets if available, otherwise compute them inline
			local depTargets = cfg._dependsOnTargets
			if not depTargets and cfg.dependson and #cfg.dependson > 0 then
				depTargets = gatherDepTargets(cfg)
			end
			
			if depTargets then
				if implicitDeps == "" then
					implicitDeps = " |"
				end
				for _, depTarget in ipairs(depTargets) do
					implicitDeps = implicitDeps .. " " .. depTarget
				end
			end
		end
		
		_p("build %s: %s_%s %s%s", objFile, rule, cfg.toolset, relPath, implicitDeps)
		
		if usePch then
			if toolset == p.tools.msc then
				table.insert(extraFlags, "/Yu" .. cfg.pchheader)
				local pchPath = m.getPchPath(cfg)
				if pchPath then
					table.insert(extraFlags, "/Fp" .. pchPath)
				end
			else
				local pch = toolset.getpch(cfg)
				if pch then
					local objdir = path.getrelative(cfg.project.location, cfg.objdir)
					local pchPlaceholder = objdir .. "/" .. path.getname(pch)
					table.insert(extraFlags, "-include " .. pchPlaceholder)
				end
			end
		end
		
		-- If the file has per-file configuration, generate flags directly rather than using variables
		if hasPerFileConfig then
			local fileFlags = {}
			if rule == "cc" then
				fileFlags = m.getFileCFlags(cfg, filecfg, toolset)
			else
				fileFlags = m.getFileCxxFlags(cfg, filecfg, toolset)
			end
			
			table.insertflat(fileFlags, extraFlags)
			
			if #fileFlags > 0 then
				if rule == "cc" then
					_p("  cflags = %s", table.concat(fileFlags, " "))
				else
					_p("  cxxflags = %s", table.concat(fileFlags, " "))
				end
			end
		else
			if rule == "cc" then
				if #extraFlags > 0 then
					_p("  cflags = $%s %s", flags, table.concat(extraFlags, " "))
				else
					_p("  cflags = $%s", flags)
				end
			else
				if #extraFlags > 0 then
					_p("  cxxflags = $%s %s", flags, table.concat(extraFlags, " "))
				else
					_p("  cxxflags = $%s", flags)
				end
			end
		end
	end
end

local function trackOutput(outputTracking, cfg, outputs)
	local alreadyGenerated = false
	if outputTracking then
		for _, output in ipairs(outputs) do
			if outputTracking[output] then
				alreadyGenerated = true
				break
			end
		end
	end

	if alreadyGenerated then
		return true
	end

	if outputTracking then
		for _, output in ipairs(outputs) do
			outputTracking[output] = outputTracking[output] or {}
			table.insert(outputTracking[output], ninja.key(cfg))
		end
	end

	return alreadyGenerated
end

function m.checkCustomRuleFile(cfg, node, filecfg, outputTracking)
	if not cfg.project.rules or #cfg.project.rules == 0 then
		return nil
	end
	
	local rule = p.global.getRuleForFile(node.abspath, cfg.project.rules)
	if not rule then
		return nil
	end
	
	local environ = table.shallowcopy(filecfg.environ)
	
	if rule.propertydefinition then
		p.rule.prepareEnvironment(rule, environ, cfg)
		p.rule.prepareEnvironment(rule, environ, filecfg)
	end
	
	local shadowContext = p.context.extent(rule, environ)
	
	local buildoutputs = shadowContext.buildoutputs
	local buildmessage = shadowContext.buildmessage
	local buildcommands = shadowContext.buildcommands
	local buildinputs = shadowContext.buildinputs
	
	if not buildoutputs or #buildoutputs == 0 then
		return nil
	end
	
	local outputs = {}
	for _, output in ipairs(buildoutputs) do
		local absOutput = path.getabsolute(path.join(cfg.project.basedir, output))
		local relOutput = path.getrelative(cfg.workspace.location, absOutput)
		table.insert(outputs, relOutput)
	end
	
	local alreadyGenerated = trackOutput(outputTracking, cfg, outputs)
	if alreadyGenerated then
		return { outputs = outputs }
	end
	
	local relPath = path.getrelative(cfg.workspace.location, node.abspath)
	local ruleNameEscaped = rule.name:gsub("[^%w_]", "_"):lower()
	
	local deps = ""
	if buildinputs and #buildinputs > 0 then
		local depList = {}
		for _, dep in ipairs(buildinputs) do
			local absDep = path.getabsolute(path.join(cfg.project.basedir, dep))
			local relDep = path.getrelative(cfg.workspace.location, absDep)
			table.insert(depList, relDep)
		end
		if #depList > 0 then
			deps = " | " .. table.concat(depList, " ")
		end
	end
	
	if cfg._dependsOnTarget and not cfg._hasPrebuild then
		if deps == "" then
			deps = " |"
		end
		deps = deps .. " " .. cfg._dependsOnTarget
	end
	
	local commands = {}
	if buildcommands then
		local translatedCommands = os.translateCommandsAndPaths(buildcommands, cfg.project.basedir, cfg.project.location)
		for _, cmd in ipairs(translatedCommands) do
			table.insert(commands, cmd)
		end
	end
	
	local commandStr = table.concat(commands, " && ")
	
	local messageStr = buildmessage or ("Processing " .. node.name)
	
	_p("build %s: %s %s%s", table.concat(outputs, " "), ruleNameEscaped, relPath, deps)
	_p("  %s_command = %s", ruleNameEscaped, commandStr)
	_p("  %s_description = %s", ruleNameEscaped, messageStr)
	
	return { outputs = outputs }
end

local function touchCommand(file)
	return os.translateCommands("{TOUCH} \"" .. file .. "\"")
end

local function buildCommandString(cmds, message, touchFile)
	local shell = os.shell()

	local allcmds = table.deepcopy(cmds)
	if message then
		table.insert(allcmds, 1, os.translateCommands('{ECHO} "' .. message .. '"'))
	end

	if touchFile then
		table.insert(allcmds, touchCommand(touchFile))
	end

	if shell == "posix" then
		return "sh -c '" .. table.concat(allcmds, " && ") .. "'"
	elseif shell == "cmd" then
		local joined = table.concat(allcmds, " && ")
		-- Escape double quotes
		joined = joined:gsub('"', '\\"')
		return "cmd /C \"" .. joined .. "\""
	else
		return table.concat(allcmds, " && ")
	end
end

function m.buildCustomFile(cfg, node, filecfg, outputTracking)
	if not filecfg.buildcommands or #filecfg.buildcommands == 0 then
		return nil
	end
	
	if not filecfg.buildoutputs or #filecfg.buildoutputs == 0 then
		return nil
	end
	
	local relPath = path.getrelative(cfg.workspace.location, node.abspath)
	
	local outputs = {}
	for _, output in ipairs(filecfg.buildoutputs) do
		local absOutput = path.getabsolute(path.join(cfg.project.basedir, output))
		local relOutput = path.getrelative(cfg.workspace.location, absOutput)
		table.insert(outputs, relOutput)
	end
	
	local alreadyGenerated = trackOutput(outputTracking, cfg, outputs)
	if alreadyGenerated then
		return outputs
	end
	
	local deps = ""
	if filecfg.buildinputs and #filecfg.buildinputs > 0 then
		local depList = {}
		for _, dep in ipairs(filecfg.buildinputs) do
			local absDep = path.getabsolute(path.join(cfg.project.basedir, dep))
			local relDep = path.getrelative(cfg.workspace.location, absDep)
			table.insert(depList, relDep)
		end
		if #depList > 0 then
			deps = " | " .. table.concat(depList, " ")
		end
	end
	
	-- Add dependson targets if they exist and no prebuild (prebuild already has the dep)
	-- Use pre-computed dependency targets if available, otherwise compute them inline
	local hasPrebuild = cfg._hasPrebuild
	if not hasPrebuild then
		hasPrebuild = #cfg.prebuildcommands > 0 or cfg.prebuildmessage
	end
	
	if not hasPrebuild then
		local depTargets = cfg._dependsOnTargets
		if not depTargets and cfg.dependson and #cfg.dependson > 0 then
			depTargets = gatherDepTargets(cfg)
		end
		
		if depTargets then
			if deps == "" then
				deps = " |"
			end
			for _, depTarget in ipairs(depTargets) do
				deps = deps .. " " .. depTarget
			end
		end
	end
	
	local commands = os.translateCommandsAndPaths(filecfg.buildcommands, cfg.project.basedir, cfg.project.location)
	local cmdStr = buildCommandString(commands, nil, nil)
	
	_p("build %s: custom %s%s", table.concat(outputs, " "), relPath, deps)
	_p("  customcommand = %s", cmdStr)
	
	if filecfg.buildmessage then
		_p("  description = %s", filecfg.buildmessage)
	end
	
	return outputs
end

function m.buildCopyFile(cfg, node, filecfg)
	local relPath = path.getrelative(cfg.workspace.location, node.abspath)
	local targetdir = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory)
	local output = targetdir .. "/" .. node.name
	
	_p("build %s: copy %s", output, relPath)
	
	return output
end

function m.linkTarget(cfg)
	if not cfg._objectFiles or #cfg._objectFiles == 0 then
		return
	end
	
	local toolset = ninja.gettoolset(cfg)
	local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
	
	local prelinkTarget = m.buildPreLinkEvents(cfg, cfg._objectFiles)
	
	local rule = iif(cfg.kind == p.STATICLIB, "ar", "link")
	
	local deps = config.getlinks(cfg, "siblings", "fullpath")
	local implicitDeps = ""
	if #deps > 0 then
		local wksRelDeps = {}
		for _, dep in ipairs(deps) do
			local absPath = path.join(cfg.project.location, dep)
			local relDep = path.getrelative(cfg.workspace.location, absPath)
			table.insert(wksRelDeps, relDep)
		end
		implicitDeps = " | " .. table.concat(wksRelDeps, " ")
	end
	
	-- Use pre-computed dependency targets if available, otherwise compute them inline
	local depTargets = cfg._dependsOnTargets
	if not depTargets and cfg.dependson and #cfg.dependson > 0 then
		depTargets = gatherDepTargets(cfg)
	end
	
	if depTargets then
		if implicitDeps == "" then
			implicitDeps = " |"
		end
		for _, depTarget in ipairs(depTargets) do
			implicitDeps = implicitDeps .. " " .. depTarget
		end
	end
	
	if prelinkTarget then
		if implicitDeps == "" then
			implicitDeps = " |"
		end
		implicitDeps = implicitDeps .. " " .. prelinkTarget
	end
	
	if cfg._copyFiles and #cfg._copyFiles > 0 then
		for _, copyFile in ipairs(cfg._copyFiles) do
			if not table.contains(cfg._objectFiles, copyFile) then
				if implicitDeps == "" then
					implicitDeps = " |"
				end
				implicitDeps = implicitDeps .. " " .. copyFile
			end
		end
	end
	
	local hasPostBuild = #cfg.postbuildcommands > 0 or cfg.postbuildmessage

	local implicitoutputs = {}

	-- If this target is a shared library on Windows with useimportlib not set to Off, add an implicit output
	-- for the .lib file
	-- If this is on windows and building a shared library, emit a exp file as an implicit output
	if cfg.system == p.WINDOWS and cfg.kind == p.SHAREDLIB then
		local expFileName = cfg.buildtarget.name:gsub("%..-$", "") .. ".exp"
		if expFileName then
			local expFilePath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. expFileName
			table.insert(implicitoutputs, expFilePath)
		end

		if cfg.useimportlib ~= p.OFF then
			local importLibName = cfg.buildtarget.name:gsub("%..-$", "") .. ".lib"
			if importLibName then
				local importLibPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. importLibName
				table.insert(implicitoutputs, importLibPath)
			end
		end
	end
	
	if #implicitoutputs > 0 then
		_p("build %s | %s: %s_%s %s%s", targetPath, table.concat(implicitoutputs, " "), rule, cfg.toolset, table.concat(cfg._objectFiles, " "), implicitDeps)
	else
		_p("build %s: %s_%s %s%s", targetPath, rule, cfg.toolset, table.concat(cfg._objectFiles, " "), implicitDeps)
	end
	
	if cfg.kind ~= p.STATICLIB then
		_p("  ldflags = $ldflags_%s", ninja.key(cfg))
		
		local links = toolset.getlinks(cfg)
		if #links > 0 then
			_p("  links = $links_%s", ninja.key(cfg))
		end
	end
	
	if hasPostBuild then
		m.buildPostBuildEvents(cfg, targetPath)
	end
end

function m.buildPreBuildEvents(cfg)
	local hasMessage = cfg.prebuildmessage ~= nil
	local hasCommands = #cfg.prebuildcommands > 0
	
	if not hasMessage and not hasCommands then
		return nil
	end
	
	local prebuildTarget = path.getrelative(cfg.workspace.location, cfg.objdir) .. "/" .. cfg.project.name .. ".prebuild"

	local implicitDeps = ""
	if cfg._dependsOnTarget then
		implicitDeps = " | " .. cfg._dependsOnTarget
	end
	
	if hasMessage and not hasCommands then
		local cmdstr = buildCommandString({}, cfg.prebuildmessage, prebuildTarget)

		_p("build %s: prebuild%s", prebuildTarget, implicitDeps)
		_p("  prebuildcommands = %s", cmdstr)
	else
		local commands = os.translateCommandsAndPaths(cfg.prebuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdstr = buildCommandString(commands, cfg.prebuildmessage, prebuildTarget)
		_p("build %s: prebuild%s", prebuildTarget, implicitDeps)
		_p("  prebuildcommands = %s", cmdstr)
	end
	
	return prebuildTarget
end

function m.buildPreLinkEvents(cfg, objectFiles)
	local hasMessage = cfg.prelinkmessage ~= nil
	local hasCommands = #cfg.prelinkcommands > 0
	
	if not hasMessage and not hasCommands then
		return nil
	end
	
	local prelinkTarget = path.getrelative(cfg.workspace.location, cfg.objdir) .. "/" .. cfg.project.name .. ".prelinkevents"
	
	local objDeps = ""
	if objectFiles and #objectFiles > 0 then
		objDeps = " " .. table.concat(objectFiles, " ")
	end
	
	if hasMessage and not hasCommands then
		local cmdstr = buildCommandString({}, cfg.prelinkmessage, prelinkTarget)

		_p("build %s: prelink%s", prelinkTarget, objDeps)
		_p("  prelinkcommands = %s", cmdstr)
	else
		local commands = os.translateCommandsAndPaths(cfg.prelinkcommands, cfg.project.basedir, cfg.project.location)
		local cmdstr = buildCommandString(commands, cfg.prelinkmessage, prelinkTarget)

		_p("build %s: prelink%s", prelinkTarget, objDeps)
		_p("  prelinkcommands = %s", cmdstr)
	end
	
	return prelinkTarget
end

function m.buildPostBuildEvents(cfg, targetPath)
	local hasMessage = cfg.postbuildmessage ~= nil
	local hasCommands = #cfg.postbuildcommands > 0
	
	if not hasMessage and not hasCommands then
		return
	end
	
	local postbuildPhony = path.getrelative(cfg.workspace.location, cfg.objdir) .. "/" .. cfg.project.name .. ".postbuild"
	
	if hasMessage and not hasCommands then
		local cmdstr = buildCommandString({}, cfg.postbuildmessage, postbuildPhony)
		_p("build %s: postbuild | %s", postbuildPhony, targetPath)
		_p("  postbuildcommands = %s", cmdstr) 
	else
		local commands = os.translateCommandsAndPaths(cfg.postbuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdstr = buildCommandString(commands, cfg.postbuildmessage, postbuildPhony)
		_p("build %s: postbuild | %s", postbuildPhony, targetPath)
		_p("  postbuildcommands = %s", cmdstr)
	end
end

function m.buildTargets(prj)
	_p("# Build targets")
	_p("")
	
	for cfg in project.eachconfig(prj) do
		local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
		local cfgName = ninja.key(cfg)
		
		local hasPostBuild = #cfg.postbuildcommands > 0 or cfg.postbuildmessage
		if hasPostBuild then
			local postbuildTarget = path.getrelative(cfg.workspace.location, cfg.objdir) .. "/" .. cfg.project.name .. ".postbuild"
			_p("build %s: phony %s", cfgName, postbuildTarget)
		else
			_p("build %s: phony %s", cfgName, targetPath)
		end
	end
	
	_p("")
end

function m.projectPhonies(prj)
	_p("# Project phony targets")
	_p("")
	
	local firstCfg = project.getfirstconfig(prj)
	if firstCfg then
		local targetPath = path.getrelative(firstCfg.workspace.location, firstCfg.buildtarget.directory) .. "/" .. firstCfg.buildtarget.name
		
		local hasPostBuild = #firstCfg.postbuildcommands > 0 or firstCfg.postbuildmessage
		if hasPostBuild then
			local postbuildTarget = path.getrelative(firstCfg.workspace.location, firstCfg.buildtarget.directory) .. "/" .. firstCfg.project.name .. ".postbuild"
			_p("build %s: phony %s", prj.name, postbuildTarget)
		else
			_p("build %s: phony %s", prj.name, targetPath)
		end
	end
	
	_p("")
end

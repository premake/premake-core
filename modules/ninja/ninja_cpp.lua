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

-- Element tables for function overrides
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

-- Generate all ninja rules (compile, link, etc.)
function m.rules(prj)
	-- Generate rules for each configuration to handle different toolsets
	local rulesDone = {}
	
	for cfg in project.eachconfig(prj) do
		local toolset = ninja.gettoolset(cfg)
		local toolsetKey = tostring(toolset)
		
		if not rulesDone[toolsetKey] then
			m.ccrules(cfg, toolset)
			m.cxxrules(cfg, toolset)
			m.resourcerules(cfg, toolset)
			m.linkrules(cfg, toolset)
			m.pchrules(cfg, toolset)
			m.copyrules(cfg, toolset)
			m.prebuildcommandsrule(cfg, toolset)
			m.prebuildmessagerule(cfg, toolset)
			m.prelinkcommandsrule(cfg, toolset)
			m.prelinkmessagerule(cfg, toolset)
			m.postbuildcommandsrule(cfg, toolset)
			m.postbuildmessagerule(cfg, toolset)
			m.customcommand(cfg, toolset)
			m.phonies(cfg, toolset)
			
			rulesDone[toolsetKey] = true
		end
	end
end

function m.ccrules(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local ccname = toolset.gettoolname(cfg, "cc")
	_p("rule cc")

	if toolset == p.tools.msc then
		_p("  command = %s $cflags /nologo /showIncludes -c /Tc$in /Fo$out", ccname)
		_p("  deps = msvc")
	else
		_p("  command = %s $cflags -c $in -o $out", ccname)
		_p("  deps = gcc")
	end
	
	_p("  description = Compiling C source $in")
	_p("  depfile = $out.d")

	_p("")
end

function m.cxxrules(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local cxxname = toolset.gettoolname(cfg, "cxx")
	_p("rule cxx")
	
	if toolset == p.tools.msc then
		_p("  command = %s $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out", cxxname)
		_p("  deps = msvc")
	else
		_p("  command = %s $cxxflags -c $in -o $out", cxxname)
		_p("  deps = gcc")
	end

	_p("  description = Compiling C++ source $in")
	_p("  depfile = $out.d")

	_p("")
end

function m.resourcerules(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local rcname = toolset.gettoolname(cfg, "rc")

	_p("rule rc")
	
	if toolset == p.tools.msc then
		_p("  command = %s /nologo /fo$out $in $resflags", rcname)
	else
		_p("  command = %s -i $in -o $out $resflags", rcname)
	end
	
	_p("  description = Compiling resource $in")
	_p("")
end

function m.linkrules(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)

	if toolset == p.tools.msc then
		if cfg.kind == p.STATICLIB then
			local arname = toolset.gettoolname(cfg, "ar")
			_p("rule ar")
			_p("  command = %s $in /nologo -OUT:$out", arname)
			_p("  description = Archiving static library $out")
			_p("")
		else
			local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
			_p("rule link")
			_p("  command = %s $in $links /link $ldflags /nologo /out:$out", ldname)
			_p("  description = Linking target $out")
			_p("")
		end
	else
		if cfg.kind == p.STATICLIB then
			local arname = toolset.gettoolname(cfg, "ar")
			_p("rule ar")
			_p("  command = %s -rcs $out $in", arname)
			_p("  description = Archiving static library $out")
			_p("")
		else
			local ldname = toolset.gettoolname(cfg, iif(cfg.language == "C", "cc", "cxx"))
			local groups = iif(cfg.linkgroups == p.ON, { "-Wl,--start-group", "-Wl,--end-group" }, {"", ""})
			local commands = string.format("command = %s -o $out %s $in $links $ldflags %s", ldname, groups[1], groups[2]);
			
			commands = commands:gsub("^%s*(.-)%s*$", "%1")
			commands = commands:gsub("%s+", " ")

			_p("rule link")
			_p("  %s", commands)
			_p("  description = Linking target $out")
			_p("")
		end
	end
end

function m.pchrules(cfg, toolset)
	toolset = toolset or ninja.gettoolset(cfg)
	local pchname = toolset.gettoolname(cfg, cfg.language == "C" and "cc" or "cxx")

	_p("rule pch")
	if toolset == p.tools.msc then
		_p("  command = %s /Yc$pchheader /Fp$out /Fo$objdir/ $cflags $in", pchname)
		_p("  description = Generating precompiled header $pchheader")
	else
		_p("  command = %s -x c++-header $cflags $in -o $out", pchname)
		_p("  description = Generating precompiled header $in")
	end
	_p("")
end

function m.copyrules(cfg, toolset)
	_p("rule copy")
	_p("  command = cp $in $out")
	_p("  description = Copying file $in to $out")
	_p("")
end

function m.prebuildcommandsrule(cfg, toolset)
	_p("rule prebuild")
	_p("  command = $prebuildcommands")
	_p("  description = Running pre-build commands")
	_p("")
end

function m.prebuildmessagerule(cfg, toolset)
	_p("rule prebuildmessage")
	_p("  command = echo $prebuildmessage")
	_p("  description = Pre-build message: $prebuildmessage")
	_p("")
end

function m.prelinkcommandsrule(cfg, toolset)
	_p("rule prelink")
	_p("  command = $prelinkcommands")
	_p("  description = Running pre-link commands")
	_p("")
end

function m.prelinkmessagerule(cfg, toolset)
	_p("rule prelinkmessage")
	_p("  command = echo $prelinkmessage")
	_p("  description = Pre-link message: $prelinkmessage")
	_p("")
end

function m.postbuildcommandsrule(cfg, toolset)
	_p("rule postbuild")
	_p("  command = $postbuildcommands")
	_p("  description = Running post-build commands")
	_p("")
end

function m.postbuildmessagerule(cfg, toolset)
	_p("rule postbuildmessage")
	_p("  command = echo $postbuildmessage")
	_p("  description = Post-build message: $postbuildmessage")
	_p("")
end

function m.customcommand(cfg, toolset)
	_p("rule custom")
	_p("  command = $customcommand")
	_p("  description = Running custom command: $customcommand")
	_p("")
end

function m.phonies(cfg, toolset)
	_p("rule phony")
	_p("  command = :")
	_p("  description = Phony target")
	_p("")
end

function m.configurations(prj)
	for cfg in project.eachconfig(prj) do
		_p("# Configuration: %s", ninja.key(cfg))
		_p("")
		
		m.configurationVariables(cfg)
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
		-- Convert any relative paths to workspace-relative
		local wksLinks = {}
		for _, link in ipairs(links) do
			if link:match("^%.%.") or (not link:match("^[/-]")) then
				-- Relative path - convert from project-relative to workspace-relative
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
	
	local defines = toolset.getdefines(cfg.defines)
	flags = table.join(flags, defines)
	
	local includedirs = toolset.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(cfg)
	flags = table.join(flags, forceincludes)
	
	return flags
end

function m.getCxxFlags(cfg, toolset)
	local flags = {}
	toolset = toolset or ninja.gettoolset(cfg)
	
	local toolFlags = toolset.getcxxflags(cfg)
	flags = table.join(flags, toolFlags)
	
	local defines = toolset.getdefines(cfg.defines)
	flags = table.join(flags, defines)
	
	local includedirs = toolset.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs)
	flags = table.join(flags, includedirs)
	
	local forceincludes = toolset.getforceincludes(cfg)
	flags = table.join(flags, forceincludes)
	
	return flags
end

function m.getLdFlags(cfg, toolset)
	local flags = {}
	toolset = toolset or ninja.gettoolset(cfg)
	
	local toolFlags = toolset.getldflags(cfg)
	flags = table.join(flags, toolFlags)
	
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
	if not cfg.pchheader or cfg.flags.NoPCH then
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
			return objdir .. "/" .. cfg.pchheader .. ".gch"
		end
	end
	
	return nil
end

function m.buildPch(cfg)
	if not cfg.pchheader or cfg.flags.NoPCH then
		return nil
	end
	
	local toolset = ninja.gettoolset(cfg)
	local pchPath = m.getPchPath(cfg)
	
	if not pchPath then
		return nil
	end
	
	if toolset == p.tools.msc then
		local pchSource = cfg.pchsource
		if pchSource then
			local relPath = path.getrelative(cfg.workspace.location, pchSource)
			local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
			local objFile = objdir .. "/" .. path.getbasename(pchSource) .. ".obj"
			
			_p("build %s: pch %s", pchPath, relPath)
			_p("  pchheader = %s", cfg.pchheader)
			_p("  objdir = %s", objdir)
			_p("  cflags = $cxxflags_%s", ninja.key(cfg))
			
			return pchPath
		end
	else
		local pch = toolset.getpch and toolset.getpch(cfg)
		local headerPath
		
		if pch then
			headerPath = path.getabsolute(path.join(cfg.project.basedir, pch))
		else
			headerPath = path.getabsolute(path.join(cfg.project.basedir, cfg.pchheader))
			if not os.isfile(headerPath) then
				for _, incdir in ipairs(cfg.includedirs) do
					local testPath = path.getabsolute(path.join(incdir, cfg.pchheader))
					if os.isfile(testPath) then
						headerPath = testPath
						break
					end
				end
			end
		end
		
		local relPath = path.getrelative(cfg.project.location, headerPath)
		
		_p("build %s: pch %s", pchPath, relPath)
		
		if cfg.language == "C" then
			_p("  cflags = $cflags_%s", ninja.key(cfg))
		else
			_p("  cflags = $cxxflags_%s", ninja.key(cfg))
		end
		
		return pchPath
	end
	
	return nil
end

function m.buildFiles(cfg)
	local tr = project.getsourcetree(cfg.project)
	local objList = {}
	local pchFile = m.buildPch(cfg)
	
	-- Build prebuild events first
	local prebuildTarget = m.buildPreBuildEvents(cfg)
	
	tree.traverse(tr, {
		onleaf = function(node, depth)
			local filecfg = fileconfig.getconfig(node, cfg)
			if filecfg and not filecfg.flags.ExcludeFromBuild then
				local toolset = ninja.gettoolset(cfg)
				if not (cfg.pchsource and node.abspath == cfg.pchsource and toolset == p.tools.msc) then
					-- Check if this file has custom build commands
					if filecfg.buildcommands and #filecfg.buildcommands > 0 and
					   filecfg.buildoutputs and #filecfg.buildoutputs > 0 then
						local outputs = m.buildCustomFile(cfg, node, filecfg)
						if outputs then
							for _, output in ipairs(outputs) do
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
	}, false, 1)
	
	cfg._objectFiles = objList
end

function m.objectFile(cfg, node, filecfg)
	local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
	local ext = path.getextension(node.abspath):lower()
	
	if path.iscppfile(node.abspath) or path.iscfile(node.abspath) then
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
	
	if path.iscfile(node.abspath) then
		rule = "cc"
		flags = "cflags_" .. ninja.key(cfg)
	elseif path.iscppfile(node.abspath) then
		rule = "cxx"
		flags = "cxxflags_" .. ninja.key(cfg)
	end
	
	if rule then
		local relPath = path.getrelative(cfg.workspace.location, node.abspath)
		local implicitDeps = ""
		
		if pchFile and not filecfg.flags.NoPCH then
			implicitDeps = implicitDeps .. " | " .. pchFile
		end
		
		if prebuildTarget then
			if implicitDeps == "" then
				implicitDeps = " |"
			end
			implicitDeps = implicitDeps .. " " .. prebuildTarget
		end
		
		_p("build %s: %s %s%s", objFile, rule, relPath, implicitDeps)
		
		if rule == "cc" then
			_p("  cflags = $%s", flags)
		else
			_p("  cxxflags = $%s", flags)
		end
	end
end

function m.buildCustomFile(cfg, node, filecfg)
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
	
	local commands = os.translateCommandsAndPaths(filecfg.buildcommands, cfg.project.basedir, cfg.project.location)
	local cmdStr = table.concat(commands, " && ")
	
	_p("build %s: custom %s%s", table.concat(outputs, " "), relPath, deps)
	_p("  customcommand = %s", cmdStr)
	
	if filecfg.buildmessage then
		_p("  description = %s", filecfg.buildmessage)
	end
	
	return outputs
end

function m.linkTarget(cfg)
	if not cfg._objectFiles or #cfg._objectFiles == 0 then
		return
	end
	
	local toolset = ninja.gettoolset(cfg)
	local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
	
	local prelinkTarget = m.buildPreLinkEvents(cfg)
	
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
	
	if prelinkTarget then
		if implicitDeps == "" then
			implicitDeps = " |"
		end
		implicitDeps = implicitDeps .. " " .. prelinkTarget
	end
	
	local hasPostBuild = #cfg.postbuildcommands > 0 or cfg.postbuildmessage
	local linkTargetName = targetPath
	
	if hasPostBuild then
		linkTargetName = targetPath .. ".link"
	end
	
	_p("build %s: %s %s%s", linkTargetName, rule, table.concat(cfg._objectFiles, " "), implicitDeps)
	
	if cfg.kind ~= p.STATICLIB then
		_p("  ldflags = $ldflags_%s", ninja.key(cfg))
		
		local links = toolset.getlinks(cfg)
		if #links > 0 then
			_p("  links = $links_%s", ninja.key(cfg))
		end
	end
	
	if hasPostBuild then
		m.buildPostBuildEvents(cfg, linkTargetName, targetPath)
	end
end

function m.buildPreBuildEvents(cfg)
	local hasMessage = cfg.prebuildmessage ~= nil
	local hasCommands = #cfg.prebuildcommands > 0
	
	if not hasMessage and not hasCommands then
		return nil
	end
	
	local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
	local prebuildTarget = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.project.name .. ".prebuild"
	
	if hasMessage and not hasCommands then
		_p("build %s: prebuildmessage", prebuildTarget)
		_p("  prebuildmessage = %s", cfg.prebuildmessage)
	elseif hasCommands and not hasMessage then
		local commands = os.translateCommandsAndPaths(cfg.prebuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = table.concat(commands, " && ")
		_p("build %s: prebuild", prebuildTarget)
		_p("  prebuildcommands = %s", cmdStr)
	else
		local commands = os.translateCommandsAndPaths(cfg.prebuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = "echo " .. ninja.esc(cfg.prebuildmessage) .. " && " .. table.concat(commands, " && ")
		_p("build %s: prebuild", prebuildTarget)
		_p("  prebuildcommands = %s", cmdStr)
	end
	
	return prebuildTarget
end

function m.buildPreLinkEvents(cfg)
	local hasMessage = cfg.prelinkmessage ~= nil
	local hasCommands = #cfg.prelinkcommands > 0
	
	if not hasMessage and not hasCommands then
		return nil
	end
	
	local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
	local prelinkTarget = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.project.name .. ".prelinkevents"
	
	if hasMessage and not hasCommands then
		_p("build %s: prelinkmessage", prelinkTarget)
		_p("  prelinkmessage = %s", cfg.prelinkmessage)
	elseif hasCommands and not hasMessage then
		local commands = os.translateCommandsAndPaths(cfg.prelinkcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = table.concat(commands, " && ")
		_p("build %s: prelink", prelinkTarget)
		_p("  prelinkcommands = %s", cmdStr)
	else
		local commands = os.translateCommandsAndPaths(cfg.prelinkcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = "echo " .. ninja.esc(cfg.prelinkmessage) .. " && " .. table.concat(commands, " && ")
		_p("build %s: prelink", prelinkTarget)
		_p("  prelinkcommands = %s", cmdStr)
	end
	
	return prelinkTarget
end

function m.buildPostBuildEvents(cfg, linkTarget, finalTarget)
	local hasMessage = cfg.postbuildmessage ~= nil
	local hasCommands = #cfg.postbuildcommands > 0
	
	if not hasMessage and not hasCommands then
		return
	end
	
	if hasMessage and not hasCommands then
		_p("build %s: postbuildmessage %s", finalTarget, linkTarget)
		_p("  postbuildmessage = %s", cfg.postbuildmessage)
	elseif hasCommands and not hasMessage then
		local commands = os.translateCommandsAndPaths(cfg.postbuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = table.concat(commands, " && ")
		_p("build %s: postbuild %s", finalTarget, linkTarget)
		_p("  postbuildcommands = %s", cmdStr)
	else
		local commands = os.translateCommandsAndPaths(cfg.postbuildcommands, cfg.project.basedir, cfg.project.location)
		local cmdStr = "echo " .. ninja.esc(cfg.postbuildmessage) .. " && " .. table.concat(commands, " && ")
		_p("build %s: postbuild %s", finalTarget, linkTarget)
		_p("  postbuildcommands = %s", cmdStr)
	end
end

function m.buildTargets(prj)
	_p("# Build targets")
	_p("")
	
	for cfg in project.eachconfig(prj) do
		local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
		local cfgName = ninja.key(cfg)
		
		_p("build %s: phony %s", cfgName, targetPath)
	end
	
	_p("")
end

function m.projectPhonies(prj)
	_p("# Project phony targets")
	_p("")
	
	local firstCfg = project.getfirstconfig(prj)
	if firstCfg then
		local targetPath = path.getrelative(firstCfg.workspace.location, firstCfg.buildtarget.directory) .. "/" .. firstCfg.buildtarget.name
		_p("build %s: phony %s", prj.name, targetPath)
	end
	
	_p("")
	
	for cfg in project.eachconfig(prj) do
		local cfgName = ninja.key(cfg)
		local targetPath = path.getrelative(cfg.workspace.location, cfg.buildtarget.directory) .. "/" .. cfg.buildtarget.name
		local toolset = ninja.gettoolset(cfg)
		
		local filesToClean = {}
		if cfg._objectFiles then
			for _, obj in ipairs(cfg._objectFiles) do
				table.insert(filesToClean, obj)
				
				if toolset ~= p.tools.msc then
					table.insert(filesToClean, obj .. ".d")
				end
			end
		end
		
		table.insert(filesToClean, targetPath)
		
		local removeCmd = iif(toolset == p.tools.msc, "del /f /q", "rm -f")
		
		_p("build clean_%s: phony", cfgName)
		if #filesToClean > 0 then
			_p("  command = %s %s", removeCmd, table.concat(filesToClean, " "))
		end
	end
	
	_p("")
	
	local cleanTargets = {}
	for cfg in project.eachconfig(prj) do
		table.insert(cleanTargets, "clean_" .. ninja.key(cfg))
	end
	
	_p("build clean_%s: phony %s", prj.name, table.concat(cleanTargets, " "))
	
	_p("")
end

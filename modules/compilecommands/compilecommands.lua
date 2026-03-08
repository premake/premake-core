--
-- compile_commands.lua
-- Generate compile_commands.json files for C/C++ projects.
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

local p = premake

p.modules.compilecommands = {}
p.modules.compilecommands._VERSION = p._VERSION

local m = p.modules.compilecommands 


function m.esc(value)
	-- Escape characters that are special in JSON strings
	value = value:gsub('\\', '\\\\')
	value = value:gsub('"', '\\"')
	value = value:gsub('\n', '\\n')
	value = value:gsub('\r', '\\r')
	value = value:gsub('\t', '\\t')
	return value
end


m.languages = {
	"C",
	"C++",
}


local implicitincludecache = {}


local function getstructuredimplicitincludedirs(toolset, cfg, tool)
	local toolname = toolset.gettoolname(cfg, tool)
	local cachekey = toolname .. "_" .. (cfg.cdialect or "") .. "_" .. (cfg.cppdialect or "")
	if implicitincludecache[cachekey] then
		return implicitincludecache[cachekey]
	end

	local result = toolset.getstructuredimplicitincludedirs(cfg, toolname, iif(toolname == "cc", "C", "C++"))
	implicitincludecache[cachekey] = result
	return result
end


function m.gettoolset(cfg)
	local default = p.action.current().toolset
	local toolset, version = p.tools.canonical(cfg.toolset or default)
	if not toolset then
		error("No toolset found for '" .. tostring(cfg.toolset) .. "'")
	end
	return toolset
end


function m.getflags(cfg, toolset, fcfg, tool)
	local flags = {}
	toolset = toolset or m.gettoolset(cfg)

	if tool == "cc" then
		if fcfg and fcfg.cdialect and fcfg.cdialect ~= cfg.cdialect then
			local toolflags = toolset.getcflags(fcfg)
			flags = table.join(flags, toolflags)
		else
			local toolflags = toolset.getcflags(cfg)
			flags = table.join(flags, toolflags)
		end
	elseif tool == "cxx" then
		if fcfg and fcfg.cppdialect and fcfg.cppdialect ~= cfg.cppdialect then
			local toolflags = toolset.getcxxflags(fcfg)
			flags = table.join(flags, toolflags)
		else
			local toolflags = toolset.getcxxflags(cfg)
			flags = table.join(flags, toolflags)
		end
	else
		error("Unsupported tool '" .. tool .. "' for getting flags")
	end

	-- Handle defines
	local defines = cfg.defines or {}
	if fcfg and fcfg.defines then
		defines = table.join(defines, fcfg.defines)
	end

	-- Handle undefines
	local undefines = cfg.undefines or {}
	if fcfg and fcfg.undefines then
		undefines = table.join(undefines, fcfg.undefines)
	end

	-- Include Directories
	local includedirs = cfg.includedirs or {}
	if fcfg and fcfg.includedirs then
		includedirs = table.join(includedirs, fcfg.includedirs)
	end

	-- External Include Directories
	local externalincludedirs = cfg.externalincludedirs or {}
	if fcfg and fcfg.externalincludedirs then
		externalincludedirs = table.join(externalincludedirs, fcfg.externalincludedirs)
	end

	-- Framework directories
	local frameworkdirs = cfg.frameworkdirs or {}
	if fcfg and fcfg.frameworkdirs then
		frameworkdirs = table.join(frameworkdirs, fcfg.frameworkdirs)
	end

	-- Include Dirs After
	local includedirsafter = cfg.includedirsafter or {}
	if fcfg and fcfg.includedirsafter then
		includedirsafter = table.join(includedirsafter, fcfg.includedirsafter)
	end

	-- Build options
	local buildoptions = cfg.buildoptions or {}
	if fcfg and fcfg.buildoptions then
		buildoptions = table.join(buildoptions, fcfg.buildoptions)
	end

	local implicitincludedirs = getstructuredimplicitincludedirs(toolset, fcfg or cfg, tool)
	local explicitincludedirs = toolset.getstructuredincludedirs(cfg, includedirs, externalincludedirs, frameworkdirs, includedirsafter)
	local allincludedirs = table.join(explicitincludedirs, implicitincludedirs)
	local allincludedirflags = table.flatten(table.translate(allincludedirs, function(kv)
		return {kv.flag, kv.value}
	end))
	-- 

	-- Compile flags and join together
	flags = table.join(flags,
						toolset.getdefines(defines),
						toolset.getundefines(undefines),
						allincludedirflags,
						toolset.getforceincludes(fcfg or cfg),
						buildoptions)

	return flags
end


function m.getcompilecommandsarguments(cfg, file, fcfg)
	if not fcfg then
		fcfg = cfg
	end

	-- Check if the buildaction is set to "None", which indicates that the file should not be compiled
	if fcfg.buildaction == "None" then
		return nil
	end

	local toolkey = (function()
		if p.languages.isc(fcfg.compileas) then
			return "cc"
		elseif p.languages.iscpp(fcfg.compileas) then
			return "cxx"
		elseif path.iscfile(file) then
			return "cc"
		elseif path.iscppfile(file) then
			return "cxx"
		else
			return nil
		end
	end)()

	if not toolkey then
		return nil
	end

	local toolset = m.gettoolset(cfg)
	local toolname = toolset.gettoolname(fcfg, toolkey)
	local args = m.getflags(cfg, toolset, fcfg, toolkey)

	return table.join({ toolname }, args, { file })
end


function m.getobjectfile(cfg, file, filecfg)
	local objdir = path.getrelative(cfg.workspace.location, cfg.objdir)
	local ext = path.getextension(file.abspath):lower()
	
	local shouldCompile = false
	
	if filecfg and filecfg.buildaction == "Compile" then
		shouldCompile = true
	elseif filecfg and filecfg.compileas and filecfg.compileas ~= "Default" then
		if p.languages.isc(filecfg.compileas) or p.languages.iscpp(filecfg.compileas) then
			shouldCompile = true
		end
	else
		if path.iscppfile(file.abspath) or path.iscfile(file.abspath) then
			shouldCompile = true
		end
	end
	
	if shouldCompile then
		local objname = filecfg.objname or path.getbasename(file.abspath)
		local toolset = m.gettoolset(cfg)
		local objext = toolset.gettooloutputext("cc")
		return objdir .. "/" .. objname .. objext
	end
	
	return nil
end


function m.generate(wks, platform, buildcfg)
	-- For each project in the workspace, for each file in the project, generate a compile command entry
	-- Each entry contains:
	-- 1. directory -- working directory for compilation
	-- 2. file -- the source file being compiled
	-- 3. arguments -- An array of command line arguments used to compile the file, including the compiler executable and all flags
	-- 4. output -- the path to the output file generated by the compilation

	local commands = {}

	for prj in p.workspace.eachproject(wks) do
		if not p.action.supports(prj.language) then
			p.warn("Project '%s' has unsupported language '%s', skipping", prj.name, prj.language)
			return
		end

		if not p.action.supportsToolset(prj) then
			p.warn("Project '%s' has unsupported toolset '%s', skipping", prj.name, prj.toolset)
			return
		end

		local cfg = p.project.getconfig(prj, buildcfg, platform)
		if not cfg then
			p.error("No configuration found for project '%s' with build configuration '%s' and platform '%s'", prj.name, buildcfg, platform)
			return
		end
    
    	p.oven.assignObjectSequences(prj)

		local tr = p.project.getsourcetree(prj)
		p.tree.traverse(tr, {
			onleaf = function(node)
				local filecfg = p.fileconfig.getconfig(node, cfg)

				local args = m.getcompilecommandsarguments(cfg, node.abspath, filecfg)
				if not args then
					return
				end

				local objfile = m.getobjectfile(cfg, node, filecfg)
				if not objfile then
					p.warn("Could not determine object file for '%s', skipping", node.abspath)
					return
				end

				objfile = path.getabsolute(objfile)

				args = table.join(args, { "-o", objfile })

				local compile_command = {
					directory = path.getabsolute(prj.location),
					file = node.abspath,
					arguments = args,
					output = objfile,
				}
				
				table.insert(commands, compile_command)
			end
		})
	end

	return commands
end


return m

--
-- _vstudio.lua
-- Define the Visual Studio 200x actions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	_VS = { }


--
-- Configuration blocks used by each version.
--

	_VS.vs2002 = {
		"VCCLCompilerTool",
		"VCCustomBuildTool",
		"VCLinkerTool",
		"VCMIDLTool",
		"VCPostBuildEventTool",
		"VCPreBuildEventTool",
		"VCPreLinkEventTool",
		"VCResourceCompilerTool",
		"VCWebServiceProxyGeneratorTool",
		"VCWebDeploymentTool"
	}
	
	_VS.vs2003 = {
		"VCCLCompilerTool",
		"VCCustomBuildTool",
		"VCLinkerTool",
		"VCMIDLTool",
		"VCPostBuildEventTool",
		"VCPreBuildEventTool",
		"VCPreLinkEventTool",
		"VCResourceCompilerTool",
		"VCWebServiceProxyGeneratorTool",
		"VCXMLDataGeneratorTool",
		"VCWebDeploymentTool",
		"VCManagedWrapperGeneratorTool",
		"VCAuxiliaryManagedWrapperGeneratorTool"
	}
	
	_VS.vs2005 = {
		"VCPreBuildEventTool",
		"VCCustomBuildTool",
		"VCXMLDataGeneratorTool",
		"VCWebServiceProxyGeneratorTool",
		"VCMIDLTool",
		"VCCLCompilerTool",
		"VCManagedResourceCompilerTool",
		"VCResourceCompilerTool",
		"VCPreLinkEventTool",
		"VCLinkerTool",
		"VCALinkTool",
		"VCManifestTool",
		"VCXDCMakeTool",
		"VCBscMakeTool",
		"VCFxCopTool",
		"VCAppVerifierTool",
		"VCWebDeploymentTool",
		"VCPostBuildEventTool"
	}	
		
	_VS.vs2008 = _VS.vs2005


--
-- Clean Visual Studio files
--

	function _VS.onclean(solutions, projects, targets)
		for _,name in ipairs(solutions) do
			os.remove(name .. ".suo")
			os.remove(name .. ".ncb")
		end
		
		for _,name in ipairs(projects) do
			os.remove(name .. ".csproj.user")
			os.remove(name .. ".csproj.webinfo")
		
			local files = os.matchfiles(name .. ".vcproj.*.user", name .. ".csproj.*.user")
			for _, fname in ipairs(files) do
				os.remove(fname)
			end
		end
		
		for _,name in ipairs(targets) do
			os.remove(name .. ".pdb")
			os.remove(name .. ".idb")
			os.remove(name .. ".ilk")
			os.remove(name .. ".vshost.exe")
			os.remove(name .. ".exe.manifest")
		end		
	end
	
	
--
-- Returns the architecture identifier for a project.
--

	function _VS.arch(prj, version)
		if (prj.language == "C#") then
			if (version < 2005) then
				return ".NET"
			else
				return "Any CPU"
			end
		else
			return "Win32"
		end
	end
	
	

--
-- Return the action specific text for a boolean value.
--

	function _VS.bool(value)
		if (_ACTION < "vs2005") then
			return iif(value, "TRUE", "FALSE")
		else
			return iif(value, "true", "false")
		end
	end
	
	
		
--
-- Return a configuration type index.
--

	function _VS.cfgtype(cfg)
		if (cfg.kind == "SharedLib") then
			return 2
		elseif (cfg.kind == "StaticLib") then
			return 4
		else
			return 1
		end
	end
	
	

--
-- Write out entries for the files element; called from premake.walksources().
--

	local function output(indent, value)
		io.write(indent .. value .. "\r\n")
	end
	
	local function attrib(indent, name, value)
		io.write(indent .. "\t" .. name .. '="' .. value .. '"\r\n')
	end
	
	function _VS.files(prj, fname, state, nestlevel)
		local indent = string.rep("\t", nestlevel + 2)
		
		if (state == "GroupStart") then
			output(indent, "<Filter")
			attrib(indent, "Name", path.getname(fname))
			attrib(indent, "Filter", "")
			output(indent, "\t>")

		elseif (state == "GroupEnd") then
			output(indent, "</Filter>")

		else
			output(indent, "<File")
			attrib(indent, "RelativePath", path.translate(fname, "\\"))
			output(indent, "\t>")
			if (not prj.flags.NoPCH and prj.pchsource == fname) then
				for _, cfgname in ipairs(prj.configurations) do
					output(indent, "\t<FileConfiguration")
					attrib(indent, "\tName", cfgname .. "|Win32")
					output(indent, "\t\t>")
					output(indent, "\t\t<Tool")
					attrib(indent, "\t\tName", "VCCLCompilerTool")
					attrib(indent, "\t\tUsePrecompiledHeader", "1")
					output(indent, "\t\t/>")
					output(indent, "\t</FileConfiguration>")
				end
			end
			output(indent, "</File>")
		end
	end
	
	
	
--
-- Returns the name for the import library generated from a DLL. I
-- can't disable it if the NoImportLib flag is set, but I can hide it.
--

	function _VS.importlibfile(cfg)
		local fname = premake.gettargetfile(cfg, "implib", "windows")
		if (cfg.flags.NoImportLib) then
			local objdir = premake.getobjdir(cfg)
			return path.join(objdir, path.getname(fname))
		else
			return fname
		end
	end
	

	
--
-- Return the optimization code.
--

	function _VS.optimization(cfg)
		local result = 0
		for _, value in ipairs(cfg.flags) do
			if (value == "Optimize") then
				result = 3
			elseif (value == "OptimizeSize") then
				result = 1
			elseif (value == "OptimizeSpeed") then
				result = 2
			end
		end
		return result
	end



--
-- Assemble the project file name.
--

	function _VS.projectfile(prj)
		local extension
		if (prj.language == "C#") then
			extension = ".csproj"
		else
			extension = ".vcproj"
		end

		local fname = path.join(prj.location, prj.name)
		return fname..extension
	end
	
	

-- 
-- Returns the runtime code for a configuration.
--

	function _VS.runtime(cfg)
		local debugbuild = (_VS.optimization(cfg) == 0)
		if (cfg.flags.StaticRuntime) then
			return iif(debugbuild, 1, 0)
		else
			return iif(debugbuild, 3, 2)
		end
	end

	

--
-- Return the debugging symbols level for a configuration.
--

	function _VS.symbols(cfg)
		if (not cfg.flags.Symbols) then
			return 0
		else
			-- Edit-and-continue does't work if optimizing or managed C++
			if (cfg.flags.NoEditAndContinue or _VS.optimization(cfg) ~= 0 or cfg.flags.Managed) then
				return 3
			else
				return 4
			end
		end
	end

	
	
--
-- Returns the Visual Studio tool ID for a given project type.
--

	function _VS.tool(prj)
		if (prj.language == "C#") then
			return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC"
		else
			return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942"
		end
	end
	
	
	

--
-- Register the "vs2002" action
--

	premake.actions["vs2002"] = {
		shortname   = "Visual Studio 2002",
		description = "Microsoft Visual Studio 2002",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },

		solutiontemplates = {
			{ ".sln",  _TEMPLATES.vs2002_solution },
		},

		projecttemplates = {
			{ ".vcproj",   _TEMPLATES.vs200x_vcproj },
		},
		
		onclean = _VS.onclean,
	}


--
-- Register the "vs2003" action
--

	premake.actions["vs2003"] = {
		shortname   = "Visual Studio 2003",
		description = "Microsoft Visual Studio 2003",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },

		solutiontemplates = {
			{ ".sln",  _TEMPLATES.vs2003_solution },
		},

		projecttemplates = {
			{ ".vcproj",   _TEMPLATES.vs200x_vcproj },
		},
		
		onclean = _VS.onclean,
	}


--
-- Register the "vs2005" action
--

	premake.actions["vs2005"] = {
		shortname   = "Visual Studio 2005",
		description = "Microsoft Visual Studio 2005",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },

		solutiontemplates = {
			{ ".sln",  _TEMPLATES.vs2005_solution },
		},

		projecttemplates = {
			{ ".vcproj",   _TEMPLATES.vs200x_vcproj },
		},
		
		onclean = _VS.onclean,
	}


--
-- Register the "vs2008" action
--

	premake.actions["vs2008"] = {
		shortname   = "Visual Studio 2008",
		description = "Microsoft Visual Studio 2008",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },

		solutiontemplates = {
			{ ".sln",  _TEMPLATES.vs2005_solution },
		},

		projecttemplates = {
			{ ".vcproj",   _TEMPLATES.vs200x_vcproj },
		},
		
		onclean = _VS.onclean,
	}

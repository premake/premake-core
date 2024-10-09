--
-- _preload.lua
-- Define the makefile action(s).
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local project = p.project

	-- initialize module.
	p.modules.vstudio = p.modules.vstudio or {}
	p.modules.vstudio._VERSION = p._VERSION
	p.vstudio = p.modules.vstudio

	-- load actions.
	include("vs2005.lua")
	include("vs2008.lua")
	include("vs2010.lua")
	include("vs2012.lua")
	include("vs2013.lua")
	include("vs2015.lua")
	include("vs2017.lua")
	include("vs2019.lua")
	include("vs2022.lua")

	-- Initialize Specific API

	p.api.addAllowed("debugger", "VisualStudioLocal")
	p.api.addAllowed("debugger", "VisualStudioRemote")
	p.api.addAllowed("debugger", "VisualStudioWebBrowser")
	p.api.addAllowed("debugger", "VisualStudioWebService")

	p.api.register {
		name = "shaderoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	p.api.register {
		name = "shaderdefines",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	p.api.register {
		name = "shaderincludedirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
		pathVars = true,
	}

	p.api.register {
		name = "shadertype",
		scope = "config",
		kind = "string",
		allowed = {
			"Effect",
			"Vertex",
			"Pixel",
			"Geometry",
			"Hull",
			"Domain",
			"Compute",
			"Library",
			"Mesh",
			"Amplification",
			"Texture",
			"RootSignature",
		}
	}

	p.api.register {
		name = "shadermodel",
		scope = "config",
		kind = "string",
		allowed = {
			"2.0",
			"3.0",
			"4.0_level_9_1",
			"4.0_level_9_3",
			"4.0",
			"4.1",
			"5.0",
			"5.1",
			"rootsig_1.0",
			"rootsig_1.1",
			"6.0",
			"6.1",
			"6.2",
			"6.3",
			"6.4",
			"6.5",
			"6.6"
		}
	}

	p.api.register {
		name = "shaderentry",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "shadervariablename",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "shaderheaderfileoutput",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "shaderobjectfileoutput",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "shaderassembler",
		scope = "config",
		kind = "string",
		allowed = {
			"NoListing",
			"AssemblyCode",
			"AssemblyCodeAndHex",
		}
	}

	p.api.register {
		name = "shaderassembleroutput",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "externalanglebrackets",
		scope = "config",
		kind = "string",
		allowed = {
			"On",
			"Off",
		},
	}

	p.api.register {   -- DEPRECATED 2019-10-21
		name = "debuggerflavor",
		scope = "config",
		kind = "string",
		allowed = {
			"Local",
			"Remote",
			"WebBrowser",
			"WebService"
		}
	}

	p.api.deprecateField("debuggerflavor", 'Use `debugger` instead.',
	function(value)
		debugger('VisualStudio' .. value)
	end)

	p.api.register {
		name = "scanformoduledependencies",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "usestandardpreprocessor",
		scope = "config",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "enableunitybuild",
		scope = { "config" },
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "enablemodules",
		scope = { "config" },
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "buildstlmodules",
		scope = { "config" },
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "clangtidy",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "runcodeanalysis",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "vsprops",
		scope = "config",
		kind = "list:table",
		tokens = true,
	}

	p.api.register {
		name = "toolchainversion",
		scope = "config",
		kind = "string",
		allowed = {}
	}

--
-- Register Linux properties
--

	p.api.addAllowed("toolchainversion", { "remote", "wsl", "wsl2" })

	-- Directory in the remote machine where our files will be copied before compilation
	p.api.register {
		name = "remoterootdir",
		scope = "config",
		kind = "string",
	}

	-- Relative per-project directory. Set to empty for the entire project to be copied as is
	-- Should default to empty really for the more seamless experience
	p.api.register {
		name = "remoteprojectrelativedir",
		scope = "config",
		kind = "string",
	}

	-- Directory in the remote machine where the build is deployed
	-- Only applies to WSL projects
	p.api.register {
		name = "remotedeploydir",
		scope = "config",
		kind = "string",
	}

	p.api.register {
		name = "remoteprojectdir",
		scope = "config",
		kind = "string",
	}

	-- Directory of LLVM install
	p.api.register {
		name = "llvmdir",
		scope = "config",
		kind = "directory",
		tokens = "true",
	}

	-- Version of LLVM Install
	p.api.register {
		name = "llvmversion",
		scope = "config",
		kind = "string",
		tokens = "true",
	}

	p.api.register {
		name = "dotnetsdk",
		scope = "project",
		kind = "string",
		allowed = {
			"Default",
			"Web",
			"Razor",
			"Worker",
			"Blazor",
			"WindowsDesktop",
			"MSTest"
		}
	}

--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return
			_ACTION == "vs2005" or
			_ACTION == "vs2008" or
			_ACTION == "vs2010" or
			_ACTION == "vs2012" or
			_ACTION == "vs2013" or
			_ACTION == "vs2015" or
			_ACTION == "vs2017" or
			_ACTION == "vs2019" or
			_ACTION == "vs2022" or
			false;
	end

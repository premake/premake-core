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

	-- Initialize Specific API

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
			"rootsig_1.0",
			"rootsig_1.1",
			"6.0",
			"6.1",
			"6.2",
			"6.3"
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
			false;
	end

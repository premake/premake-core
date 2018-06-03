--
-- Name:        xbox360/_preload.lua
-- Purpose:     Define the Xbox 360 APIs
-- Author:      Emilio López
-- Copyright:   (c) 2018-2018 Jason Perkins and the Premake project
--

	local p = premake
	local api = p.api

--
-- Register the Xbox 360 extension
--

	p.XBOX360 = "xbox360"

	api.addAllowed("system", p.XBOX360)
	api.addAllowed("architecture", { "x86", "x64" })
	api.addAllowed("vectorextensions", { "altivec" })

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { "xbox360",  "XBOX360" })
	end

	-- add system tags for XBOX360
	os.systemTags[p.XBOX360] = { "xbox360" }

	filter { "system:xbox360", "kind:ConsoleApp or WindowedApp" }
		targetextension ".exe"
		
	filter { "system:xbox360", "kind:SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	filter { "system:xbox360", "kind:StaticLib" }
		targetprefix ""
		targetextension ".lib"
	
--
-- Register Xbox 360 properties
--

-- Compilation properties

	-- VMX registers reservation
	api.register {
		name = "registerreservation",
		scope = "config",
		kind = "boolean",
	}
	
	-- Listing with cycle count from pipeline emulations
	api.register {
		name = "analyzestalls",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "callattributedprofiling",
		scope = "config",
		kind = "string",
		allowed = {
			"disabled",
			"callcap", -- Call profiler around function calls
			"fastcap", -- Call profiler within function calls
		},
	}
	
	-- Trap instructions around integer divides
	api.register {
		name = "trapintegerdivides",
		scope = "config",
		kind = "boolean",
	}
	
	-- Perform an additional code scheduling pass
	api.register {
		name = "prescheduling",
		scope = "config",
		kind = "boolean",
	}
	
	-- Reorder inline assembly instructions
	api.register {
		name = "inlineassembly",
		scope = "config",
		kind = "boolean",
	}

-- XEX properties
	
	api.register {
		name = "xexoutput",
		scope = "config",
		kind = "string",
		tokens = true,
	}
	
	api.register {
		name = "configfile",
		scope = "config",
		kind = "string",
		tokens = true,
	}
	
	api.alias("configfile", "configFile")
	
	-- Specify title id
	api.register {
		name = "titleid",
		scope = "config",
		kind = "string",
	}

	-- 32 digits: "ABCDEF0102030405060708a1b2b3c4d5"
	api.register {
		name = "lankey",
		scope = "config",
		kind = "string",
	}
	
	-- Example "0x88000000" 64k aligned
	api.register {
		name = "baseaddress",
		scope = "config",
		kind = "string",
	}
	
	api.register {
		name = "heapsize",
		scope = "config",
		kind = "string",
	}
	
	api.register {
		name = "workspacesize",
		scope = "config",
		kind = "string",
	}
	
	api.register {
		name = "additionalsections",
		scope = "config",
		kind = "string",
	}
	
	-- Include symbol names in the executable
	api.register {
		name = "exportbyname",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "opticaldiscdrivemapping",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "pal50incompatible",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "multidisctitle",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "preferbigbuttoninput",
		scope = "config",
		kind = "boolean",
	}
	
	-- IP instead of ethernet
	api.register {
		name = "crossplatformsystemlink",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "allowavatargetmetadata",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "allowcontrollerswapping",
		scope = "config",
		kind = "boolean",
	}
	
	-- Require extended Xbox Live
	api.register {
		name = "requirefullexperience",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "gamevoicerequiredui",
		scope = "config",
		kind = "boolean",
	}

-- Deployment properties

	api.register {
		name = "deployment",
		scope = "config",
		kind = "string",
		allowed = {
			"copytohdd",
			"emulatehdd",
		},
	}
	
	-- Suppress startup banner and information messages
	api.register {
		name = "nostartupbanner",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "buildnodeploy",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "showdeployprogress",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "deployforce",
		scope = "config",
		kind = "boolean",
	}
	
	api.register {
		name = "dvdemulationtype",
		scope = "config",
		kind = "string",
		allowed = {
			"zero",
			"typical",
			"accurate",
		},
	}
	
	api.register {
		name = "deploymentfiles",
		scope = "config",
		kind = "string",
		tokens = true,
	}
	
	api.register {
		name = "deploymentroot",
		scope = "config",
		kind = "string",
		tokens = true,
	}
	
	api.register {
		name = "layoutfile",
		scope = "config",
		kind = "string",
		tokens = true,
	}
	
	return function(cfg)
		return (cfg.system == p.XBOX360)
	end

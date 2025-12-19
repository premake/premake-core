--
-- _preload.lua
-- Define the Visual Studio action(s).
-- Copyright (c) Jess Perkins and the Premake project
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
	include("vs2026.lua")

	-- Initialize Specific API

	p.api.addAllowed("debugger", "VisualStudioLocal")
	p.api.addAllowed("debugger", "VisualStudioRemote")
	p.api.addAllowed("debugger", "VisualStudioWebBrowser")
	p.api.addAllowed("debugger", "VisualStudioWebService")

	p.api.register {
		name = "allmodulespublic",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "assemblydebug",
		scope = "config",
		kind  = "boolean"
	}

	p.api.register {
		name = "atl",
		scope = "config",
		kind  = "string",
		allowed = {
			"Off",
			"Dynamic",
			"Static",
		},
	}

	p.api.register {
		name = "buildcustomizations",
		scope = "project",
		kind = "list:string",
	}

	p.api.register {
		name = "builddependencies",
		scope = { "rule" },
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}
	p.api.alias("builddependencies", "buildDependencies") -- for backward compatibility

	p.api.register {
		name = "buildlog",
		scope = { "config" },
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	p.api.register {
		name = "callingconvention",
		scope = "config",
		kind = "string",
		allowed = {
			"Cdecl",
			"FastCall",
			"StdCall",
			"VectorCall",
		}
	}

	p.api.register {
		name = "cleanextensions",
		scope = "config",
		kind = "list:string",
	}
	p.api.alias("cleanextensions", "cleanExtensions") -- for backward compatibility

	p.api.register {
		name = "conformancemode",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "consumewinrtextension",
		scope = "config",
		kind = "boolean",
	}

	p.api.register {
		name = "customtoolnamespace",
		scope = "config",
		kind = "string",
	}

	p.api.register {
		name = "debuggertype",
		scope = "config",
		kind = "string",
		allowed = {
			"Mixed",
			"NativeOnly",
			"ManagedOnly",
			"NativeWithManagedCore"
		}
	}

	p.api.register {
		name = "documentationfile",
		scope = "project",
		kind = "string",
	}

	p.api.register {
		name = "dotnetframework",
		scope = "config",
		kind = "string",
	}
	p.api.alias("dotnetframework", "framework") -- for backward compatibility

	p.api.register {
		name = "dpiawareness",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"None",
			"High",
			"HighPerMonitor",
		}
	}

	p.api.register {
		name = "enabledefaultcompileitems",
		scope = "config",
		kind = "boolean",
		default = false
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

	p.api.register {
		name = "fastuptodate",
		scope = "project",
		kind = "boolean",
	}

	p.api.register {
		name = "floatingpointexceptions",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "functionlevellinking",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "forceusings",
		scope = "config",
		kind = "list:file",
		tokens = true,
	}

	p.api.register {
		name = "ignoredefaultlibraries",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
	}

	p.api.register {
		name = "imageoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	p.api.register {
		name = "imagepath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	p.api.register {
		name = "inheritdependencies",
		scope = "config",
		kind = "boolean",
	}

	p.api.register {
		name = "inlining",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Disabled",
			"Explicit",
			"Auto"
		}
	}

	p.api.register {
		name = "intrinsics",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "justmycode",
		scope = "project",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "largeaddressaware",
		scope = "config",
		kind = "boolean",
	}

	p.api.register {
		name = "locale",
		scope = "config",
		kind = "string",
		tokens = false,
	}

	p.api.register {
		name = "namespace",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "nativewchar",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
		}
	}

	p.api.register {
		name = "pchsource",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	p.api.register {
		name = "preferredtoolarchitecture",
		scope = "workspace",
		kind = "string",
		allowed = {
			"Default",
			p.X86,
			p.X86_64,
		}
	}

	p.api.register {
		name = "removeunreferencedcodedata",
		scope = "config",
		kind = "boolean"
	}

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
		name = "stringpooling",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "symbolspath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	p.api.register {
		name = "tailcalls",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "toolsversion",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	p.api.register {
		name = "usefullpaths",
		scope = "config",
		kind = "boolean"
	}

	p.api.register {
		name = "usingdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
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
			"MSTest",
			function (value)
				-- value is expected to be in the format <sdk>/<version>
				local parts = value:explode("/", true, 1)

				if parts and #parts == 2 then
					if p.api.checkValue(p.field.get("dotnetsdk"), parts[1], "string") then
						return value
					end
				end

				return nil
			end
		}
	}

	p.api.register {
		name = "mfc",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Off",
			"On",
			"Static",
			"Dynamic",
		}
	}

--
-- Register Android properties
--

	p.api.register {
		name = "endian",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Little",
			"Big",
		},
	}

	p.api.register {
		name = "fpu",
		scope = "config",
		kind = "string",
		allowed = {
			"Software",
			"Hardware",
		}
	}

	p.api.addAllowed("toolchainversion", {
		"4.6", -- NDK GCC versions
		"4.8",
		"4.9",
		"3.4", -- NDK clang versions
		"3.5",
		"3.6",
		"3.8",
		"5.0", })

	p.api.register {
		name = "floatabi",
		scope = "config",
		kind = "string",
		allowed = {
			"soft",
			"softfp",
			"hard",
		},
	}

	p.api.register {
		name = "androidapilevel",
		scope = "config",
		kind = "integer",
	}

	p.api.register {
		name = "stl",
		scope = "config",
		kind = "string",
		allowed = {
			"none",
			"gabi++",
			"stlport",
			"gnu",
			"libc++",
		},
	}

	p.api.register {
		name = "thumbmode",
		scope = "config",
		kind = "string",
		allowed = {
			"thumb",
			"arm",
			"disabled",
		},
	}

	-- Emit each data item in a separate section. This help linker optimizations to remove unused data
	p.api.register {
		name = "linksectiondata",
		scope = "config",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "linksectionfunction",
		scope = "config",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	p.api.register {
		name = "androidapplibname",
		scope = "config",
		kind = "string"
	}

	p.api.addAllowed("system", p.ANDROID)
	p.api.addAllowed("architecture", { "armv5", "armv7", "aarch64", "mips", "mips64", "arm" })
	p.api.addAllowed("vectorextensions", { "NEON", "MXU" })
	p.api.addAllowed("exceptionhandling", {"UnwindTables"})
	p.api.addAllowed("kind", p.PACKAGING)
	p.api.addAllowed("flags", { "NoImplicitLink" })

	p.api.register {
		name = "implicitlink",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off"
		}
	}

	p.api.deprecateValue("flags", "NoImplicitLink", "Use `implicitlink` instead.",
	function(value)
		implicitlink("Off")
	end,
	function(value)
		implicitlink("Default")
	end)

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
			_ACTION == "vs2026" or
			false;
	end

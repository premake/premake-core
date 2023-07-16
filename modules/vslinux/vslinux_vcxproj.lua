--
-- vslinux/vslinux_vcxproj.lua
-- vslinux integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	p.modules.vslinux = { }

	local vslinux = p.modules.vslinux
	local vc2010 = p.vstudio.vc2010
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config

--
-- Extend global properties
--
	p.override(vc2010.elements, "globals", function (oldfn, prj)
		local elements = oldfn(prj)

		if prj.system == p.LINUX then
		
			table.remove(elements, table.indexof(elements, vc2010.ignoreWarnDuplicateFilename))
			
			elements = table.join(elements, {
				vslinux.linuxApplicationType
			})
		end

		return elements
	end)

	p.override(vc2010.elements, "globalsCondition", function (oldfn, prj, cfg)
		local elements = oldfn(prj, cfg)

		if cfg.system == p.LINUX and cfg.system ~= prj.system then
			elements = table.join(elements, {
				vslinux.linuxApplicationType
			})
		end

		return elements
	end)

	function vslinux.linuxApplicationType(cfg)
		vc2010.element("Keyword", nil, "Linux")
		vc2010.element("RootNamespace", nil, "%s", cfg.project.name)
		vc2010.element("MinimumVisualStudioVersion", nil, "17.0")
		vc2010.element("ApplicationType", nil, "Linux")
		vc2010.element("TargetLinuxPlatform", nil, "Generic")
		vc2010.element("ApplicationTypeRevision", nil, "1.0")
	end

--
-- Extend configurationProperties.
--

	p.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)

		if cfg.system == p.LINUX and cfg.kind ~= p.UTILITY and cfg.kind ~= p.PACKAGING then
			
			table.remove(elements, table.indexof(elements, vc2010.characterSet))
			table.remove(elements, table.indexof(elements, vc2010.wholeProgramOptimization))
			table.remove(elements, table.indexof(elements, vc2010.windowsSDKDesktopARMSupport))

			elements = table.join(elements, {
				vslinux.linuxStlType,
				vslinux.remoteRootDir,
				vslinux.remoteProjectRelDir
			})
		end
		return elements
	end)

	function vslinux.linuxStlType(cfg)
		if cfg.staticruntime ~= nil then
			vc2010.element("UseOfStl", nil, iif(cfg.staticruntime == "On", "libstdc++_static", "libstdc++_shared"))
		end
	end
	
	function vslinux.remoteRootDir(cfg)
		if cfg.remoterootdir ~= nil and cfg.remoterootdir ~= "" then
			vc2010.element("RemoteRootDir", nil, cfg.remoterootdir)
		end
	end
	
	function vslinux.remoteProjectRelDir(cfg)
		if cfg.remoteprojectrelativedir ~= nil then
			vc2010.element("RemoteProjectRelDir", nil, cfg.remoteprojectrelativedir)
		end
	end

	p.override(vc2010, "platformToolset", function(oldfn, cfg)
		if cfg.system ~= p.LINUX then
			return oldfn(cfg)
		end

		local gcc_map = {
			["remote"] = "Remote_GCC_1_0",
			["wsl"] = "WSL_1_0",
			["wsl2"] = "WSL2_1_0",
		}
		
		local clang_map = {
			["remote"] = "Remote_Clang_1_0",
			["wsl"] = "WSL_Clang_1_0",
			["wsl2"] = "WSL2_Clang_1_0",
		}

		if cfg.toolchainversion ~= nil then
			local map = iif(cfg.toolset == "gcc", gcc_map, clang_map)
			local ts  = map[cfg.toolchainversion]
			if ts == nil then
				p.error('Invalid toolchainversion for the selected toolset (%s).', cfg.toolset or "clang")
			end

			vc2010.element("PlatformToolset", nil, ts)
		end
	end)

--
-- Extend clCompile.
--

	p.override(vc2010.elements, "clCompile", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.system == p.LINUX then
			elements = table.join(elements, {
				vslinux.strictAliasing,
				vslinux.pic
			})

			table.replace(elements, vc2010.floatingPointModel, vslinux.floatingPointModel)
			
			table.replace(elements, vc2010.debugInformationFormat, vslinux.debugInformationFormat)
			
			table.replace(elements, vc2010.wholeProgramOptimization, vslinux.wholeProgramOptimization)

			-- Linux has C[pp]LanguageStandard instead.
			table.replace(elements, vc2010.languageStandard, vslinux.languageStandard)

			table.replace(elements, vc2010.languageStandardC, vslinux.languageStandardC)
			
			table.replace(elements, vc2010.warningLevel, vslinux.warningLevel)

			-- Remove properties that don't make sense in Linux builds
			table.remove(elements, table.indexof(elements, vc2010.stringPooling))
			table.remove(elements, table.indexof(elements, vc2010.minimalRebuild))
			table.remove(elements, table.indexof(elements, vc2010.enableFunctionLevelLinking))
			table.remove(elements, table.indexof(elements, vc2010.intrinsicFunctions))
			table.remove(elements, table.indexof(elements, vc2010.functionLevelLinking))
			table.remove(elements, table.indexof(elements, vc2010.inlineFunctionExpansion))
			table.remove(elements, table.indexof(elements, vc2010.runtimeLibrary))
			table.remove(elements, table.indexof(elements, vc2010.precompiledHeader))
			table.remove(elements, table.indexof(elements, vc2010.precompiledHeaderFile))
			table.remove(elements, table.indexof(elements, vc2010.externalWarningLevel))
			
		end
		return elements
	end)
	
	function vslinux.warningLevel(cfg)
	
		if cfg.warnings ~= nil then
			vc2010.element("WarningLevel", nil, iif(cfg.warnings == p.OFF, "false", "EnableAllWarnings"))
		end
	
	end
	
	function vslinux.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			vc2010.element("LinkTimeOptimization", nil, "true")
		end
	end
	
	function vslinux.floatingPointModel(cfg)

		if cfg.floatingpoint ~= nil then
			vc2010.element("RelaxIEEE", nil, iif(cfg.floatingpoint == p.OFF, "false", "true"))
		end
	
	end
	
	function vslinux.debugInformationFormat(cfg, toolset)
	
		if cfg.symbols ~= nil then
	
			if cfg.symbols == p.ON then
				vc2010.element("DebugInformationFormat", nil, "Minimal")
			elseif cfg.symbols == "Full" then
				vc2010.element("DebugInformationFormat", nil, "FullDebug")
			elseif cfg.symbols == p.OFF then
				vc2010.element("DebugInformationFormat", nil, "None")
			end
		
		end
	
	end

	function vslinux.strictAliasing(cfg)
		if cfg.strictaliasing ~= nil then
			vc2010.element("StrictAliasing", nil, iif(cfg.strictaliasing == "Off", "false", "true"))
		end
	end

	function vslinux.pic(cfg)
		if cfg.pic ~= nil then
			vc2010.element("PositionIndependentCode", nil, iif(cfg.pic == "On", "true", "false"))
		end
	end

	function vslinux.languageStandardC(cfg)
		local c_langmap = {
			["C89"]   = "c89",
			["C99"]   = "c99",
			["C11"]   = "c11",
			["gnu99"] = "gnu99",
			["gnu11"] = "gnu11",
		}
		if c_langmap[cfg.cdialect] ~= nil then
			vc2010.element("CLanguageStandard", nil, c_langmap[cfg.cdialect])
		end
	end

	function vslinux.languageStandard(cfg)

		local cpp_langmap = {
			["C++98"]   = "c++98",
			["C++03"]   = "c++98",
			["C++11"]   = "c++11",
			["C++14"]   = "c++14",
			["C++17"]   = "c++17",
			["C++2a"]   = "c++2a",
			["C++20"]   = "c++20",
			["C++latest"] = "c++2a",
			["gnu++98"] = "gnu++98",
			["gnu++03"] = "gnu++03",
			["gnu++11"] = "gnu++11",
			["gnu++14"] = "gnu++14",
			["gnu++17"] = "gnu++17",
			["gnu++17"] = "gnu++20",
		}
		
		if cpp_langmap[cfg.cppdialect] ~= nil then
			vc2010.element("CppLanguageStandard", nil, cpp_langmap[cfg.cppdialect])
		end
	end

	p.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		if cfg.system == p.LINUX then
			local opts = cfg.buildoptions

			if cfg.disablewarnings and #cfg.disablewarnings > 0 then
				for _, warning in ipairs(cfg.disablewarnings) do
					table.insert(opts, '-Wno-' .. warning)
				end
			end

			-- -fvisibility=<>
			if cfg.visibility ~= nil then
				table.insert(opts, p.tools.gcc.cxxflags.visibility[cfg.visibility])
			end

			if #opts > 0 then
				opts = table.concat(opts, " ")
				vc2010.element("AdditionalOptions", condition, '%s %%(AdditionalOptions)', opts)
			end
		else
			oldfn(cfg, condition)
		end
	end)

	p.override(vc2010, "clCompilePreprocessorDefinitions", function(oldfn, cfg, condition)
		if cfg.system == p.LINUX then
			vc2010.preprocessorDefinitions(cfg, cfg.defines, false, condition)
		else
			oldfn(cfg, condition)
		end
	end)

--
-- Exceptions
--

	p.override(vc2010, "exceptionHandling", function(oldfn, cfg, condition)
		if cfg.system == p.LINUX then
		
			-- Exceptions have different values from standard projects
			local exceptions = {
				On = "Enabled",
				Off = "Disabled"
			}
			
			if exceptions[cfg.exceptionhandling] ~= nil then
				vc2010.element("ExceptionHandling", condition, exceptions[cfg.exceptionhandling])
			end
		else
			oldfn(cfg, condition)
		end
	end)

--
-- Disable subsystem.
--

	p.override(vc2010, "subSystem", function(oldfn, cfg)
		if cfg.system ~= p.LINUX then
			return oldfn(cfg)
		end
	end)

--
-- Disable override of OutDir. This is breaking deployment.
--

	p.override(vc2010, "outDir", function(oldfn, cfg)
		if cfg.system ~= p.LINUX then
			return oldfn(cfg)
		end
	end)
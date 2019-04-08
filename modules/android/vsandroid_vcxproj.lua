--
-- android/vsandroid_vcxproj.lua
-- vs-android integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	p.modules.vsandroid = { }

	local android = p.modules.android
	local vsandroid = p.modules.vsandroid
	local vc2010 = p.vstudio.vc2010
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config


--
-- Utility functions
--
	local function setBoolOption(optionName, flag, value)
		if flag ~= nil then
			vc2010.element(optionName, nil, value)
		end
	end

--
-- Add android tools to vstudio actions.
--

	if vstudio.vs2010_architectures ~= nil then
		if _ACTION >= "vs2015" then
			vstudio.vs2010_architectures.arm = "ARM"
		else
			vstudio.vs2010_architectures.android = "Android"
		end
	end

--
-- Extend global properties
--
	premake.override(vc2010.elements, "globals", function (oldfn, prj)
		local elements = oldfn(prj)

		if prj.system == premake.ANDROID and prj.kind ~= premake.PACKAGING then
			-- Remove "IgnoreWarnCompileDuplicatedFilename".
			local pos = table.indexof(elements, vc2010.ignoreWarnDuplicateFilename)
			table.remove(elements, pos)
			elements = table.join(elements, {
				android.androidApplicationType
			})
		end

		return elements
	end)

	premake.override(vc2010.elements, "globalsCondition", function (oldfn, prj, cfg)
		local elements = oldfn(prj, cfg)

		if cfg.system == premake.ANDROID and cfg.system ~= prj.system and cfg.kind ~= premake.PACKAGING then
			elements = table.join(elements, {
				android.androidApplicationType
			})
		end

		return elements
	end)

	function android.androidApplicationType(cfg)
		vc2010.element("Keyword", nil, "Android")
		vc2010.element("RootNamespace", nil, "%s", cfg.project.name)
		vc2010.element("MinimumVisualStudioVersion", nil, "15.0") -- Use 14.0 for VS2015?
		vc2010.element("ApplicationType", nil, "Android")
		if _ACTION >= "vs2017" then
			vc2010.element("ApplicationTypeRevision", nil, "3.0")
		elseif _ACTION >= "vs2015" then
			vc2010.element("ApplicationTypeRevision", nil, "2.0")
		else
			vc2010.element("ApplicationTypeRevision", nil, "1.0")
		end
	end

--
-- Extend configurationProperties.
--

	premake.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)

		if cfg.kind ~= p.UTILITY and cfg.kind ~= p.PACKAGING and cfg.system == premake.ANDROID then
			table.remove(elements, table.indexof(elements, vc2010.characterSet))
			table.remove(elements, table.indexof(elements, vc2010.wholeProgramOptimization))
			table.remove(elements, table.indexof(elements, vc2010.windowsSDKDesktopARMSupport))

			elements = table.join(elements, {
				android.androidAPILevel,
				android.androidStlType,
			})

			if _ACTION >= "vs2015" then
				elements = table.join(elements, {
					android.thumbMode,
				})
			end
		end
		return elements
	end)

	function android.androidAPILevel(cfg)
		if cfg.androidapilevel ~= nil then
			vc2010.element("AndroidAPILevel", nil, "android-" .. cfg.androidapilevel)
		end
	end

	function android.androidStlType(cfg)
		if cfg.stl ~= nil then
			local stlType = {
				["none"] = "system",
				["gabi++"] = "gabi++",
				["stlport"] = "stlport",
				["gnustl"] = "gnustl",
				["libc++"] = "c++",
			}

			local postfix = iif(cfg.staticruntime == "On", "_static", "_shared")
			local runtimeLib = iif(cfg.stl == "none", "system", stlType[cfg.stl] .. postfix)

			if _ACTION >= "vs2015" then
				vc2010.element("UseOfStl", nil, runtimeLib)
			else
				vc2010.element("AndroidStlType", nil, runtimeLib)
			end
		end
	end

	function android.thumbMode(cfg)
		if cfg.thumbmode ~= nil then
			local thumbMode =
			{
				thumb = "Thumb",
				arm = "ARM",
				disabled = "Disabled",
			}
			vc2010.element("ThumbMode", nil, thumbMode[cfg.thumbmode])
		end
	end

	-- Note: this function is already patched in by vs2012...
	premake.override(vc2010, "platformToolset", function(oldfn, cfg)
		if cfg.system ~= premake.ANDROID then
			return oldfn(cfg)
		end

		if _ACTION >= "vs2015" then
			local gcc_map = {
				["4.6"] = "GCC_4_6",
				["4.8"] = "GCC_4_8",
				["4.9"] = "GCC_4_9",
			}
			local clang_map = {
				["3.4"] = "Clang_3_4",
				["3.5"] = "Clang_3_5",
				["3.6"] = "Clang_3_6",
				["3.8"] = "Clang_3_8",
				["5.0"] = "Clang_5_0",
			}

			if cfg.toolchainversion ~= nil then
				local map = iif(cfg.toolset == "gcc", gcc_map, clang_map)
				local ts  = map[cfg.toolchainversion]
				if ts == nil then
					p.error('Invalid toolchainversion for the selected toolset (%s).', cfg.toolset or "clang")
				end

				vc2010.element("PlatformToolset", nil, ts)
			end
		else
			local archMap = {
				arm = "armv5te", -- should arm5 be default? vs-android thinks so...
				arm5 = "armv5te",
				arm7 = "armv7-a",
				mips = "mips",
				x86 = "x86",
			}
			local arch = cfg.architecture or "arm"

			if (cfg.architecture ~= nil or cfg.toolchainversion ~= nil) and archMap[arch] ~= nil then
				local defaultToolsetMap = {
					arm = "arm-linux-androideabi-",
					armv5 = "arm-linux-androideabi-",
					armv7 = "arm-linux-androideabi-",
					aarch64 = "aarch64-linux-android-",
					mips = "mipsel-linux-android-",
					mips64 = "mips64el-linux-android-",
					x86 = "x86-",
					x86_64 = "x86_64-",
				}
				local toolset = defaultToolsetMap[arch]

				if cfg.toolset == "clang" then
					error("The clang toolset is not yet supported by vs-android", 2)
					toolset = toolset .. "clang"
				elseif cfg.toolset and cfg.toolset ~= "gcc" then
					error("Toolset not supported by the android NDK: " .. cfg.toolset, 2)
				end

				local version = cfg.toolchainversion or iif(cfg.toolset == "clang", "3.5", "4.9")

				vc2010.element("PlatformToolset", nil, toolset .. version)
				vc2010.element("AndroidArch", nil, archMap[arch])
			end
		end
	end)


--
-- Extend clCompile.
--

	premake.override(vc2010.elements, "clCompile", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.system == premake.ANDROID then
			elements = table.join(elements, {
				android.debugInformation,
				android.strictAliasing,
				android.fpu,
				android.pic,
				android.shortEnums,
				android.cStandard,
				android.cppStandard,
			})
			if _ACTION >= "vs2015" then
				table.remove(elements, table.indexof(elements, vc2010.debugInformationFormat))

				-- Android has C[pp]LanguageStandard instead.
				table.remove(elements, table.indexof(elements, vc2010.languageStandard))
				-- Ignore multiProcessorCompilation for android projects, they use UseMultiToolTask instead.
				table.remove(elements, table.indexof(elements, vc2010.multiProcessorCompilation))
				-- minimalRebuild also ends up in android projects somehow.
				table.remove(elements, table.indexof(elements, vc2010.minimalRebuild))

				-- VS has NEON support through EnableNeonCodegen.
				table.replace(elements, vc2010.enableEnhancedInstructionSet, android.enableEnhancedInstructionSet)
				-- precompiledHeaderFile support.
				table.replace(elements, vc2010.precompiledHeaderFile, android.precompiledHeaderFile)
			end
		end
		return elements
	end)

	function android.precompiledHeaderFile(fileName, cfg)
		-- Doesn't work for project-relative paths.
		vc2010.element("PrecompiledHeaderFile", nil, "%s", path.getabsolute(path.rebase(fileName, cfg.basedir, cfg.location)))
	end

	function android.debugInformation(cfg)
		if cfg.flags.Symbols then
			_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
		end
	end

	function android.strictAliasing(cfg)
		if cfg.strictaliasing ~= nil then
			vc2010.element("StrictAliasing", nil, iif(cfg.strictaliasing == "Off", "false", "true"))
		end
	end

	function android.fpu(cfg)
		if cfg.fpu ~= nil then
			_p(3,'<SoftFloat>true</SoftFloat>', iif(cfg.fpu == "Software", "true", "false"))
		end
	end

	function android.pic(cfg)
		if cfg.pic ~= nil then
			vc2010.element("PositionIndependentCode", nil, iif(cfg.pic == "On", "true", "false"))
		end
	end

	function android.verboseCompiler(cfg)
		setBoolOption("Verbose", cfg.flags.VerboseCompiler, "true")
	end

	function android.undefineAllPreprocessorDefinitions(cfg)
		setBoolOption("UndefineAllPreprocessorDefinitions", cfg.flags.UndefineAllPreprocessorDefinitions, "true")
	end

	function android.showIncludes(cfg)
		setBoolOption("ShowIncludes", cfg.flags.ShowIncludes, "true")
	end

	function android.dataLevelLinking(cfg)
		setBoolOption("DataLevelLinking", cfg.flags.DataLevelLinking, "true")
	end

	function android.shortEnums(cfg)
		setBoolOption("UseShortEnums", cfg.flags.UseShortEnums, "true")
	end

	function android.cStandard(cfg)
		local c_langmap = {
			["C98"]   = "c98",
			["C99"]   = "c99",
			["C11"]   = "c11",
			["gnu99"] = "gnu99",
			["gnu11"] = "gnu11",
		}
		if c_langmap[cfg.cdialect] ~= nil then
			vc2010.element("CLanguageStandard", nil, c_langmap[cfg.cdialect])
		end
	end

	function android.cppStandard(cfg)
		local cpp_langmap = {
			["C++98"]   = "c++98",
			["C++11"]   = "c++11",
			["C++14"]   = "c++1y",
			["C++17"]   = "c++1z",
			["C++latest"] = "c++1z",
			["gnu++98"] = "gnu++98",
			["gnu++11"] = "gnu++11",
			["gnu++14"] = "gnu++1y",
			["gnu++17"] = "gnu++1z",
		}
		if cpp_langmap[cfg.cppdialect] ~= nil then
			vc2010.element("CppLanguageStandard", nil, cpp_langmap[cfg.cppdialect])
		end
	end

	p.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		if cfg.system == p.ANDROID then
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

	p.override(vc2010, "warningLevel", function(oldfn, cfg)
		if _ACTION >= "vs2015" and cfg.system == p.ANDROID and cfg.warnings and cfg.warnings ~= "Off" then
			vc2010.element("WarningLevel", nil, "EnableAllWarnings")
		elseif (_ACTION >= "vs2015" and cfg.system == p.ANDROID and cfg.warnings) or not (_ACTION >= "vs2015" and cfg.system == p.ANDROID) then
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "clCompilePreprocessorDefinitions", function(oldfn, cfg, condition)
		if cfg.system == p.ANDROID then
			vc2010.preprocessorDefinitions(cfg, cfg.defines, false, condition)
		else
			oldfn(cfg, condition)
		end
	end)

	premake.override(vc2010, "exceptionHandling", function(oldfn, cfg, condition)
		if cfg.system == p.ANDROID then
			-- Note: Android defaults to 'off'
			local exceptions = {
				On = "Enabled",
				Off = "Disabled",
				UnwindTables = "UnwindTables",
			}
			if _ACTION >= "vs2015" then
				if exceptions[cfg.exceptionhandling] ~= nil then
					vc2010.element("ExceptionHandling", condition, exceptions[cfg.exceptionhandling])
				end
			else
				if cfg.exceptionhandling == premake.ON then
					vc2010.element("GccExceptionHandling", condition, "true")
				end
			end
		else
			oldfn(cfg, condition)
		end
	end)

	function android.enableEnhancedInstructionSet(cfg)
		if cfg.vectorextensions == "NEON" then
			vc2010.element("EnableNeonCodegen", nil, "true")
		end
	end

	premake.override(vc2010, "runtimeTypeInfo", function(oldfn, cfg, condition)
		if cfg.system == premake.ANDROID then
			-- Note: Android defaults to 'off'
			if cfg.rtti == premake.ON then
				vc2010.element("RuntimeTypeInfo", condition, "true")
			end
		else
			oldfn(cfg, condition)
		end
	end)


--
-- Extend Link.
--

	premake.override(vc2010, "generateDebugInformation", function(oldfn, cfg)
		-- Note: Android specifies the debug info in the clCompile section
		if cfg.system ~= premake.ANDROID then
			oldfn(cfg)
		end
	end)


--
-- Add android tools to vstudio actions.
--

	premake.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.system == premake.ANDROID and _ACTION < "vs2015" then
			elements = table.join(elements, {
				android.antBuild,
			})
		end
		return elements
	end)

	function android.antPackage(cfg)
		p.push('<AntPackage>')
		if cfg.androidapplibname ~= nil then
			vc2010.element("AndroidAppLibName", nil, cfg.androidapplibname)
		else
			vc2010.element("AndroidAppLibName", nil, "$(RootNamespace)")
		end
		p.pop('</AntPackage>')
	end

	function android.antBuild(cfg)
		if cfg.kind == premake.STATICLIB or cfg.kind == premake.SHAREDLIB then
			return
		end

		_p(2,'<AntBuild>')
		_p(3,'<AntBuildType>%s</AntBuildType>', iif(premake.config.isDebugBuild(cfg), "Debug", "Release"))
		_p(2,'</AntBuild>')
	end

	premake.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		if cfg.system == premake.ANDROID then
			vsandroid.additionalOptions(cfg, condition)
		end
		return oldfn(cfg, condition)
	end)

	premake.override(vc2010.elements, "user", function(oldfn, cfg)
		if cfg.system == p.ANDROID then
			return {}
		else
			return oldfn(cfg)
		end
	end)

--
-- Add options unsupported by vs-android UI to <AdvancedOptions>.
--
	function vsandroid.additionalOptions(cfg)
		if _ACTION >= "vs2015" then

		else
			local function alreadyHas(t, key)
				for _, k in ipairs(t) do
					if string.find(k, key) then
						return true
					end
				end
				return false
			end

			if not cfg.architecture or string.startswith(cfg.architecture, "arm") then
				-- we might want to define the arch to generate better code
--				if not alreadyHas(cfg.buildoptions, "-march=") then
--					if cfg.architecture == "armv6" then
--						table.insert(cfg.buildoptions, "-march=armv6")
--					elseif cfg.architecture == "armv7" then
--						table.insert(cfg.buildoptions, "-march=armv7")
--					end
--				end

				-- ARM has a comprehensive set of floating point options
				if cfg.fpu ~= "Software" and cfg.floatabi ~= "soft" then

					if cfg.architecture == "armv7" then

						-- armv7 always has VFP, may not have NEON

						if not alreadyHas(cfg.buildoptions, "-mfpu=") then
							if cfg.vectorextensions == "NEON" then
								table.insert(cfg.buildoptions, "-mfpu=neon")
							elseif cfg.fpu == "Hardware" or cfg.floatabi == "softfp" or cfg.floatabi == "hard" then
								table.insert(cfg.buildoptions, "-mfpu=vfpv3-d16") -- d16 is the lowest common denominator
							end
						end

						if not alreadyHas(cfg.buildoptions, "-mfloat-abi=") then
							if cfg.floatabi == "hard" then
								table.insert(cfg.buildoptions, "-mfloat-abi=hard")
							else
								-- Android should probably use softfp by default for compatibility
								table.insert(cfg.buildoptions, "-mfloat-abi=softfp")
							end
						end

					else

						-- armv5/6 may not have VFP

						if not alreadyHas(cfg.buildoptions, "-mfpu=") then
							if cfg.fpu == "Hardware" or cfg.floatabi == "softfp" or cfg.floatabi == "hard" then
								table.insert(cfg.buildoptions, "-mfpu=vfp")
							end
						end

						if not alreadyHas(cfg.buildoptions, "-mfloat-abi=") then
							if cfg.floatabi == "softfp" then
								table.insert(cfg.buildoptions, "-mfloat-abi=softfp")
							elseif cfg.floatabi == "hard" then
								table.insert(cfg.buildoptions, "-mfloat-abi=hard")
							end
						end

					end

				elseif cfg.floatabi == "soft" then

					table.insert(cfg.buildoptions, "-mfloat-abi=soft")

				end

				if cfg.endian == "Little" then
					table.insert(cfg.buildoptions, "-mlittle-endian")
				elseif cfg.endian == "Big" then
					table.insert(cfg.buildoptions, "-mbig-endian")
				end

			elseif cfg.architecture == "mips" then

				-- TODO...

				if cfg.vectorextensions == "MXU" then
					table.insert(cfg.buildoptions, "-mmxu")
				end

			elseif cfg.architecture == "x86" then

				-- TODO...

			end
		end
	end

--
-- Disable subsystem.
--

	p.override(vc2010, "subSystem", function(oldfn, cfg)
		if cfg.system ~= p.ANDROID then
			return oldfn(cfg)
		end
	end)

--
-- Remove .lib and list in LibraryDependencies instead of AdditionalDependencies.
--

	p.override(vc2010, "additionalDependencies", function(oldfn, cfg, explicit)
		if cfg.system == p.ANDROID then
			local links = {}

			-- If we need sibling projects to be listed explicitly, grab them first
			if explicit then
				links = config.getlinks(cfg, "siblings", "fullpath")
			end

			-- Then the system libraries, which come undecorated
			local system = config.getlinks(cfg, "system", "name")
			for i = 1, #system do
				local link = system[i]
				table.insert(links, link)
			end

			-- TODO: When to use LibraryDependencies vs AdditionalDependencies

			if #links > 0 then
				links = path.translate(table.concat(links, ";"))
				vc2010.element("LibraryDependencies", nil, "%%(LibraryDependencies);%s", links)
			end
		else
			return oldfn(cfg, explicit)
		end
	end)

function android.useMultiToolTask(cfg)
	-- Android equivalent of 'MultiProcessorCompilation'
	if cfg.flags.MultiProcessorCompile then
		vc2010.element("UseMultiToolTask", nil, "true")
	end
end

premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
	if cfg.system == p.ANDROID then
		return table.join(oldfn(cfg), {
			android.useMultiToolTask,
		})
	else
		return oldfn(cfg)
	end
end)

--
-- Disable override of OutDir.  This is breaking deployment.
--

	p.override(vc2010, "outDir", function(oldfn, cfg)
		if cfg.system ~= p.ANDROID then
			return oldfn(cfg)
		end
	end)

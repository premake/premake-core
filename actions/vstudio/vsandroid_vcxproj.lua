--
-- vsandroid_vcxproj.lua
-- vs-android helpers for vstudio.
-- Copyright (c) 2012 Manu Evans and the Premake project
--

	premake.extensions.vsandroid = { }
	local vsandroid = premake.extensions.vsandroid
	local sln2005 = premake.vstudio.sln2005
	local vc2010 = premake.vstudio.vc2010
	local vstudio = premake.vstudio
	local project = premake.project
	local config = premake.config


--
-- Add android tools to vstudio actions.
--

	if vstudio.vs2010_architectures ~= nil then
		vstudio.vs2010_architectures.android = "Android"
	end


--
-- Extend configurationProperties.
--

	table.insertafter(vc2010.elements.configurationProperties, "platformToolset", "androidAPILevel")
	table.insertafter(vc2010.elements.configurationProperties, "androidAPILevel", "androidStlType")

	-- Note: this function is already patched in by vs2012...
	premake.override(vc2010, "platformToolset", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			local defaultToolsetMap = {
				x32 = "x86-4.6",
				armv5 = "arm-linux-androideabi-4.6",
				armv7 = "arm-linux-androideabi-4.6",
				mips = "mipsel-linux-android-4.6",
			}
			local archMap = {
				x32 = "x86",
				armv5 = "armv5te",
				armv7 = "armv7-a",
				mips = "mips",
			}
			-- TODO: use 'toolset' options to select GCC or Clang
			-- TODO: allow the user to select the toolset version somehow
			if cfg.architecture ~= nil and defaultToolsetMap[cfg.architecture] ~= nil then
				_p(2,'<PlatformToolset>%s</PlatformToolset>', defaultToolsetMap[cfg.architecture])
				_p(2,'<AndroidArch>%s</AndroidArch>', archMap[cfg.architecture])
			end
		else
			oldfn(cfg)
		end
	end)

	function vc2010.androidAPILevel(cfg)
		if cfg.system == premake.ANDROID then
			if cfg.androidapilevel ~= nil then
--				_p(2,'<AndroidAPILevel>android-%d</AndroidAPILevel>', cfg.androidapilevel)
			end
		end
	end

	function vc2010.androidStlType(cfg)
		if cfg.system == premake.ANDROID then
			-- TODO: do something about this?
--			_p(2,'<AndroidStlType>stlport_static</AndroidStlType>')
		end
	end


--
-- Extend outputProperties.
--

	premake.override(vc2010, "targetExt", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			local ext = cfg.buildtarget.extension
			if ext ~= "" then
				_x(2,'<TargetExt>%s</TargetExt>', ext)
			end
		else
			oldfn(cfg)
		end
	end)


--
-- Extend clCompile.
--

	table.insert(vc2010.elements.clCompile, "androidDebugInformation")
	table.insert(vc2010.elements.clCompile, "thumbMode")
--	table.insert(vc2010.elements.clCompile, "StrictAliasing")
--	table.insert(vc2010.elements.clCompile, "SoftFloat")
--	table.insert(vc2010.elements.clCompile, "ShortEnums")
--	table.insert(vc2010.elements.clCompile, "PositionIndependentCode")

	premake.override(vc2010, "warningLevel", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			local map = { Off = "DisableAllWarnings", Extra = "AllWarnings" }
			if map[cfg.warnings] ~= nil then
				_p(3,'<Warnings>%s</Warnings>', map[cfg.warnings])
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "treatWarningAsError", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			if cfg.flags.FatalWarnings and cfg.warnings ~= "Off" then
				_p(3,'<WarningsAsErrors>true</WarningsAsErrors>')
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "optimization", function(oldfn, cfg, condition)
		if cfg.system == premake.ANDROID then
			local map = { Off="O0", On="O2", Debug="O0", Full="O3", Size="Os", Speed="O3" }
			local value = map[cfg.optimize]
			if value or not condition then
				vc2010.element(3, 'OptimizationLevel', condition, value or "O0")
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "exceptionHandling", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			-- Note: Android defaults to 'off'
			if not cfg.flags.NoExceptions then
				_p(3,'<GccExceptionHandling>true</GccExceptionHandling>')
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "runtimeTypeInfo", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
			-- Note: Android defaults to 'off'
			if not cfg.flags.NoRTTI then
				_p(3,'<RuntimeTypeInfo>true</RuntimeTypeInfo>')
			end
		else
			oldfn(cfg)
		end
	end)

	function vc2010.androidDebugInformation(cfg)
		if cfg.system == premake.ANDROID then
			if cfg.flags.Symbols then
				_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
			end
		end
	end

	function vc2010.thumbMode(cfg)
		if cfg.system == premake.ANDROID then
			if cfg.flags.EnableThumb then
				_p(3,'<ThumbMode>true</ThumbMode>')
			end
		end
	end


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

	table.insertafter(vc2010.elements.itemDefinitionGroup, "imageXex", "antBuild")

	function vc2010.antBuild(cfg)
		if cfg.system == premake.ANDROID then
			if cfg.kind == premake.STATICLIB or cfg.kind == premake.SHAREDLIB then
				return
			end

			_p(2,'<AntBuild>')
			if premake.config.isDebugBuild(cfg) then
				_p(3,'<AntBuildType>Debug</AntBuildType>')
			else
				_p(3,'<AntBuildType>Release</AntBuildType>')
			end
			_p(2,'</AntBuild>')
		end
	end

	premake.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		if cfg.system == premake.ANDROID then
			vsandroid.additionalOptions(cfg)
		end
		return oldfn(cfg, condition)
	end)


--
-- Add options unsupported by vs-android UI to <AdvancedOptions>.
--
	function vsandroid.additionalOptions(cfg)

		local function alreadyHas(t, key)
			for _, k in ipairs(t) do
				if string.find(k, key) then
					return true
				end
			end
			return false
		end


		-- Flags that are not supported by the vs-android UI may be added manually here...

		-- we might want to define the arch to generate better code
--		if not alreadyHas(cfg.buildoptions, "-march=") then
--			if cfg.architecture == "armv6" then
--				table.insert(cfg.buildoptions, "-march=armv6")
--			elseif cfg.architecture == "armv7" then
--				table.insert(cfg.buildoptions, "-march=armv7")
--			end
--		end

		-- Android has a comprehensive set of floating point options
		if not cfg.flags.SoftwareFloat and cfg.floatabi ~= "soft" then

			if cfg.architecture == "armv7" then

				-- armv7 always has VFP, may not have NEON

				if not alreadyHas(cfg.buildoptions, "-mfpu=") then
					if cfg.vectorextensions ~= nil and cfg.vectorextensions == "NEON" then
						table.insert(cfg.buildoptions, "-mfpu=neon")
					elseif cfg.flags.HardwareFloat or cfg.floatabi == "softfp" or cfg.floatabi == "hard" then
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
					if cfg.flags.HardwareFloat or cfg.floatabi == "softfp" or cfg.floatabi == "hard" then
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

--		if cfg.flags.LittleEndian then
--			table.insert(cfg.buildoptions, "-mlittle-endian")
--		elseif cfg.flags.BigEndian then
--			table.insert(cfg.buildoptions, "-mbig-endian")
--		end

	end

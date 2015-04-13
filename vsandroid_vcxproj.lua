--
-- android/vsandroid_vcxproj.lua
-- vs-android integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	p.modules.vsandroid = { }

	local android = p.modules.android
	local vsandroid = p.modules.vsandroid
	local sln2005 = p.vstudio.sln2005
	local vc2010 = p.vstudio.vc2010
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config


--
-- Add android tools to vstudio actions.
--

	if vstudio.vs2010_architectures ~= nil then
		vstudio.vs2010_architectures.android = "Android"
	end


--
-- Extend configurationProperties.
--

	premake.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY and cfg.system == premake.ANDROID then
			elements = table.join(elements, {
				android.androidAPILevel,
				android.androidStlType,
			})
		end
		return elements
	end)

	function android.androidAPILevel(cfg)
		if cfg.androidapilevel ~= nil then
			_p(2,'<AndroidAPILevel>android-%d</AndroidAPILevel>', cfg.androidapilevel)
		end
	end

	function android.androidStlType(cfg)
		if cfg.stl ~= nil then
			local static = {
				none       = "none",
				minimal    = "system",
				["stdc++"] = "gnustl_static",
				stlport    = "stlport_static",
			}
			local dynamic = {
				none       = "none",
				minimal    = "system",
				["stdc++"] = "gnustl_dynamic",
				stlport    = "stlport_dynamic",
			}
			local stl = iif(cfg.flags.StaticRuntime, static, dynamic);
			_p(2,'<AndroidStlType>%s</AndroidStlType>', stl[cfg.stl])
		end
	end

	-- Note: this function is already patched in by vs2012...
	premake.override(vc2010, "platformToolset", function(oldfn, cfg)
		if cfg.system == premake.ANDROID then
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

				_p(2,'<PlatformToolset>%s</PlatformToolset>', toolset .. version)
				_p(2,'<AndroidArch>%s</AndroidArch>', archMap[arch])
			end
		else
			oldfn(cfg)
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
				android.thumbMode,
				android.fpu,
				android.pic,
--				android.ShortEnums,
			})
		end
		return elements
	end)

	function android.debugInformation(cfg)
		if cfg.flags.Symbols then
			_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
		end
	end

	function android.strictAliasing(cfg)
		if cfg.strictaliasing ~= nil then
			_p(3,'<StrictAliasing>%s</StrictAliasing>', iif(cfg.strictaliasing == "Off", "false", "true"))
		end
	end

	function android.thumbMode(cfg)
		if cfg.flags.Thumb then
			_p(3,'<ThumbMode>true</ThumbMode>')
		end
	end

	function android.fpu(cfg)
		if cfg.fpu ~= nil then
			_p(3,'<SoftFloat>true</SoftFloat>', iif(cfg.fpu == "Software", "true", "false"))
		end
	end

	function android.pic(cfg)
		-- TODO: We only have a flag to turn it on, but android is on by default
		--       it seems we would rather have a flag to turn it off...
--		if cfg.pic ~= nil then
--			_p(3,'<PositionIndependentCode>%s</PositionIndependentCode>', iif(cfg.pic == "On", "true", "false"))
--		end
	end

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
		if cfg.system == premake.ANDROID then
			elements = table.join(elements, {
				android.antBuild,
			})
		end
		return elements
	end)

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

		if not cfg.architecture or string.startswith(cfg.architecture, "arm") then
			-- we might want to define the arch to generate better code
--			if not alreadyHas(cfg.buildoptions, "-march=") then
--				if cfg.architecture == "armv6" then
--					table.insert(cfg.buildoptions, "-march=armv6")
--				elseif cfg.architecture == "armv7" then
--					table.insert(cfg.buildoptions, "-march=armv7")
--				end
--			end

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

--
-- xbox360/xbox360_vcxproj.lua
-- Xbox 360 integration for vstudio.
-- Author: Emilio López
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake

	local xbox360 = p.modules.xbox360
	local vc2010 = p.vstudio.vc2010
	local vc200x = p.vstudio.vc200x
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config


--
-- Add Xbox 360 tools to vstudio actions.
--

	if vstudio.vs2010_architectures ~= nil then
		-- Interestingly the Xbox 360 XDK requires VS2010 to be installed but works on any Visual Studio version
		vstudio.vs2010_architectures.xbox360 = "Xbox 360"
	end
	
--
-- Extend globals
--

	-- TODO We need to do per config global here
	premake.override(vc2010, "keyword", function(oldfn, cfg)
	
		if cfg.system == premake.XBOX360 then			
			vc2010.element("Keyword", nil, "Xbox360Proj")
		else
			return oldfn(cfg)
		end
	
	end)
	
	
--
-- Extend configurationProperties.
--

	premake.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY and cfg.system == premake.XBOX360 then
			elements = table.join(elements, {
				xbox360.imageXexOutput,
			})
		end
		return elements
	end)
	
	function xbox360.imageXexOutput(cfg)	
		if cfg.xexoutput ~= nil then
			vc2010.element("ImageXexOutput", nil, "%s", cfg.xexoutput)
		end
	end
	
--
-- Depolyment Configuration
--
	
	function xbox360.deployConfig(cfg)
		p.push('<Deploy>')
		
		if cfg.deployment ~= nil then
			if cfg.deployment == "copytohdd" then
				vc2010.element("DeploymentType", nil, "CopyToHardDrive")
			elseif cfg.deployment == "emulatehdd" then
				vc2010.element("DeploymentType", nil, "EmulateHardDrive")
			end
		end
		
		if cfg.nostartupbanner ~= nil then
			vc2010.element("SuppressStartupBanner", nil, iif(cfg.nostartupbanner, "true", "false"))
		end
		
		if cfg.buildnodeploy ~= nil then
			vc2010.element("ExcludedFromBuild", nil, iif(cfg.buildnodeploy, "true", "false"))
		end
		
		if cfg.showdeployprogress ~= nil then
			vc2010.element("Progress", nil, iif(cfg.showdeployprogress, "true", "false"))
		end
		
		if cfg.deployforce ~= nil then
			vc2010.element("ForceCopy", nil, iif(cfg.deployforce, "true", "false"))
		end
		
		if cfg.dvdemulationtype ~= nil then
			local value = nil
			if cfg.dvdemulationtype == "zero" then
				value = "ZeroSeekTimes"
			elseif cfg.dvdemulationtype == "typical" then
				value = "TypicalSeekTimes"
			elseif cfg.dvdemulationtype == "accurate" then
				value = "AccurateSeekTimes"
			end
			
			if value then
				vc2010.element("DvdEmulationType", nil, value)
			end
		end
		
		if cfg.deploymentfiles ~= nil then
			vc2010.element("DeploymentFiles", nil, cfg.deploymentfiles)
		else
			vc2010.element("DeploymentFiles", nil, "$(RemoteRoot)=$(ImagePath);")
		end
		
		p.pop('</Deploy>')
	end
	
	function xbox360.deploymentroot(cfg)
		if cfg.deploymentroot ~= nil then
			_p(2,'<RemoteRoot>%s</RemoteRoot>', cfg.deploymentroot)
		end
	end
	
	premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.system == premake.XBOX360 then
			elements = table.join(elements, {
				xbox360.deploymentroot,
			})
		end
		return elements
	end)
	
--
-- Xex Image Configuration
--
	
	function xbox360.imageXex(cfg)
		p.push('<ImageXex>')
		
		if cfg.configfile ~= nil then
			vc2010.element("ConfigurationFile", nil, "%s", cfg.configfile)
		end
		
		if cfg.titleid ~= nil then
			vc2010.element("TitleID", nil, "%s", tostring(cfg.titleid))
		end
		
		if cfg.lankey ~= nil then
			vc2010.element("LanKey", nil, "%s", tostring(cfg.lankey))
		end
		
		if cfg.baseaddress ~= nil then
			vc2010.element("BaseAddress", nil, "%s", cfg.baseaddress)
		end
		
		if cfg.heapsize ~= nil then
			vc2010.element("HeapSize", nil, "%s", cfg.heapsize)
		end
		
		if cfg.workspacesize ~= nil then
			vc2010.element("WorkspaceSize", nil, "%s", cfg.workspacesize)
		end
		
		if cfg.additionalsections ~= nil then
			vc2010.element("AdditionalSections", nil, "%s", cfg.additionalsections)
		end
		
		if cfg.exportbyname ~= nil then
			vc2010.element("ExportByName", nil, "%s", iif(cfg.exportbyname, "true", "false"))
		end
		
		if cfg.opticaldiscdrivemapping ~= nil then
			vc2010.element("OpticalDiscDriveMapping", nil, "%s", iif(cfg.opticaldiscdrivemapping, "true", "false"))
		end
		
		if cfg.pal50incompatible ~= nil then
			vc2010.element("Pal50Incompatible", nil, "%s", iif(cfg.pal50incompatible, "true", "false"))
		end
		
		if cfg.multidisctitle ~= nil then
			vc2010.element("MultiDiscTitle", nil, "%s", iif(cfg.multidisctitle, "true", "false"))
		end
		
		if cfg.preferbigbuttoninput ~= nil then
			vc2010.element("PreferBigButtonInput", nil, "%s", iif(cfg.preferbigbuttoninput, "true", "false"))
		end
		
		if cfg.crossplatformsystemlink ~= nil then
			vc2010.element("CrossPlatformSystemLink", nil, "%s", iif(cfg.crossplatformsystemlink, "true", "false"))
		end
		
		if cfg.allowavatargetmetadata ~= nil then
			vc2010.element("AllowAvatarGetMetadata", nil, "%s", iif(cfg.allowavatargetmetadata, "true", "false"))
		end
		
		if cfg.allowcontrollerswapping ~= nil then
			vc2010.element("AllowControllerSwapping", nil, "%s", iif(cfg.allowcontrollerswapping, "true", "false"))
		end
		
		if cfg.requirefullexperience ~= nil then
			vc2010.element("RequireFullExperience", nil, "%s", iif(cfg.requirefullexperience, "true", "false"))
		end
		
		if cfg.gamevoicerequiredui ~= nil then
			vc2010.element("GameVoiceRequiredUI", nil, "%s", iif(cfg.gamevoicerequiredui, "true", "false"))
		end
		
		p.pop('</ImageXex>')
	end
	
	premake.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY and cfg.system == premake.XBOX360 then
			elements = table.join(elements, {
				xbox360.deployConfig,
				xbox360.imageXex,
			})
		end
		return elements
	end)

	
	-- If any value is specified it confuses Visual Studio into thinking it's not an Xbox 360 project
	premake.override(vc2010, "platformToolset", function(oldfn, cfg)
		if cfg.system ~= premake.XBOX360 then
			return oldfn(cfg)
		end
	end)
	
--
-- Extend clCompile
--

	premake.override(vc2010.elements, "clCompile", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.system == premake.XBOX360 then
			elements = table.join(elements, {
				xbox360.registerReservation,
				xbox360.analyzeStalls,
				xbox360.callAttributedProfiling,
				xbox360.trapIntegerDivides,
				xbox360.prescheduling,
				xbox360.inlineAssembly,
			})
		end
		return elements
	end)
	
	function xbox360.registerReservation(cfg)
		if cfg.registerreservation then
			_p(3,'<RegisterReservation>%s</RegisterReservation>', cfg.registerreservation)
		end
	end
	
	function xbox360.analyzeStalls(cfg)
		if cfg.analyzestalls then
			_p(3,'<AnalyzeStalls>%s</AnalyzeStalls>', cfg.analyzestalls)
		end
	end
	
	function xbox360.callAttributedProfiling(cfg)
		if cfg.callattributedprofiling then
			_p(3,'<CallAttributedProfiling>%s</CallAttributedProfiling>', cfg.callattributedprofiling:gsub("^%l", string.upper))
		end
	end
	
	function xbox360.trapIntegerDivides(cfg)
		if cfg.trapintegerdivides then
			_p(3,'<TrapIntegerDividesOptimization>%s</TrapIntegerDividesOptimization>', cfg.trapintegerdivides)
		end
	end
	
	function xbox360.prescheduling(cfg)
		if cfg.prescheduling then
			_p(3,'<PreschedulingOptimization>%s</PreschedulingOptimization>', cfg.prescheduling)
		end
	end
	
	function xbox360.inlineAssembly(cfg)
		if cfg.inlineassembly then
			_p(3,'<InlineAssemblyOptimization>%s</InlineAssemblyOptimization>', cfg.inlineassembly)
		end
	end
	
	
--
-- Target extension
--
	
	premake.override(vc2010, "targetExt", function(oldfn, cfg)
	
		local ext = cfg.buildtarget.extension

		if cfg.system == premake.XBOX360 and ext == '' then
		
			if cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp" then
				cfg.buildtarget.extension = ".exe"
			elseif cfg.kind == "StaticLib" then
				cfg.buildtarget.extension = ".lib"
			elseif cfg.kind == "SharedLib" then
				cfg.buildtarget.extension = ".dll"
			end
			
		end
		
		oldfn(cfg) -- Call the original function with the new arguments
	
	end)
	
--
-- Extend Link
--

	-- Xbox 360 doesn't support things like EditAndContinue so just set the appropriate subset
	premake.override(vc2010, "debugInformationFormat", function(oldfn, cfg)
	
		if cfg.system == premake.XBOX360 then		
		
			if (cfg.symbols == p.ON) or (cfg.symbols == "FastLink") then
				if cfg.debugformat == "c7" then
					value = "OldStyle"
				else
					value = "ProgramDatabase"
				end

				vc2010.element("DebugInformationFormat", nil, value)
			elseif cfg.symbols == p.OFF then
				-- leave field blank for vs2013 and older to workaround bug
				if _ACTION < "vs2015" then
					value = ""
				else
					value = "None"
				end

				vc2010.element("DebugInformationFormat", nil, value)
			end
			
		else
			oldfn(cfg)
		end
	end)
	
	-- Skip resource compile
	premake.override(vc2010, "resourceCompile", function(oldfn, cfg)	
		if cfg.system ~= premake.XBOX360 then
			oldfn(cfg)
		end
	end)
	
	-- Skip subsystem
	premake.override(vc2010, "subSystem", function(oldfn, cfg)	
		if cfg.system ~= premake.XBOX360 then
			oldfn(cfg)
		end
	end)

--
-- Extend Tools (applies to vs200x only)
--
	
	premake.override(vc200x.elements, "tools", function(oldfn, cfg)
	
		if cfg.system == premake.XBOX360 then
			if vstudio.isMakefile(cfg) and not cfg.fake then
				return { vc200x.VCNMakeTool }
			end
		
			return {
				-- Use a subset of the common set of tools
				vc200x.VCPreBuildEventTool,
				vc200x.VCCustomBuildTool,
				vc200x.VCXMLDataGeneratorTool,
				vc200x.VCWebServiceProxyGeneratorTool,
				vc200x.VCMIDLTool,
				vc200x.VCCLCompilerTool,
				vc200x.VCManagedResourceCompilerTool,
				vc200x.VCResourceCompilerTool,
				vc200x.VCPreLinkEventTool,
				vc200x.VCLinkerTool,
				vc200x.VCALinkTool,				
				vc200x.VCBscMakeTool,
				vc200x.VCPostBuildEventTool,
				vc200x.DebuggerTool,
				
				-- 360 specific
				xbox360.VCX360ImageTool,
				xbox360.VCX360DeploymentTool,
			}
		else
			return oldfn(cfg)
		end
	end)

	xbox360.VCX360ImageTool = function(cfg)
		return {
			vc200x.additionalImageOptions,
			vc200x.outputFileName,
		}
	end

	function xbox360.VCX360ImageTool(cfg)
		vc200x.VCTool("VCX360ImageTool", cfg)
	end

	xbox360.VCX360DeploymentTool = function(cfg)
		return {
			vc200x.deploymentType,
			vc200x.additionalDeploymentOptions,
		}
	end

	function xbox360.VCX360DeploymentTool(cfg)
		vc200x.VCTool("VCX360DeploymentTool", cfg)
	end
	
	premake.override(vc200x, "VCCLCompilerToolName", function(oldfn, cfg)	
		local prjcfg, filecfg = config.normalize(cfg)			
		if prjcfg and prjcfg.system == premake.XBOX360 then	
			if filecfg and fileconfig.hasCustomBuildRule(filecfg) then
				return "VCCustomBuildTool"
			else
				return "VCCLX360CompilerTool"
			end
		else
			return oldfn(cfg)
		end			
	end)
	
	premake.override(vc200x, "VCLinkerToolName", function(oldfn, cfg)
		if cfg.system == p.XBOX360 then	
			if cfg.kind == p.STATICLIB then
				return "VCLibrarianTool"
			else
				return "VCX360LinkerTool"
			end
		else
			return oldfn(cfg)
		end
	end)

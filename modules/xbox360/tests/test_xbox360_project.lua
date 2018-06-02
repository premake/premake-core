	local p = premake
	local suite = test.declare("test_xbox360_project")
	local xbox360 = p.modules.xbox360
	local vc2010 = p.vstudio.vc2010
	local vc200x = p.vstudio.vc200x
	local config = p.config
	local sln2005 = p.vstudio.sln2005

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks, prj = test.createWorkspace()
	end
	
	local function preparePlatform()
		local cfg = test.getconfig(prj, "Debug")
		return config.gettargetinfo(cfg)
	end
	
	function suite.nameUsesExe_onXbox360ConsoleApp()
		kind "ConsoleApp"
		system "Xbox360"
		i = preparePlatform()
		test.isequal("MyProject.exe", i.name)
	end
    
	function suite.nameUsesLib_onXbox360StaticLib()
		kind "StaticLib"
		system "Xbox360"
		i = preparePlatform()
		test.isequal("MyProject.lib", i.name)
	end

--
-- Xbox 360 doesn't list a subsystem or entry point.
--

	local function prepareLinker(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.linker(cfg)
	end

	function suite.onXbox360()
		kind "ConsoleApp"
		system "Xbox360"
		prepareLinker()
		test.capture [[
		]]
	end

--
-- Xbox 360 uses .lib for library extensions
--
	function suite.libAdded_onXbox360SystemLibs()
		kind "ConsoleApp"
		system "Xbox360"
		links { "user32" }
		prepareLinker()
		test.capture [[
<Link>
	<AdditionalDependencies>user32.lib;%(AdditionalDependencies)</AdditionalDependencies>
</Link>
		]]
	end
	
--
-- Xbox360 adds an extra <OutputFile> element to the block.
--

	local function prepareOutputProperties()
		local cfg = test.getconfig(prj, "Debug", "Xbox 360")
		vc2010.outputProperties(cfg)
	end

	function suite.structureIsCorrect_onXbox360()
		configurations { "Debug" }
		platforms { "Xbox 360" }
		system "xbox360"
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Xbox 360'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Xbox 360\Debug\</OutDir>
	<IntDir>obj\Xbox 360\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
</PropertyGroup>
		]]
	end

	function suite.staticLibStructureIsCorrect_onXbox360()
		kind "StaticLib"
		configurations { "Debug" }
		platforms { "Xbox 360" }
		system "Xbox360"
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Xbox 360'">
	<OutDir>bin\Xbox 360\Debug\</OutDir>
	<IntDir>obj\Xbox 360\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.lib</TargetExt>
</PropertyGroup>
		]]
	end
	
	
	function suite.skips_onXbox360()
		files { "hello.rc" }
		defines { "DEBUG" }
		system "Xbox360"
		local cfg = test.getconfig(prj, "Debug")
		vc2010.resourceCompile(cfg)
		test.isemptycapture()
	end

--
-- Xex Properties
--	
	
	local function prepareXex(platform)
		local cfg = test.getconfig(prj, "Debug", "Xbox 360")
		xbox360.imageXex(cfg)
	end

--
-- Test default ImageXex settings
--
	function suite.defaultSettings()
		configurations { "Debug" }
		platforms { "Xbox 360" }
		prepareXex()
		test.capture [[
<ImageXex>
</ImageXex>
		]]
	end

--
-- Ensure configuration file is output in ImageXex block
--
	function suite.imageXex()
		configurations { "Debug" }
		platforms { "Xbox 360" }
	
		configfile("testconfig.xml")
		xexoutput("test_output.xex")
		titleid("0x1234567")
		lankey("01020304050607080910AABBCCDDEEFF")
		baseaddress("0x88000000")
		heapsize("0x1234567")
		workspacesize("0x1234567")
		additionalsections("font=$(OutDir)\\test.xpr,R")
		exportbyname("true")
		opticaldiscdrivemapping("false")
		pal50incompatible("true")
		multidisctitle("false")
		preferbigbuttoninput("true")
		crossplatformsystemlink("false")
		allowavatargetmetadata("true")
		allowcontrollerswapping("false")
		requirefullexperience("true")
		gamevoicerequiredui("false")
		
		prepareXex()
		test.capture [[
<ImageXex>
	<ConfigurationFile>testconfig.xml</ConfigurationFile>
	<TitleID>0x1234567</TitleID>
	<LanKey>01020304050607080910AABBCCDDEEFF</LanKey>
	<BaseAddress>0x88000000</BaseAddress>
	<HeapSize>0x1234567</HeapSize>
	<WorkspaceSize>0x1234567</WorkspaceSize>
	<AdditionalSections>font=$(OutDir)\test.xpr,R</AdditionalSections>
	<ExportByName>true</ExportByName>
	<OpticalDiscDriveMapping>false</OpticalDiscDriveMapping>
	<Pal50Incompatible>true</Pal50Incompatible>
	<MultiDiscTitle>false</MultiDiscTitle>
	<PreferBigButtonInput>true</PreferBigButtonInput>
	<CrossPlatformSystemLink>false</CrossPlatformSystemLink>
	<AllowAvatarGetMetadata>true</AllowAvatarGetMetadata>
	<AllowControllerSwapping>false</AllowControllerSwapping>
	<RequireFullExperience>true</RequireFullExperience>
	<GameVoiceRequiredUI>false</GameVoiceRequiredUI>
</ImageXex>
		]]
	end
	

--
-- If the platform identifier matches a system or architecture, omit it
-- from the configuration description.
--

	function suite.onSingleCpp_withPlatformsMatchingArch_noArchs()
		
		local testWorkspace = workspace("MyWorkspace")
		
		configurations { "Debug", "Release" }
		platforms { "Win32", "Xbox 360" }
		
		filter {"platforms:Xbox 360"}
			system("xbox360")
		filter{}

		project "MyProject"
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"
		wks = test.getWorkspace(wks)
		sln2005.configurationPlatforms(wks)
		test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|Win32 = Debug|Win32
	Debug|Xbox 360 = Debug|Xbox 360
	Release|Win32 = Release|Win32
	Release|Xbox 360 = Release|Xbox 360
EndGlobalSection
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.ActiveCfg = Debug|Win32
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.Build.0 = Debug|Win32
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Xbox 360.ActiveCfg = Debug|Xbox 360
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Xbox 360.Build.0 = Debug|Xbox 360
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.ActiveCfg = Release|Win32
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.Build.0 = Release|Win32
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Xbox 360.ActiveCfg = Release|Xbox 360
	{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Xbox 360.Build.0 = Release|Xbox 360
EndGlobalSection
		]]
	end
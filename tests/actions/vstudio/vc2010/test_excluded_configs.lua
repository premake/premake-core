--
-- tests/actions/vstudio/vc2010/test_excluded_configs.lua
-- Check handling of configurations which have been excluded from the build.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vs2010_excluded_configs = {}
	local suite = T.vs2010_excluded_configs
	local vc2010 = premake.vstudio.vc2010


--
-- Setup/teardown
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2010"
		
		sln = solution("MySolution")
		configurations { "Debug", "Release" }
		platforms { "Zeus", "Ares" }
		language "C++"
		
		prj = project("MyProject")
		kind "ConsoleApp"
		links { "MyProject2", "MyProject3" }
		
		project("MyProject2")
		kind "StaticLib"
		
		project("MyProject3")
		kind "StaticLib"
		removeplatforms { "Ares" }
	end

	local function prepare(platform)
		local cfg = premake5.project.getconfig(prj, "Debug", platform)
		vc2010.Link(cfg)
	end



--
-- If a sibling is included in one configuration and excluded from
-- another, the included configuration should link as normal.
--

	function suite.normalLink_onIncludedConfig()
		prepare("Zeus")
		test.capture [[
		<Link>
			<SubSystem>Console</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		</Link>
		]]
	end

	function suite.normalLink_onIncludedConfig_externalTool()
		solution("MySolution")
		system "PS3"
		prepare("Zeus")
		test.capture [[
		<Link>
			<SubSystem>Console</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		</Link>
		]]
	end


--
-- If a sibling is included in one configuration and excluded from
-- another, the excluded configuration should force explicit linking
-- and not list the excluded library.
--

	function suite.explicitLink_onExcludedConfig()
		prepare("Ares")
		test.capture [[
		<Link>
			<SubSystem>Console</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>MyProject2.lib;%(AdditionalDependencies)</AdditionalDependencies>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		</Link>
		<ProjectReference>
			<LinkLibraryDependencies>false</LinkLibraryDependencies>
		</ProjectReference>
		]]
	end

	function suite.explicitLink_onExcludedConfig_externalTool()
		solution("MySolution")
		system "PS3"
		prepare("Ares")
		test.capture [[
		<Link>
			<SubSystem>Console</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>libMyProject2.a;%(AdditionalDependencies)</AdditionalDependencies>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		</Link>
		<ProjectReference>
			<LinkLibraryDependencies>false</LinkLibraryDependencies>
		</ProjectReference>
		]]
	end

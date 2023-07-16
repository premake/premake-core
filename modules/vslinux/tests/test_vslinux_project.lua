	local p = premake
	local suite = test.declare("test_vslinux_project")
	local vc2010 = p.vstudio.vc2010
	local linux = p.modules.linux

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2022")
		system "linux"
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.clCompile(cfg)
	end

	local function prepareGlobals()
		prj = test.getproject(wks, 1)
		vc2010.globals(prj)
	end

	local function prepareOutputProperties()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	function suite.minVisualStudioVersion_17()
		prepareGlobals()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Linux</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<MinimumVisualStudioVersion>17.0</MinimumVisualStudioVersion>
	<ApplicationType>Linux</ApplicationType>
	<TargetLinuxPlatform>Generic</TargetLinuxPlatform>
	<ApplicationTypeRevision>1.0</ApplicationTypeRevision>]]
	end

	function suite.noOptions()
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOff()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOn()
		rtti "On"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.exceptionHandlingOff()
		exceptionhandling "Off"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>Disabled</ExceptionHandling>
</ClCompile>]]
	end

	function suite.exceptionHandlingOn()
		exceptionhandling "On"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>Enabled</ExceptionHandling>
]]
	end

	function suite.cppdialect_cpp11()
		cppdialect "C++11"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<CppLanguageStandard>c++11</CppLanguageStandard>
]]
	end

	function suite.cppdialect_cpp14()
		cppdialect "C++14"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<CppLanguageStandard>c++14</CppLanguageStandard>
]]
	end

	function suite.cppdialect_cpp17()
		cppdialect "C++17"
		prepare()
		test.capture [[
<ClCompile>
	<Optimization>Disabled</Optimization>
	<CppLanguageStandard>c++17</CppLanguageStandard>
]]
	end

	function suite.externalIncludeDirs()
		externalincludedirs { "externalincludedirs" }
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Linux'">
	<LinkIncremental>true</LinkIncremental>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>
	</TargetExt>
	<IncludePath>externalincludedirs;$(IncludePath)</IncludePath>
]]
	end

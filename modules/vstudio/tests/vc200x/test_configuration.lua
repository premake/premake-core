--
-- tests/actions/vstudio/vc200x/test_configuration.lua
-- Test the Visual Studio 2002-2008 project's Configuration block
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vc200x_configuration")
	local vstudio = p.vstudio
	local vc200x = p.vstudio.vc200x
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug", (prj.platforms or wks.platforms or {})[1])
		vc200x.configuration(cfg, vstudio.projectConfig(cfg))
	end


--
-- Check the results of generating with the default project settings
-- (C++ console application).
--

	function suite.defaultSettings()
		prepare()
		test.capture [[
<Configuration
	Name="Debug|Win32"
	OutputDirectory="bin\Debug"
	IntermediateDirectory="obj\Debug"
	ConfigurationType="1"
	CharacterSet="1"
	>
		]]
	end


--
-- If a platform is specified, it should be included in the platform name.
--

	function suite.usesWin32_onX86()
		workspace("MyWorkspace")
		platforms { "x86" }
		prepare()
		test.capture [[
<Configuration
	Name="Debug|Win32"
		]]
	end


--
-- Check the x64 architecture handling.
--

	function suite.usesX64Architecture_onX86_64Platform()
		platforms { "x86_64" }
		prepare()
		test.capture [[
<Configuration
	Name="Debug|x64"
		]]
	end


--
-- The output directory should use backslashes
--

	function suite.escapesOutputDir()
		targetdir("../bin")
		prepare()
		test.capture [[
<Configuration
	Name="Debug|Win32"
	OutputDirectory="..\bin"
		]]
	end


--
-- Makefiles set the configuration type and drop the
-- character encoding.
--

	function suite.defaultSettings_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
<Configuration
	Name="Debug|Win32"
	OutputDirectory="bin\Debug"
	IntermediateDirectory="obj\Debug"
	ConfigurationType="0"
	>
		]]
	end

	function suite.defaultSettings_onNone()
		kind "None"
		prepare()
		test.capture [[
<Configuration
	Name="Debug|Win32"
	OutputDirectory="bin\Debug"
	IntermediateDirectory="obj\Debug"
	ConfigurationType="0"
	>
		]]
	end

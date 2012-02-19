--
-- tests/actions/vstudio/vc200x/test_configuration.lua
-- Test the Visual Studio 2002-2008 project's Configuration block
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_vc200x_configuration = { }
	local suite = T.vstudio_vc200x_configuration
	local vc200x = premake.vstudio.vc200x


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2008"
		sln, prj = test.createsolution()
		sln.platforms = {}
	end
	
	local function prepare()
		local cfg = premake5.project.getconfig(prj, "Debug", sln.platforms[1])
		vc200x.configuration(cfg)
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
			OutputDirectory="."
			IntermediateDirectory="obj\Debug"
			ConfigurationType="1"
			CharacterSet="2"
			>
		]]
	end


--
-- If a platform is specified, it should be included in the platform name.
--

	function suite.usesWin32_onX32()
		solution "MySolution"
		platforms { "x32" }
		prepare()
		test.capture [[
		<Configuration
			Name="Debug x32|Win32"
		]]
	end


--
-- Check the x64 architecture handling.
--

	function suite.usesX64Architecture_onX64Platform()
		solution "MySolution"
		platforms { "x64" }
		prepare()
		test.capture [[
		<Configuration
			Name="Debug x64|x64"
		]]
	end


--
-- The output directory should use backslashes
--

	function suite.usesX64Architecture_onX64Platform()
		targetdir("../bin")
		prepare()
		test.capture [[
		<Configuration
			Name="Debug|Win32"
			OutputDirectory="..\bin"
		]]
	end

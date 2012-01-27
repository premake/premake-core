--
-- tests/actions/vstudio/vc2010/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_globals = { }
	local suite = T.vstudio_vs2010_globals
	local vc2010 = premake.vstudio.vc2010


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
	end
	
	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		vc2010.globals(prj)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<PropertyGroup Label="Globals">
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<Keyword>Win32Proj</Keyword>
		<RootNamespace>MyProject</RootNamespace>
	</PropertyGroup>
		]]
	end

--
-- Ensure CLR support gets enabled for Managed C++ projects.
--

	function suite.keywordIsCorrect_onManagedC()
		flags { "Managed" }
		prepare()
		test.capture [[
	<PropertyGroup Label="Globals">
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
		<Keyword>ManagedCProj</Keyword>
		<RootNamespace>MyProject</RootNamespace>
	</PropertyGroup>
		]]
	end


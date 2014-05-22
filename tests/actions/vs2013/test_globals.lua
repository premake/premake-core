--
-- tests/actions/vs2013/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2013_globals")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2013"
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
		vc2010.globals(prj)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<PropertyGroup Label="Globals">
		<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
		<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
		<Keyword>Win32Proj</Keyword>
		<RootNamespace>MyProject</RootNamespace>
	</PropertyGroup>
		]]
	end

--
-- tests/actions/vstudio/vc2012/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2012_globals = { }
	local suite = T.vstudio_vs2012_globals
	local vc2010 = premake.vstudio.vc2010


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2012"
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
		<VCTargetsPath Condition="'$(VCTargetsPath11)' != '' and '$(VSVersion)' == '' and '$(VisualStudioVersion)' == ''">$(VCTargetsPath11)</VCTargetsPath>
		<RootNamespace>MyProject</RootNamespace>
	</PropertyGroup>
		]]
	end

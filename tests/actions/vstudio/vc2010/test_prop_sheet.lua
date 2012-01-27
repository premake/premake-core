--
-- tests/actions/vstudio/vc2010/test_prop_sheet.lua
-- Validate generation of the property sheet import groups.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_prop_sheet = { }
	local suite = T.vstudio_vs2010_prop_sheet
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup 
--

	local sln, prj, cfg
	
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = project.getconfig(prj, "Debug")
		vc2010.propertySheet(cfg)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
	</ImportGroup>
		]]
	end

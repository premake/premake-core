--
-- tests/actions/vstudio/cs2005/test_compiler_props.lua
-- Test the compiler flags of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_compiler_props = {}
	local suite = T.vstudio_cs2005_compiler_props
	local cs2005 = premake.vstudio.cs2005
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2005"
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		local cfg = project.getconfig(prj, "Debug")
		cs2005.compilerProps(cfg)
	end


--
-- Check handling of defines.
--

	function suite.defineConstants_onDefines()
		defines { "DEBUG", "TRACE" }
		prepare()
		test.capture [[
		<DefineConstants>DEBUG;TRACE</DefineConstants>
		]]
	end


--
-- Check handling of the Unsafe flag.
--

	function suite.allowUnsafeBlocks_onUnsafeFlag()
		flags { "Unsafe" }
		prepare()
		test.capture [[
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
		]]
	end


--
-- Check handling of FatalWarnings flag.
--


	function suite.treatWarningsAsErrors_onFatalWarningsFlag()
		flags { "FatalWarnings" }
		prepare()
		test.capture [[
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<TreatWarningsAsErrors>true</TreatWarningsAsErrors>
		]]
	end

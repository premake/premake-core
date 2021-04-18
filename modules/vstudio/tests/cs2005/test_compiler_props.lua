--
-- tests/actions/vstudio/cs2005/test_compiler_props.lua
-- Test the compiler flags of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_compiler_props")
	local dn2005 = p.vstudio.dotnetbase
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.compilerProps(cfg)
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
		clr "Unsafe"
		prepare()
		test.capture [[
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
		]]
	end

	function suite.allowUnsafeBlocks_onUnsafeFlagNonConfigOnNetcore()
		dotnetframework "netcoreapp3.1"
		clr "Unsafe"
		prepare()
		test.capture [[
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
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

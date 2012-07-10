--
-- tests/actions/vstudio/cs2005/test_flags.lua
-- Test the build flags block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_flags = {}
	local suite = T.vstudio_cs2005_flags
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
		cs2005.flags(cfg)
	end


--
-- Check the handling of the Symbols flag.
--

	function suite.debugSymbols_onNoSymbolsFlag()
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		]]
	end

	function suite.debugSymbols_onSymbolsFlag()
		flags { "Symbols" }
		prepare()
		test.capture [[
		<DebugSymbols>true</DebugSymbols>
		<DebugType>full</DebugType>
		<Optimize>false</Optimize>
		]]
	end


--
-- Check handling of optimization flags.
--

	function suite.optimize_onOptimizeFlag()
		flags { "Optimize" }
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSizeFlag()
		flags { "OptimizeSize" }
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSpeedFlag()
		flags { "OptimizeSpeed" }
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end


--
-- Check handling of the output directory.
--

	function suite.outputDirectory_onTargetDir()
		targetdir "../build"
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		<OutputPath>../build</OutputPath>
		]]
	end


--
-- Check handling of defines.
--

	function suite.defineConstants_onDefines()
		defines { "DEBUG", "TRACE" }
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		<OutputPath>.</OutputPath>
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
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		<OutputPath>.</OutputPath>
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
	</PropertyGroup>
		]]
	end


--
-- Check handling of FatalWarnings flag.
--


	function suite.treatWarningsAsErrors_onFatalWarningsFlag()
		flags { "FatalWarnings" }
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		<OutputPath>.</OutputPath>
		<DefineConstants></DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<TreatWarningsAsErrors>true</TreatWarningsAsErrors>
	</PropertyGroup>
		]]
	end

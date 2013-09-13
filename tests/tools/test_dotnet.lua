--
-- tests/tools/test_dotnet.lua
-- Automated test suite for the .NET toolset interface.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.tools_dotnet = {}
	local suite = T.tools_dotnet
	local dotnet = premake.tools.dotnet


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake.project.getconfig(prj, "Debug")
	end


--
-- On Windows, use Microsoft's CSC compiler by default.
--

	function suite.defaultCompiler_onWindows()
		_OS = "windows"
		prepare()
		test.isequal("csc", dotnet.gettoolname(cfg, "csc"))
	end


--
-- Everywhere other than Windows, use Mono by default.
--

	function suite.defaultCompiler_onMacOSX()
		_OS = "macosx"
		prepare()
		test.isequal("mcs", dotnet.gettoolname(cfg, "csc"))
	end

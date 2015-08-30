--
-- tests/tools/test_dotnet.lua
-- Automated test suite for the .NET toolset interface.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("tools_dotnet")
	local dotnet = premake.tools.dotnet


--
-- Setup/teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
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

--
-- tests/tools/test_dotnet.lua
-- Automated test suite for the .NET toolset interface.
-- Copyright (c) 2012-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("tools_dotnet")
	local dotnet = p.tools.dotnet


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
		_TARGET_OS = "windows"
		prepare()
		test.isequal("csc", dotnet.gettoolname(cfg, "csc"))
	end


--
-- Everywhere other than Windows, use Mono by default.
--

	function suite.defaultCompiler_onMacOSX()
		_TARGET_OS = "macosx"
		prepare()
		test.isequal("csc", dotnet.gettoolname(cfg, "csc"))
	end


--
-- Check support for the `csversion` API
--

function suite.flags_csversion()
	prepare()
	csversion "7.2"
	test.contains({ "/langversion:7.2" }, dotnet.getflags(cfg))
end

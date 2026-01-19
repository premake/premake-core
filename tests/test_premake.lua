--
-- tests/test_premake.lua
-- Automated test suite for the Premake support functions.
-- Copyright (c) 2008-2015 Jess Perkins and the Premake project
--

-- Start local lua debugger
-- https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
end

	local suite = test.declare("premake")

	local p = premake


--
-- Setup
--

	local wks, prj
	function suite.setup()
		os.chdir(_TESTS_DIR)
		wks = test.createWorkspace()
		location "MyLocation"
		prj = p.workspace.getproject(wks, 1)
	end


--
-- generate() tests
--

	function suite.generate_OpensCorrectFile()
		p.generate(prj, ".prj", function () end)
		test.openedfile(path.join(os.getcwd(), "MyLocation/MyProject.prj"))
	end

	function suite.generate_ClosesFile()
		p.generate(prj, ".prj", function () end)
		test.closedfile(true)
	end

--
-- Fatal Warnings related tests
--

	function suite.filterFatalWarnings()
		local warnings = { "All", "4996" }
		local filtered = p.filterFatalWarnings(warnings)
		test.isequal({ "4996" }, filtered)
	end

	function suite.hasFatalCompileWarnings()
		local warnings = { "All", "4996" }
		local hasFatal = p.hasFatalCompileWarnings(warnings)
		test.istrue(hasFatal)
	end

	function suite.hasFatalCompileWarningsNotPresent()
		local warnings = { "4996" }
		local hasFatal = p.hasFatalCompileWarnings(warnings)
		test.isfalse(hasFatal)
	end

	function suite.hasFatalLinkWarnings()
		local warnings = { "All", "4996" }
		local hasFatal = p.hasFatalLinkWarnings(warnings)
		test.istrue(hasFatal)
	end

	function suite.hasFatalLinkWarningsNotPresent()
		local warnings = { "4996" }
		local hasFatal = p.hasFatalLinkWarnings(warnings)
		test.isfalse(hasFatal)
	end

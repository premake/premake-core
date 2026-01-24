--
-- tests/base/test_module_loader_silent.lua
-- Test the custom module loader with silent option.
-- Copyright (c) 2012-2022 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("module_loader_silent")

--
-- Setup
--

	function suite.setup()
	end

	function suite.teardown()
	end

--
-- Check that premake's module loader will failed to
-- load module silently
--

	function suite.silentLoadingFailure()
		local result, msg = require("i-am-not-a-module", nil, true)
		test.isfalse(result)
		p.w(msg)
		test.capture("module 'i-am-not-a-module' not found")
	end
	
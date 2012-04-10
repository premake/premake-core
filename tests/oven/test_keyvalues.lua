--
-- tests/oven/test_keyvalues.lua
-- Test the handling of key-value data types in the oven.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_keyvalues = { }
	local suite = T.oven_keyvalues
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- Make sure that key-value types show up in the baked result.
--

	function suite.valuePresentInResult()
		configmaps { ["key"] = "value" }		
		local cfg = oven.merge({}, sln)
		test.isequal("value", cfg.configmaps["key"][1])
	end

	
--
-- When multiple key-value blocks are present, the resulting keys
-- should be merged into a single result.
--

	function suite.keysMerged_onMultipleValues()
		configmaps { ["sln"] = "slnvalue" }
		prj = project("MyProject")
		configmaps { ["prj"] = "prjvalue" }
		local cfg = oven.merge(oven.merge({}, sln), prj)
		test.istrue(cfg.configmaps.sln ~= nil and cfg.configmaps.prj ~= nil)
	end

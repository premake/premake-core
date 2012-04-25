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
		configmap { ["key"] = "value" }		
		local cfg = oven.merge({}, sln)
		test.isequal("value", cfg.configmap["key"][1])
	end

	
--
-- When multiple key-value blocks are present, the resulting keys
-- should be merged into a single result.
--

	function suite.keysMerged_onMultipleValues()
		configmap { ["sln"] = "slnvalue" }
		prj = project("MyProject")
		configmap { ["prj"] = "prjvalue" }
		local cfg = oven.merge(prj, sln)
		test.istrue(cfg.configmap.sln ~= nil and cfg.configmap.prj ~= nil)
	end

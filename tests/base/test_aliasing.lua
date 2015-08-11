--
-- tests/base/test_aliasing.lua
-- Verify handling of function aliases.
-- Copyright (c) 2015 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_alias")

	local p = premake


	function suite.setup()
		suite.testfunc = function()
			return 48
		end
		suite.aliased = nil
		suite.aliased2 = nil
	end


	function suite.returnsOriginalFunction_onNoAlias()
		local scope, f = p.resolveAlias(suite, "testfunc")
		test.isequal("testfunc", f)
	end


	function suite.pointsAliasToOriginalFunction()
		p.alias(suite, "testfunc", "aliased")
		test.isequal(48, suite.aliased())
	end


	function suite.returnsOriginalFunction_onAlias()
		p.alias(suite, "testfunc", "aliased")
		local scope, f = p.resolveAlias(suite, "aliased")
		test.isequal("testfunc", f)
	end


	function suite.returnsOriginalFunction_onChainedAliases()
		p.alias(suite, "testfunc", "aliased")
		p.alias(suite, "aliased", "aliased2")
		local scope, f = p.resolveAlias(suite, "aliased2")
		test.isequal("testfunc", f)
	end


	function suite.overrideResolvesAliases()
		p.alias(suite, "testfunc", "aliased")
		p.override(suite, "aliased", function(base)
			return base() + 1
		end)
		test.isequal(49, suite.testfunc())
	end


	function suite.aliasTracksOverrides()
		p.alias(suite, "testfunc", "aliased")
		p.override(suite, "testfunc", function(base)
			return base() + 1
		end)
		test.isequal(49, suite.aliased())
	end


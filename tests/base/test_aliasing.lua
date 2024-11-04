--
-- tests/base/test_aliasing.lua
-- Verify handling of function aliases.
-- Copyright (c) 2015 Jess Perkins and the Premake project
--

	local suite = test.declare("premake_alias")
	local m = {}

	local p = premake


	function suite.setup()
		m.testfunc = function()
			return 48
		end
		m.aliased = nil
		m.aliased2 = nil
	end


	function suite.returnsOriginalFunction_onNoAlias()
		local scope, f = p.resolveAlias(m, "testfunc")
		test.isequal("testfunc", f)
	end


	function suite.pointsAliasToOriginalFunction()
		p.alias(m, "testfunc", "aliased")
		test.isequal(48, m.aliased())
	end


	function suite.returnsOriginalFunction_onAlias()
		p.alias(m, "testfunc", "aliased")
		local scope, f = p.resolveAlias(m, "aliased")
		test.isequal("testfunc", f)
	end


	function suite.returnsOriginalFunction_onChainedAliases()
		p.alias(m, "testfunc", "aliased")
		p.alias(m, "aliased", "aliased2")
		local scope, f = p.resolveAlias(m, "aliased2")
		test.isequal("testfunc", f)
	end


	function suite.overrideResolvesAliases()
		p.alias(m, "testfunc", "aliased")
		p.override(m, "aliased", function(base)
			return base() + 1
		end)
		test.isequal(49, m.testfunc())
	end


	function suite.aliasTracksOverrides()
		p.alias(m, "testfunc", "aliased")
		p.override(m, "testfunc", function(base)
			return base() + 1
		end)
		test.isequal(49, m.aliased())
	end


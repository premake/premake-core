--
-- tests/actions/test_xcode.lua
-- Automated test suite for the "clean" action.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3 = { }
	local xcode = premake.xcode


--
-- Setup
--

	local sln, tr
	function T.xcode3.setup()
		premake.action.set("xcode3")
		-- reset the list of generated IDs
		xcode.used_ids = { }
		sln = test.createsolution()
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		tr = xcode.buildtree(sln)
	end






---
-- tests/oven/test_using.lua
-- Test the using and import of exported values.
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
---

	local p = premake
	local suite = test.declare("oven_using")
	local oven = p.oven

---
-- Setup
---

	function suite.setup()
		workspace("MyWorkspace")
			configurations { "Debug", "Release" }
	end

	function suite.testPublicProperty()
		-- create two projects.
		local prj1 = project "MyProject1"
			kind 'StaticLib'
			includedirs {"private"}
			includedirs ({"public"}, "public")

		local prj2 = project "MyProject2"
			kind 'ConsoleApp'
			using { "MyProject1" }

		-- test if prj2 contains the public includedirs, but not the private ones.
		local cfg = test.getconfig(prj2, "Debug")
		test.isequal(#cfg.includedirs, 1)
		test.contains({ path.getabsolute("public") }, cfg.includedirs)

		-- it must also link against it.
		test.isequal(#cfg.links, 1)
		test.contains({ "MyProject1" }, cfg.links)
	end


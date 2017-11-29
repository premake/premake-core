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

	local wks, prj1, prj2

	function suite.setup()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
	end

	function suite.testPublicProperty()
		-- create two projects.

		prj1 = project "MyProject1"
			kind 'StaticLib'

			includedirs {"private"}
			includedirs ({"public"}, "public")

		prj2 = project "MyProject2"
			kind 'ConsoleApp'

			using { "MyProject1" }

		-- test if prj2 contains the public includedirs, but not the private ones.
		cfg = test.getconfig(prj2, "Debug")
		test.print(table.tostring(cfg.includedirs))
		test.isequal(#cfg.includedirs, 1)
		test.contains({ path.getabsolute("public") }, cfg.includedirs)
	end


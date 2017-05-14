---
-- xcode/tests/test_header.lua
-- Validate generation for Xcode workspaces.
-- Author Jason Perkins
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---

	local suite = test.declare("xcode_header")
	local p = premake
	local xcode = p.modules.xcode


--
-- Setup
--

	local wks

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		xcode.header(prj)
		xcode.footer(prj)
	end


--
-- Check basic structure
--

	function suite.onDefaults()
		prepare()
		test.capture [[
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 46;
	objects = {

	};
	rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;
}
		]]
	end

---
-- xcode/xcode.lua
-- Common support code for the Apple Xcode exporters.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---

	local p = premake

	p.modules.xcode = {}
	local m = p.modules.xcode

	dofile("_action.lua")
	dofile("xcode_common.lua")
	dofile("xcode4_workspace.lua")
	dofile("xcode_project.lua")

	return m

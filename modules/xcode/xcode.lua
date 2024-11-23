---
-- xcode/xcode.lua
-- Common support code for the Apple Xcode exporters.
-- Copyright (c) 2009-2015 Jess Perkins and the Premake project
---

	local p = premake

	p.modules.xcode = {}

	local m = p.modules.xcode
	m._VERSION = p._VERSION
	m.elements = {}

	include("xcode_common.lua")
	include("xcode4_workspace.lua")
	include("xcode_project.lua")

	return m

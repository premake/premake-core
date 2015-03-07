---
-- xcode/xcode.lua
-- Common support code for the Apple Xcode exporters.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---

	local p = premake

	p.modules.xcode = {}
	local m = p.modules.xcode


	function m.generateWorkspace(sln)
		print("Generating Xcode workspace...")
	end


	function m.generateProject(prj)
		print("Generating Xcode project...")
	end


	print("Here is the Xcode module")

	return m

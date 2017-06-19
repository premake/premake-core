--
-- _preload.lua
-- Define the makefile action(s).
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

	local p = premake
	local project = p.project

	-- initialize module.
	p.modules.vstudio = p.modules.vstudio or {}
	p.modules.vstudio._VERSION = p._VERSION
	p.vstudio = p.modules.vstudio

	-- load actions.
	include("vs2005.lua")
	include("vs2008.lua")
	include("vs2010.lua")
	include("vs2012.lua")
	include("vs2013.lua")
	include("vs2015.lua")
	include("vs2017.lua")

--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return
			_ACTION == "vs2005" or
			_ACTION == "vs2008" or
			_ACTION == "vs2010" or
			_ACTION == "vs2012" or
			_ACTION == "vs2013" or
			_ACTION == "vs2015" or
			_ACTION == "vs2017";
	end

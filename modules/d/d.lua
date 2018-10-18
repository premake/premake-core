--
-- d/d.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake

	p.modules.d = {}

	local m = p.modules.d

	m._VERSION = p._VERSION
	m.elements = {}

	local api = p.api


--
-- Patch the project table to provide knowledge of D projects
--
	function p.project.isd(prj)
		return prj.language == p.D
	end

--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d" })
	end

	function path.isdheader(fname)
		return path.hasextension(fname, { ".di" })
	end


--
-- Patch actions
--
	include( "tools/dmd.lua" )
	include( "tools/gdc.lua" )
	include( "tools/ldc.lua" )

	include( "actions/gmake.lua" )
	include( "actions/vcxproj.lua" )
	include( "actions/visuald.lua" )

	return m

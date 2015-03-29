--
-- d/d.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake

	p.modules.d = {}

	local d = p.modules.d


--
-- Patch the project table to provide knowledge of D projects
--
	function p.project.isd(prj)
		return prj.language == premake.D
	end

--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d", ".di" })
	end


	include("_preload.lua")

	include( "tools/dmd.lua" )
	include( "tools/gdc.lua" )
	include( "tools/ldc.lua" )

	include( "actions/gmake.lua" )
	include( "actions/vstudio.lua" )
	-- this one depends on the monodevelop extension
	if p.modules.monodevelop then
		include( "actions/monodev.lua" )
	end

	return d

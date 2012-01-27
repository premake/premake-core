--
-- tests/actions/vstudio/vc2010/test_header.lua
-- Validate generation of the project file header block.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vc2010_header = { }
	local suite = T.vstudio_vc2010_header
	local vc2010 = premake.vstudio.vc2010


--
-- If a default build target is specified, it should be included in the
-- generated Project element.
--

	function suite.project_onDefaultTarget()
		vc2010.header_ng("Build")
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

--
-- If no build target is specified, the entire attribute should be omitted.
--

	function suite.project_onNoDefaultTarget()
		vc2010.header_ng()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

--
-- tests/actions/vstudio/vc2010/test_resource_compile.lua
-- Validate resource compiler settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_resource_compiler = { }
	local suite = T.vstudio_vs2010_resource_compiler
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare(platform)
		cfg = project.getconfig(prj, "Debug", platform)
		vc2010.resourceCompile(cfg)
	end


 --
-- Check the basic element structure with default settings.
--

	function suite.defaultSettings()
		prepare()
		test.capture [[
		<ResourceCompile>
		</ResourceCompile>
		]]
	end

--
-- If defines are specified, the <PreprocessorDefinitions> element should be added.
--

	function suite.preprocessorDefinitions_onDefines()
		defines { "DEBUG" }
		resdefines { "RESOURCES" }
		prepare()
		test.capture [[
		<ResourceCompile>
			<PreprocessorDefinitions>DEBUG;RESOURCES;%(PreprocessorDefinitions)</PreprocessorDefinitions>
		]]
	end


--
-- If include directories are specified, the <AdditionalIncludeDirectories> should be added.
--

	function suite.additionalIncludeDirs_onIncludeDirs()
		includedirs { "include/lua" }
		resincludedirs { "include/zlib" }
		prepare()
		test.capture [[
		<ResourceCompile>
			<AdditionalIncludeDirectories>include\lua;include\zlib;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
		]]
	end

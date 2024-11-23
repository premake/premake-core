--
-- tests/actions/vstudio/vc2010/test_resource_compile.lua
-- Validate resource compiler settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_resource_compiler")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		p.escaper(p.vstudio.vs2010.esc)
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.resourceCompile(cfg)
	end


--
-- Should only write the element if it is needed.
--

	function suite.excluded_onNoResourceFiles()
		prepare()
		test.isemptycapture()
	end

	function suite.excluded_onNoSettings()
		files { "hello.rc" }
		prepare()
		test.isemptycapture()
	end

--
-- If defines are specified, the <PreprocessorDefinitions> element should be added.
--

	function suite.preprocessorDefinitions_onDefines()
		files { "hello.rc" }
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
		files { "hello.rc" }
		includedirs { "include/lua" }
		resincludedirs { "include/zlib" }
		prepare()
		test.capture [[
<ResourceCompile>
	<AdditionalIncludeDirectories>include\lua;include\zlib;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
		]]
	end


--
-- Test special escaping for preprocessor definition with quotes.
--

	function suite.preprocessorDefinitions_onDefinesEscaping()
		files { "hello.rc" }
		defines { 'VERSION_STRING="1.0.0 (testing)"' }
		prepare()
		test.capture [[
<ResourceCompile>
	<PreprocessorDefinitions>VERSION_STRING=\"1.0.0 (testing)\";%(PreprocessorDefinitions)</PreprocessorDefinitions>
		]]
	end


--
-- Test locale conversion to culture codes.
--

	function suite.culture_en_US()
		files { "hello.rc" }
		locale "en-US"
		prepare()
		test.capture [[
<ResourceCompile>
	<Culture>0x0409</Culture>
		]]
	end

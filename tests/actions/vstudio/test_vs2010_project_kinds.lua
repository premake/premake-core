	T.vs2010_project_kinds= { }
	local vs10_project_kinds = T.vs2010_project_kinds
	local sln, prj

	function vs10_project_kinds.setup()
		_ACTION = "vs2010"

		sln = solution "MySolution"
		configurations { "Debug" }
		platforms {}
	
		prj = project "MyProject"
		language "C++"
	end
	
	local function get_buffer()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		premake.vs2010_vcxproj(prj)
		buffer = io.endcapture()
		return buffer
	end
	--incorrect assumption
	--[[
	function vs10_project_kinds.staticLib_doesNotContainLinkSection()
		kind "StaticLib"
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'<Link>.*</Link>')
	end
	--]]
		
	function vs10_project_kinds.staticLib_containsLibSection()
		kind "StaticLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<ItemDefinitionGroup.*<Lib>.*</Lib>.*</ItemDefinitionGroup>')
	end
	function vs10_project_kinds.staticLib_libSection_containsProjectNameDotLib()
		kind "StaticLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<Lib>.*<OutputFile>.*MyProject.lib.*</OutputFile>.*</Lib>')
	end
	--[[
	function vs10_project_kinds.sharedLib_fail_asIDoNotKnowWhatItShouldLookLike_printsTheBufferSoICanCompare()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'youWillNotFindThis')
	end
	--]]
		
	--[[
check OutDir in debug it is showing "."
shared lib missing  <ImportLibrary>???</ImportLibrary> in link section when noInportLib not used
	--]]
	--check why  <MinimalRebuild>true</MinimalRebuild> is missing in a debug static lib and shared lib build
	function vs10_project_kinds.staticLib_valueInMinimalRebuildIsTrue()
		kind "StaticLib"
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile>.*<MinimalRebuild>true</MinimalRebuild>.*</ClCompile>')
	end
	function vs10_project_kinds.sharedLib_valueInMinimalRebuildIsTrue()
		kind "SharedLib"
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile>.*<MinimalRebuild>true</MinimalRebuild>.*</ClCompile>')
	end
	--shared lib missing <DebugInformationFormat>EditAndContinue</DebugInformationFormat> in ClCompile section
	function vs10_project_kinds.sharedLib_valueDebugInformationFormatIsEditAndContinue()
		kind "SharedLib"
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile>.*<DebugInformationFormat>EditAndContinue</DebugInformationFormat>.*</ClCompile>')
	end
	function vs10_project_kinds.sharedLib_valueGenerateDebugInformationIsTrue()
		kind "SharedLib"
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<Link>.*<GenerateDebugInformation>true</GenerateDebugInformation>.*</Link>')
	end
	function vs10_project_kinds.sharedLib_linkSectionContainsImportLibrary()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<Link>.*<ImportLibrary>.*</ImportLibrary>.*</Link>')
	end
	
	function vs10_project_kinds.sharedLib_bufferContainsImportLibrary()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<Link>.*<ImportLibrary>MyProject.lib</ImportLibrary>.*</Link>')
	end
	--should this go in vs2010_flags???

	function vs10_project_kinds.sharedLib_withNoImportLibraryFlag_linkSectionContainsImportLibrary()
		kind "SharedLib"
		flags{"NoImportLib"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<Link>.*<ImportLibrary>.*</ImportLibrary>.*</Link>')
	end

	function vs10_project_kinds.sharedLib_withOutNoImportLibraryFlag_propertyGroupSectionContainsIgnoreImportLibrary()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup>.*<IgnoreImportLibrary.*</IgnoreImportLibrary>.*</PropertyGroup>')
	end
	
	function vs10_project_kinds.sharedLib_withNoImportLibraryFlag_propertyGroupSectionContainsIgnoreImportLibrary()
		kind "SharedLib"
		flags{"NoImportLib"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup>.*<IgnoreImportLibrary.*</IgnoreImportLibrary>.*</PropertyGroup>')
	end
	
	function vs10_project_kinds.sharedLib_withOutNoImportLibraryFlag_ignoreImportLibraryValueIsFalse()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup>.*<IgnoreImportLibrary.*false</IgnoreImportLibrary>.*</PropertyGroup>')
	end
	
	function vs10_project_kinds.sharedLib_withNoImportLibraryFlag_ignoreImportLibraryValueIsTrue()
		kind "SharedLib"
		flags{"NoImportLib"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup>.*<IgnoreImportLibrary.*true</IgnoreImportLibrary>.*</PropertyGroup>')
	end
	
	--shared lib LinkIncremental set to incorrect value of false
	function vs10_project_kinds.staticLib_doesNotContainLinkIncremental()
		kind "StaticLib"
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'<LinkIncremental.*</LinkIncremental>')
	end
	
	function vs10_project_kinds.sharedLib_withoutOptimisation_linkIncrementalValueIsTrue()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_contains(buffer,'<LinkIncremental.*true</LinkIncremental>')
	end
	
	function vs10_project_kinds.sharedLib_withOptimisation_linkIncrementalValueIsFalse()
		kind "SharedLib"
		flags{"Optimize"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<LinkIncremental.*false</LinkIncremental>')
	end
	
	--check all configs %(AdditionalIncludeDirectories) missing before AdditionalIncludeDirectories end tag in ClCompile
	function vs10_project_kinds.kindDoesNotMatter_noAdditionalDirectoriesSpecified_bufferDoesNotContainAdditionalIncludeDirectories()
		kind "SharedLib"
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'<ClCompile>.*<AdditionalIncludeDirectories>.*</ClCompile>')
	end
	
	function vs10_project_kinds.configType_configIsWindowedApp_resultComparesEqualToApplication()
		local t = { kind = "WindowedApp"}
		local result = premake.vstudio.vs10_helpers.config_type(t)
		test.isequal('Application',result)
	end
	
	function vs10_project_kinds.linkOptions_staticLib_bufferContainsAdditionalOptionsInSideLibTag()
		kind "StaticLib"
		linkoptions{'/dummyOption'}

		test.string_contains(get_buffer(),
			'<AdditionalOptions>.*%%%(AdditionalOptions%)</AdditionalOptions>.*</Lib>')
	end
	
	function vs10_project_kinds.noLinkOptions_staticLib_bufferDoesNotContainAdditionalOptionsInSideLibTag()
		kind "StaticLib"

		test.string_does_not_contain(get_buffer(),
			'<AdditionalOptions>.*%%%(AdditionalOptions%)</AdditionalOptions>.*</Lib>')
	end		
	
	function vs10_project_kinds.linkOptions_staticLib_bufferContainsPassedOption()
		kind "StaticLib"
		linkoptions{'/dummyOption'}

		test.string_contains(get_buffer(),
			'<AdditionalOptions>/dummyOption %%%(AdditionalOptions%)</AdditionalOptions>.*</Lib>')
	end	
	
	function vs10_project_kinds.linkOptions_windowedApp_bufferContainsAdditionalOptionsInSideLinkTag()
		kind "WindowedApp"
		linkoptions{'/dummyOption'}
		
		test.string_contains(get_buffer(),
			'<AdditionalOptions>.* %%%(AdditionalOptions%)</AdditionalOptions>.*</Link>')
	end	
	function vs10_project_kinds.linkOptions_consoleApp_bufferContainsAdditionalOptionsInSideLinkTag()
		kind "ConsoleApp"
		linkoptions{'/dummyOption'}
		
		test.string_contains(get_buffer(),
			'<AdditionalOptions>.* %%%(AdditionalOptions%)</AdditionalOptions>.*</Link>')
	end

	function vs10_project_kinds.linkOptions_sharedLib_bufferContainsAdditionalOptionsInSideLinkTag()
		kind "SharedLib"
		linkoptions{'/dummyOption'}
		
		test.string_contains(get_buffer(),
			'<AdditionalOptions>.* %%%(AdditionalOptions%)</AdditionalOptions>.*</Link>')
	end			
				
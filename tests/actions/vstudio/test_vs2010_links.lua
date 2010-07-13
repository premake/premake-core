	T.vs2010_links = { }
	local vs10_links = T.vs2010_links
	local sln, prj

	function vs10_links.setup()
		_ACTION = "vs2010"

		sln = solution "MySolution"
		configurations { "Debug" }
		platforms {}
	
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	end
	
	local function get_buffer()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		premake.vs2010_vcxproj(prj)
		buffer = io.endcapture()
		return buffer
	end
	
	function vs10_links.hasLinkBlock()
		local buffer = get_buffer()
		test.string_contains(buffer,'<Link>.*</Link>')
	end
	
	function vs10_links.additionalDependancies_isInsideLinkBlock()
		configuration("Debug")
			links{"link_test"}
		local buffer = get_buffer()
		test.string_contains(buffer,
			'<Link>.*<AdditionalDependencies>.*%%%(AdditionalDependencies%)</AdditionalDependencies>.*</Link>')
	end
	
	function vs10_links.additionalDependancies_containsLinkTestDotLib()
		configuration("Debug")
			links{"link_test"}
		local buffer = get_buffer()
		test.string_contains(buffer,
			'<AdditionalDependencies>link_test%.lib;%%%(AdditionalDependencies%)</AdditionalDependencies>')
	end
	
	function vs10_links.outPutFile_isEqualToOutDirMyProjectDotExe()
		local buffer = get_buffer()
		test.string_contains(buffer,'<OutputFile>%$%(OutDir%)MyProject.exe</OutputFile>')
	end
	
	function vs10_links.additionalLibraryDirectories_inputNoDirectories_tagsAreEmpty()
		local buffer = get_buffer()
		test.string_contains(buffer,
			'<AdditionalLibraryDirectories>%%%(AdditionalLibraryDirectories%)</AdditionalLibraryDirectories>')
	end
	
	function vs10_links.additionalLibraryDirectories_inputTestPath_tagsContainExspectedValue()
		configuration("Debug")
			libdirs { "test_path" }
		local buffer = get_buffer()
		local exspect = "test_path;"
		test.string_contains(buffer,
			'<AdditionalLibraryDirectories>'..exspect..'%%%(AdditionalLibraryDirectories%)</AdditionalLibraryDirectories>')
	end
	
	function vs10_links.additionalLibraryDirectories_inputTwoPaths_tagsContainExspectedValue()
		configuration("Debug")
			libdirs { "test_path","another_path" }
		local buffer = get_buffer()
		local exspect = "test_path;another_path;"
		test.string_contains(buffer,
			'<AdditionalLibraryDirectories>'..exspect..'%%%(AdditionalLibraryDirectories%)</AdditionalLibraryDirectories>')
	end
	
	function vs10_links.generateDebugInformation_withoutSymbolsFlag_valueInTagsIsFalse()
		local buffer = get_buffer()
		test.string_contains(buffer,'<GenerateDebugInformation>false</GenerateDebugInformation>')
	end
	
	function vs10_links.generateDebugInformation_withSymbolsFlag_valueInTagsIsTrue()
		flags  {"Symbols"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<GenerateDebugInformation>true</GenerateDebugInformation>')
	end

	
	function vs10_links.noOptimiseFlag_optimizeReferences_isNotInBuffer()
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'OptimizeReferences')
	end

	function vs10_links.noOptimiseFlag_enableCOMDATFolding_isNotInBuffer()
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'EnableCOMDATFolding')
	end
	
	function vs10_links.optimiseFlag_optimizeReferences_valueInsideTagsIsTrue()
		flags{"Optimize"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<OptimizeReferences>true</OptimizeReferences>')
	end

	function vs10_links.noOptimiseFlag_enableCOMDATFolding_valueInsideTagsIsTrue()
		flags{"Optimize"}
		local buffer = get_buffer()
		test.string_contains(buffer,'EnableCOMDATFolding>true</EnableCOMDATFolding')
	end
		
	function vs10_links.entryPointSymbol_noWimMainFlag_valueInTagsIsMainCrtStartUp()
		local buffer = get_buffer()
		test.string_contains(buffer,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
	end
	
	function vs10_links.entryPointSymbol_noWimMainFlag_valueInTagsIsMainCrtStartUp()
		local buffer = get_buffer()
		test.string_contains(buffer,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
	end
	
	function vs10_links.entryPointSymbol_winMainFlag_doesNotContainEntryPointSymbol()
		flags{"WinMain"}
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,'<EntryPointSymbol>')
	end
	
	function vs10_links.targetMachine_default_valueInTagsIsMachineX86()
		local buffer = get_buffer()
		test.string_contains(buffer,'<TargetMachine>MachineX86</TargetMachine>')
	end

	function vs10_links.targetMachine_x32_valueInTagsIsMachineX64()
		platforms {"x32"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<TargetMachine>MachineX86</TargetMachine>')
	end
	
	function vs10_links.targetMachine_x64_valueInTagsIsMachineX64()
		platforms {"x64"}
		local buffer = get_buffer()
		test.string_contains(buffer,'<TargetMachine>MachineX64</TargetMachine>')
	end
	
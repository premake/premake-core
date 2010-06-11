	T.vs2010_vcxproj = { }
	local vs10_vcxproj = T.vs2010_vcxproj
	local include_directory = "bar/foo"
	local include_directory2 = "baz/foo"
	local debug_define = "I_AM_ALIVE_NUMBER_FIVE"
	
	local sln, prj
	function vs10_vcxproj.setup()
		_ACTION = "vs2010"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
	
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"		
		
		includedirs
		{
			include_directory,
			include_directory2
		}
		
		configuration("Release")
			flags {"Optimize"}
			
		configuration("Debug")
			defines {debug_define}
			

	end
	
	local function get_buffer()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		premake.vs2010_vcxproj(prj)
		buffer = io.endcapture()
		return buffer
	end

	function vs10_vcxproj.xmlDeclarationPresent()
		buffer = get_buffer()
		test.istrue(string.startswith(buffer, '<?xml version=\"1.0\" encoding=\"utf-8\"?>'))
	end

	function vs10_vcxproj.projectBlocksArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<Project*.*</Project>')
	end

	function vs10_vcxproj.projectOpenTagIsCorrect()
		buffer = get_buffer()
		test.string_contains(buffer,'<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">*.*</Project>')
	end
	
	function vs10_vcxproj.configItemGroupPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<ItemGroup Label="ProjectConfigurations">*.*</ItemGroup>')
	end
	
	function vs10_vcxproj.configBlocksArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<ProjectConfiguration*.*</ProjectConfiguration>')
	end

	function vs10_vcxproj.configTypeBlockPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup Condition="\'%$%(Configuration%)|%$%(Platform%)\'==\'*.*\'" Label="Configuration">*.*</PropertyGroup>')
	end
	
	function vs10_vcxproj.twoConfigTypeBlocksPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup Condition*.*</PropertyGroup>*.*<PropertyGroup Condition=*.*</PropertyGroup>')	
	end
	
	function vs10_vcxproj.propsDefaultForCppProjArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<Import Project="$%(VCTargetsPath%)\\Microsoft.Cpp.Default.props" />')
	end
	
	
	function vs10_vcxproj.propsForCppProjArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<Import Project="%$%(VCTargetsPath%)\\Microsoft.Cpp.props" />')
	end
	
	function vs10_vcxproj.extensionSettingArePresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<ImportGroup Label="ExtensionSettings">*.*</ImportGroup>')
	end
	
	function vs10_vcxproj.userMacrosPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup Label="UserMacros" />')
	end
	
	function vs10_vcxproj.intermediateAndOutDirsPropertyGroupWithMagicNumber()
		buffer = get_buffer()
		test.string_contains(buffer,'<PropertyGroup>*.*<_ProjectFileVersion>10%.0%.30319%.1</_ProjectFileVersion>')
	end
	
	function vs10_vcxproj.outDirPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<OutDir>*.*</OutDir>')
	end
	function vs10_vcxproj.initDirPresent()
		buffer = get_buffer()
		test.string_contains(buffer,'<IntDir>*.*</IntDir>')
	end
	
	function vs10_vcxproj.projectWithDebugAndReleaseConfig_twoOutDirsAndTwoIntDirs()
		buffer = get_buffer()
		test.string_contains(buffer,'<OutDir>*.*</OutDir>*.*<IntDir>*.*</IntDir>*.*<OutDir>*.*</OutDir>*.*<IntDir>*.*</IntDir>')
	end

	function vs10_vcxproj.containsItemDefinition()
		buffer = get_buffer()
		test.string_contains(buffer,'<ItemDefinitionGroup Condition="\'%$%(Configuration%)|%$%(Platform%)\'==\'*.*\'">*.*</ItemDefinitionGroup>')
	end
	

	function vs10_vcxproj.containsClCompileBlock()
		buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile>*.*</ClCompile>')		
	end
	--[[	
	function vs10_vcxproj.containsAdditionalOptions()
		buffer = get_buffer()
		test.string_contains(buffer,'<AdditionalOptions>*.*<AdditionalOptions>')		
	end
	--]]
	
	local function cl_compile_string(version)
		return '<ItemDefinitionGroup Condition="\'%$%(Configuration%)|%$%(Platform%)\'==\''..version..'|Win32\'">*.*<ClCompile>'
	end
	
	function vs10_vcxproj.debugHasNoOptimisation()
		buffer = get_buffer()
		test.string_contains(buffer, cl_compile_string('Debug').. '*.*<Optimization>Disabled</Optimization>*.*</ItemDefinitionGroup>')
	end
	
	function vs10_vcxproj.releaseHasFullOptimisation()
		buffer = get_buffer()
		test.string_contains(buffer, cl_compile_string('Release').. '*.*<Optimization>Full</Optimization>*.*</ItemDefinitionGroup>')
	end
	
	function vs10_vcxproj.includeDirectories_debugEntryContains_include_directory()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Debug').. '*.*<AdditionalIncludeDirectories>'.. path.translate(include_directory, '\\') ..'*.*</AdditionalIncludeDirectories>')
	end
	
	function vs10_vcxproj.includeDirectories_debugEntryContains_include_directory2PrefixWithSemiColon()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Debug').. '*.*<AdditionalIncludeDirectories>*.*;'.. path.translate(include_directory2, '\\') ..'*.*</AdditionalIncludeDirectories>')
	end
	
	function vs10_vcxproj.includeDirectories_debugEntryContains_include_directory2PostfixWithSemiColon()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Debug').. '*.*<AdditionalIncludeDirectories>*.*'.. path.translate(include_directory2, '\\') ..';*.*</AdditionalIncludeDirectories>')
	end
	
	function vs10_vcxproj.debugContainsPreprossorBlock()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Debug').. '*.*<PreprocessorDefinitions>*.*</PreprocessorDefinitions>')
	end
	
	function vs10_vcxproj.debugHasDebugDefine()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Debug')..'*.*<PreprocessorDefinitions>*.*'..debug_define..'*.*</PreprocessorDefinitions>')
	end
	
	function vs10_vcxproj.releaseHasStringPoolingOn()
		buffer = get_buffer()
		test.string_contains(buffer,cl_compile_string('Release')..'*.*<StringPooling>true</StringPooling>')
	end
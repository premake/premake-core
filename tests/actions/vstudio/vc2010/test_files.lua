--
-- tests/actions/vstudio/vc2010/test_files.lua
-- Validate generation of files block in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite =  test.declare("vstudio_vs2010_files")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
		vc2010.files(prj)
	end


--
-- Test filtering of source files into the correct categories.
--

	function suite.clInclude_onHFile()
		files { "include/hello.h" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClInclude Include="include\hello.h" />
	</ItemGroup>
		]]
	end

	function suite.clCompile_onCFile()
		files { "hello.c" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.c" />
	</ItemGroup>
		]]
	end

	function suite.resourceCompile_onRCFile()
		files { "resources/hello.rc" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="resources\hello.rc" />
	</ItemGroup>
		]]
	end

	function suite.none_onTxtFile()
		files { "docs/hello.txt" }
		prepare()
		test.capture [[
	<ItemGroup>
		<None Include="docs\hello.txt" />
	</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRule()
		files { "hello.cg" }
		configuration "**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare()
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg">
			<FileType>Document</FileType>
			<Command Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">$(InputName).obj</Outputs>
			<Command Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(InputName).obj</Outputs>
		</CustomBuild>
	</ItemGroup>
		]]
	end


	function suite.customBuild_onBuildRuleWithMessage()
		files { "hello.cg" }
		configuration "**.cg"
			buildmessage "Compiling shader $(InputFile)"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare()
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg">
			<FileType>Document</FileType>
			<Command Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">$(InputName).obj</Outputs>
			<Message Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Compiling shader $(InputFile)</Message>
			<Command Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(InputName).obj</Outputs>
			<Message Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">Compiling shader $(InputFile)</Message>
		</CustomBuild>
	</ItemGroup>
		]]
	end


--
-- If a PCH source is specified, ensure it is included in the file configuration.
--

	function suite.precompiledHeader_onPchSource()
		files { "afxwin.cpp" }
		pchheader "afxwin.h"
		pchsource "afxwin.cpp"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="afxwin.cpp">
			<PrecompiledHeader Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Create</PrecompiledHeader>
			<PrecompiledHeader Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">Create</PrecompiledHeader>
		</ClCompile>
	</ItemGroup>
		]]
	end


--
-- If a file is excluded from a configuration, make sure it is marked as such.
--

	function suite.excludedFromBuild_onExcludedFile()
		files { "hello.cpp" }
		configuration "Debug"
		removefiles { "hello.cpp" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
		</ClCompile>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onExcludeFlag()
		files { "hello.cpp" }
		configuration "hello.cpp"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
		</ClCompile>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_excludedFile()
		files { "hello.rc" }
		configuration "Debug"
		removefiles { "hello.rc" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="hello.rc">
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
		</ResourceCompile>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_excludeFlag()
		files { "hello.rc" }
		configuration "hello.rc"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="hello.rc">
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
		</ResourceCompile>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_excludeFlag_nonWindows()
		files { "hello.rc" }
		system "PS3"
		configuration "hello.rc"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="hello.rc" />
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onCustomBuildRule_excludedFile()
		files { "hello.cg" }
		configuration "**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		configuration "Debug"
			removefiles { "hello.cg" }
		prepare()
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg">
			<FileType>Document</FileType>
			<Command Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(InputName).obj</Outputs>
		</CustomBuild>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onCustomBuildRule_excludeFlag()
		files { "hello.cg" }
		configuration "**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg">
			<FileType>Document</FileType>
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
			<Command Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">$(InputName).obj</Outputs>
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
			<Command Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(InputName).obj</Outputs>
		</CustomBuild>
	</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onCustomBuildRule_withNoCommands()
		files { "hello.cg" }
		configuration { "**.cg", "Debug" }
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		configuration { "**.cg" }
			flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg">
			<FileType>Document</FileType>
			<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
			<Command Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">cgc $(InputFile)</Command>
			<Outputs Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">$(InputName).obj</Outputs>
		</CustomBuild>
	</ItemGroup>
		]]
	end


--
-- If two files at different folder levels have the same name, a different
-- object file name should be used for each.
--

	function suite.uniqueObjectNames_onSourceNameCollision()
		files { "hello.cpp", "greetings/hello.cpp" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="greetings\hello.cpp" />
		<ClCompile Include="hello.cpp">
			<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">$(IntDir)\hello1.obj</ObjectFileName>
			<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(IntDir)\hello1.obj</ObjectFileName>
		</ClCompile>
	</ItemGroup>
		]]
	end


--
-- Check handling of per-file forced includes.
--

	function suite.forcedIncludeFiles()
		files { "hello.cpp" }
		configuration "**.cpp"
			forceincludes { "../include/force1.h", "../include/force2.h" }

		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<ForcedIncludeFiles Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">..\include\force1.h;..\include\force2.h</ForcedIncludeFiles>
			<ForcedIncludeFiles Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">..\include\force1.h;..\include\force2.h</ForcedIncludeFiles>
		</ClCompile>
	</ItemGroup>
		]]
	end


--
-- Check handling of per-file command line build options.
--

	function suite.additionalOptions()
		files { "hello.cpp" }
		configuration "**.cpp"
			buildoptions { "/Xc" }

		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">/Xc %(AdditionalOptions)</AdditionalOptions>
			<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">/Xc %(AdditionalOptions)</AdditionalOptions>
		</ClCompile>
	</ItemGroup>
		]]
	end


--
-- Check handling of per-file optimization levels.
--

	function suite.onOptimize()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "On"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Full</Optimization>
		]]
	end


	function suite.onOptimizeSize()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "Size"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">MinSpace</Optimization>
		]]
	end

	function suite.onOptimizeSpeed()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "Speed"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">MaxSpeed</Optimization>
		]]
	end

	function suite.onOptimizeFull()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "Full"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Full</Optimization>
		]]
	end

	function suite.onOptimizeOff()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "Off"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Disabled</Optimization>
		]]
	end

	function suite.onOptimizeDebug()
		files { "hello.cpp" }
		configuration "hello.cpp"
		optimize "Debug"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<Optimization Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">Disabled</Optimization>
		]]
	end


--
-- Check handling of per-file no PCH build options.
--

	function suite.excludedFromPCH()
		files { "hello.cpp" }
		configuration "**.cpp"
		flags { "NoPCH" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<PrecompiledHeader Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">NotUsing</PrecompiledHeader>
			<PrecompiledHeader Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">NotUsing</PrecompiledHeader>
		</ClCompile>
	</ItemGroup>
		]]
	end



--
-- Check handling of per-file command line build options.
--

	function suite.perFileDefines()
		files { "hello.cpp" }
		configuration "**.cpp"
			defines { "IS_CPP" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<PreprocessorDefinitions Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">IS_CPP;%(PreprocessorDefinitions)</PreprocessorDefinitions>
			<PreprocessorDefinitions Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">IS_CPP;%(PreprocessorDefinitions)</PreprocessorDefinitions>
		</ClCompile>
	</ItemGroup>
		]]
	end


--
-- Make sure that the sort order of the source files is maintained even
-- when virtual paths are used to organize them.
--

	function suite.maintainsSortOrder_onVirtualPaths()
		files { "SystemTray.h", "PrefsWriter.h", "SystemTray.cpp", "PrefsWriter.cpp" }
		vpaths {
			["source/mfc"] = { "PrefsWriter.*" },
			["source/core"] = { "SystemTray.*" },
		}
		prepare()
		test.capture [[
	<ItemGroup>
		<ClInclude Include="PrefsWriter.h" />
		<ClInclude Include="SystemTray.h" />
	</ItemGroup>
		]]
	end



--
-- Check handling of per-file vector extensions.
--

	function suite.perFileVectorExtensions()
		files { "hello.cpp" }
		configuration "**.cpp"
			vectorextensions "sse2"
		prepare()
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.cpp">
			<EnableEnhancedInstructionSet Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">StreamingSIMDExtensions2</EnableEnhancedInstructionSet>
			<EnableEnhancedInstructionSet Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">StreamingSIMDExtensions2</EnableEnhancedInstructionSet>
		</ClCompile>
	</ItemGroup>
		]]
	end

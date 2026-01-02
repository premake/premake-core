--
-- tests/actions/vstudio/vc2010/test_files.lua
-- Validate generation of files block in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite =  test.declare("vstudio_vs2010_files")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")

		rule "Animation"
		fileextension ".dae"
		propertydefinition {
			name = "AdditionalOptions",
			kind = "list",
			separator = ";"
		}

		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
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

	function suite.midlCompile_onIDLFile()
		files { "idl/interfaces.idl" }
		prepare()
		test.capture [[
<ItemGroup>
	<Midl Include="idl\interfaces.idl" />
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

	function suite.appxManifestCompile_onAppxManifestFile()
		files { "hello.appxmanifest" }
		prepare()
		test.capture [[
<ItemGroup>
	<AppxManifest Include="hello.appxmanifest">
		<FileType>Document</FileType>
		<SubType>Designer</SubType>
	</AppxManifest>
</ItemGroup>
		]]
	end


--
-- Check handling of buildaction.
--
	function suite.customBuildTool_onBuildAction()
		files { "test.x", "test2.cpp", "test3.cpp", "test4.dll" }
		filter "files:**.x"
			buildaction "FxCompile"
		filter "files:test2.cpp"
			buildaction "None"
		filter { "files:test4.dll" }
			buildaction "Copy"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="test3.cpp" />
</ItemGroup>
<ItemGroup>
	<FxCompile Include="test.x" />
</ItemGroup>
<ItemGroup>
	<None Include="test2.cpp" />
</ItemGroup>
<ItemGroup>
	<CopyFileToFolders Include="test4.dll">
		<DestinationFolders Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">bin\Debug</DestinationFolders>
		<DestinationFolders Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">bin\Release</DestinationFolders>
	</CopyFileToFolders>
</ItemGroup>
		]]
	end


--
-- Check handling of files with custom build rules.
--

	function suite.customBuild_onBuildRule()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg">
		<FileType>Document</FileType>
		<Command>cgc $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRuleMultipleBuildOutputs()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).a", "$(InputName).b" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg">
		<FileType>Document</FileType>
		<Command>cgc $(InputFile)</Command>
		<Outputs>$(InputName).a;$(InputName).b</Outputs>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRuleWithMessage()
		files { "hello.cg" }
		filter "files:**.cg"
			buildmessage "Compiling shader $(InputFile)"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg">
		<FileType>Document</FileType>
		<Command>cgc $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
		<Message>Compiling shader $(InputFile)</Message>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.customBuild_onBuildRuleWithAdditionalInputs()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			buildinputs { "common.cg.inc", "common.cg.inc2" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg">
		<FileType>Document</FileType>
		<Command>cgc $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
		<AdditionalInputs>common.cg.inc;common.cg.inc2</AdditionalInputs>
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
		<PrecompiledHeader>Create</PrecompiledHeader>
	</ClCompile>
</ItemGroup>
		]]
	end


--
-- If a file is excluded from a configuration, make sure it is marked as such.
--

	function suite.excludedFromBuild_onExcludedFile()
		files { "hello.cpp" }
		filter "Debug"
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
		filter "files:hello.cpp"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ClCompile>
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onBuildActionNone()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		buildaction "None"
		prepare()
		test.capture [[
<ItemGroup>
	<None Include="hello.cpp" />
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onAPI()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		excludefrombuild "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.excludedFromBuild_onResourceFile_excludedFile()
		files { "hello.rc" }
		filter "Debug"
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
		filter "files:hello.rc"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ResourceCompile>
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_buildActionNone()
		files { "hello.rc" }
		filter "files:hello.rc"
		buildaction "None"
		prepare()
		test.capture [[
<ItemGroup>
	<None Include="hello.rc" />
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_viaAPI()
		files { "hello.rc" }
		filter "files:hello.rc"
		excludefrombuild "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ResourceCompile>
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_excludeFlag_nonWindows()
		files { "hello.rc" }
		system "Linux"
		filter "files:hello.rc"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ResourceCompile>
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onResourceFile_viaAPI_nonWindows()
		files { "hello.rc" }
		system "Linux"
		filter "files:hello.rc"
		excludefrombuild "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc">
		<ExcludedFromBuild>true</ExcludedFromBuild>
	</ResourceCompile>
</ItemGroup>
		]]
	end

	function suite.includedFromBuild_onResourceFile_nonWindows()
		files { "hello.rc" }
		system "Linux"
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc" />
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onCustomBuildRule_excludedFile()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		filter "Debug"
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
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg">
		<FileType>Document</FileType>
		<ExcludedFromBuild>true</ExcludedFromBuild>
		<Command>cgc $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.excludedFromBuild_onCustomBuildRule_withNoCommands_excludeViaFlag()
		files { "hello.cg" }
		filter { "files:**.cg", "Debug" }
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		filter { "files:**.cg" }
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

	function suite.excludedFromBuild_onCustomBuildRule_withNoCommands_excludeViaAPI()
		files { "hello.cg" }
		filter { "files:**.cg", "Debug" }
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		filter { "files:**.cg" }
			excludefrombuild "On"
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
-- If a custom rule outputs an object file, it's automatically linked, unless
-- we explicitly specify that it isn't with linkbuildoutputs.
--

	function suite.linkBuildOutputs_onNotSpecified()
		files { "hello.x" }
		filter "files:**.x"
			buildcommands { "echo $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.x">
		<FileType>Document</FileType>
		<Command>echo $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.linkBuildOutputs_onOff()
		files { "hello.x" }
		filter "files:**.x"
			buildcommands { "echo $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			linkbuildoutputs "Off"
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.x">
		<FileType>Document</FileType>
		<Command>echo $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
		<LinkObjects>false</LinkObjects>
	</CustomBuild>
</ItemGroup>
		]]
	end

	function suite.linkBuildOutputs_onOn()
		files { "hello.x" }
		filter "files:**.x"
			buildcommands { "echo $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			linkbuildoutputs "On"
		prepare()
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.x">
		<FileType>Document</FileType>
		<Command>echo $(InputFile)</Command>
		<Outputs>$(InputName).obj</Outputs>
		<LinkObjects>true</LinkObjects>
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
		<ObjectFileName>$(IntDir)\hello1.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision1()
		files { "a/hello.cpp", "b/hello.cpp", "c/hello1.cpp" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\hello.cpp" />
	<ClCompile Include="b\hello.cpp">
		<ObjectFileName>$(IntDir)\hello1.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="c\hello1.cpp">
		<ObjectFileName>$(IntDir)\hello11.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision2()
		files { "a/hello1.cpp", "b/hello.cpp", "c/hello.cpp" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\hello1.cpp" />
	<ClCompile Include="b\hello.cpp" />
	<ClCompile Include="c\hello.cpp">
		<ObjectFileName>$(IntDir)\hello2.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision_Release()
		files { "a/hello.cpp", "b/hello.cpp", "c/hello1.cpp", "d/hello11.cpp" }
		filter "configurations:Debug"
			excludes {"b/hello.cpp"}
		filter "configurations:Release"
			excludes {"d/hello11.cpp"}

		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\hello.cpp" />
	<ClCompile Include="b\hello.cpp">
		<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
		<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(IntDir)\hello1.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="c\hello1.cpp">
		<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(IntDir)\hello11.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="d\hello11.cpp">
		<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
	</ClCompile>
</ItemGroup>
		]]
	end

--
-- Test that changes in case are treated as if multiple files of the same name are being built
--

	function suite.uniqueObjectNames_onSourceNameCollision_ignoreCase()
		files { "hello.cpp", "greetings/Hello.cpp" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="greetings\Hello.cpp" />
	<ClCompile Include="hello.cpp">
		<ObjectFileName>$(IntDir)\hello1.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision_ignoreCase1()
		files { "a/hello.cpp", "b/Hello.cpp", "c/hello1.cpp" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\hello.cpp" />
	<ClCompile Include="b\Hello.cpp">
		<ObjectFileName>$(IntDir)\Hello1.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="c\hello1.cpp">
		<ObjectFileName>$(IntDir)\hello11.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision_ignoreCase2()
		files { "a/hello1.cpp", "b/Hello.cpp", "c/hello.cpp" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\hello1.cpp" />
	<ClCompile Include="b\Hello.cpp" />
	<ClCompile Include="c\hello.cpp">
		<ObjectFileName>$(IntDir)\hello2.obj</ObjectFileName>
	</ClCompile>
</ItemGroup>
		]]
	end


	function suite.uniqueObjectNames_onBaseNameCollision_Release_ignoreCase()
		files { "a/Hello.cpp", "b/hello.cpp", "c/hello1.cpp", "d/hello11.cpp" }
		filter "configurations:Debug"
			excludes {"b/hello.cpp"}
		filter "configurations:Release"
			excludes {"d/hello11.cpp"}

		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="a\Hello.cpp" />
	<ClCompile Include="b\hello.cpp">
		<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</ExcludedFromBuild>
		<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(IntDir)\hello1.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="c\hello1.cpp">
		<ObjectFileName Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">$(IntDir)\hello11.obj</ObjectFileName>
	</ClCompile>
	<ClCompile Include="d\hello11.cpp">
		<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
	</ClCompile>
</ItemGroup>
		]]
	end



--
-- Check handling of per-file forced includes.
--

	function suite.forcedIncludeFiles()
		files { "hello.cpp" }
		filter "files:**.cpp"
			forceincludes { "../include/force1.h", "../include/force2.h" }

		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<ForcedIncludeFiles>..\include\force1.h;..\include\force2.h</ForcedIncludeFiles>
	</ClCompile>
</ItemGroup>
		]]
	end


--
-- Check handling of per-file command line build options.
--

	function suite.additionalOptions()
		files { "hello.cpp" }
		filter "files:**.cpp"
			buildoptions { "/Xc" }

		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<AdditionalOptions>/Xc %(AdditionalOptions)</AdditionalOptions>
	</ClCompile>
</ItemGroup>
		]]
	end

--
-- Check handling of per-file compileas options.
--

	function suite.onCompileAs()
		files { "hello.c" }
		filter "files:hello.c"
			compileas "C++"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.c">
		<CompileAs>CompileAsCpp</CompileAs>
		]]
	end

	function suite.onCompileAsDebug()
		files { "hello.c" }
		filter { "configurations:Debug", "files:hello.c" }
			compileas "C++"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.c">
		<CompileAs Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">CompileAsCpp</CompileAs>
		]]
	end

	function suite.onCompileAsExt()
		files { "hello.unknown_ext" }
		filter "files:hello.unknown_ext"
			compileas "C++"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.unknown_ext">
		<CompileAs>CompileAsCpp</CompileAs>
		]]
	end

--
-- Check handling of per-file cdialect.
--
	function suite.onCDialect()
		p.action.set("vs2019")
		cdialect "c11"
		files { "file.c", "file11.c", "file17.c" }
		filter "files:file11.c"
			cdialect "c11"
		filter "files:file17.c"
			cdialect "c17"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="file.c" />
	<ClCompile Include="file11.c">
		<LanguageStandard_C>stdc11</LanguageStandard_C>
	</ClCompile>
	<ClCompile Include="file17.c">
		<LanguageStandard_C>stdc17</LanguageStandard_C>
	</ClCompile>
  <ItemGroup>]]
	end

--
-- Check handling of per-file cppdialect.
--
	function suite.onCppDialect()
		p.action.set("vs2017")
		cppdialect "c++14"
		files { "file.cpp", "file14.cpp", "file17.cpp" }
		filter "files:file14.cpp"
			cppdialect "c++14"
		filter "files:file17.cpp"
			cppdialect "c++17"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="file.cpp" />
	<ClCompile Include="file14.cpp">
		<LanguageStandard>stdcpp14</LanguageStandard>
	</ClCompile>
	<ClCompile Include="file17.cpp">
		<LanguageStandard>stdcpp17</LanguageStandard>
	</ClCompile>
  <ItemGroup>]]
	end


--
-- Check handling of per-file optimization levels.
--

	function suite.onOptimize()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>Full</Optimization>
		]]
	end


	function suite.onOptimizeSize()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "Size"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>MinSpace</Optimization>
		]]
	end

	function suite.onOptimizeSpeed()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "Speed"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>MaxSpeed</Optimization>
		]]
	end

	function suite.onOptimizeFull()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "Full"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>Full</Optimization>
		]]
	end

	function suite.onOptimizeOff()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "Off"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>Disabled</Optimization>
		]]
	end

	function suite.onOptimizeDebug()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		optimize "Debug"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<Optimization>Disabled</Optimization>
		]]
	end



--
-- Check handling of per-file optimization levels.
--

	function suite.onPerFileRttiOn()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		rtti "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<RuntimeTypeInfo>true</RuntimeTypeInfo>
	</ClCompile>
</ItemGroup>
		]]
	end

	function suite.onPerFileRttiOff()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		rtti "Off"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<RuntimeTypeInfo>false</RuntimeTypeInfo>
	</ClCompile>
</ItemGroup>
		]]
	end

--
-- Check handling of per-file no PCH build options.
--

	function suite.excludedFromPCH()
		files { "hello.cpp" }
		filter "files:**.cpp"
		flags { "NoPCH" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<PrecompiledHeader>NotUsing</PrecompiledHeader>
	</ClCompile>
</ItemGroup>
		]]
	end



--
-- Check handling of per-file command line build options.
--

	function suite.perFileDefines()
		files { "hello.cpp" }
		filter "files:**.cpp"
			defines { "IS_CPP" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<PreprocessorDefinitions>IS_CPP;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	</ClCompile>
</ItemGroup>
		]]
	end




--
-- Check handling of per-file command line build options.
--

	function suite.perFileSEH()
		files { "hello.asm", "hello.cpp" }
		filter "files:**.asm"
			exceptionhandling 'SEH'
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp" />
</ItemGroup>
<ItemGroup>
	<Masm Include="hello.asm">
		<UseSafeExceptionHandlers>true</UseSafeExceptionHandlers>
	</Masm>
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
		filter "files:**.cpp"
			vectorextensions "sse2"
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>
	</ClCompile>
</ItemGroup>
		]]
	end


--
-- Check handling of files using custom rule definitions.
--

	function suite.isCategorizedByRule()
		rules "Animation"
		files { "hello.dae" }
		prepare()
		test.capture [[
<ItemGroup>
	<Animation Include="hello.dae" />
</ItemGroup>
		]]
	end


	function suite.listsPerConfigRuleVars()
		rules "Animation"
		files { "hello.dae" }
		filter { "files:hello.*", "configurations:Debug" }
			animationVars { AdditionalOptions = { "File1", "File2" }}
		filter { "files:hello.*", "configurations:Release" }
			animationVars { AdditionalOptions = { "File3" }}
		prepare()
		test.capture [[
<ItemGroup>
	<Animation Include="hello.dae">
		<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">File1;File2</AdditionalOptions>
		<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">File3</AdditionalOptions>
	</Animation>
</ItemGroup>
		]]
	end

--
-- test warning level set for a single file
--

	function suite.warningLevelPerFile()
		warnings 'Off'
		files { "hello.cpp", "hello2.cpp" }
		filter { "files:hello.cpp" }
			warnings 'Extra'
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<WarningLevel>Level4</WarningLevel>
	</ClCompile>
	<ClCompile Include="hello2.cpp" />
</ItemGroup>
		]]
	end

--
-- test consumewinrtextension set for a single file
--

	function suite.consumewinrtextensionPerFile()
		p.action.set("vs2019")
		files { "hello.cpp", "hello2.cpp" }
		filter { "files:hello.cpp" }
			consumewinrtextension 'On'
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<CompileAsWinRT>true</CompileAsWinRT>
	</ClCompile>
	<ClCompile Include="hello2.cpp" />
</ItemGroup>
		]]
	end

	function suite.consumewinrtextensionPerFile_BeforeVS2019()
		p.action.set("vs2017")
		files { "hello.cpp", "hello2.cpp" }
		filter { "files:hello.cpp" }
			consumewinrtextension 'On'
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp" />
	<ClCompile Include="hello2.cpp" />
</ItemGroup>
		]]
	end

--
-- tests/actions/vstudio/vc200x/test_files.lua
-- Validate generation of <files/> block in Visual Studio 200x projects.
-- Copyright (c) 2009-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs200x_files")
	local vc200x = p.vstudio.vc200x


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		p.escaper(p.vstudio.vs2005.esc)
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc200x.files(prj)
	end


--
-- Check the structure of an individual file element.
--

	function suite.file_onDefaults()
		files { "hello.cpp" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
	</File>
		]]
	end


--
-- Check the structure of a file contained in a folder.
--

	function suite.file_onSingleLevelFolder()
		files { "src/hello.cpp", "so_long.cpp" }
		prepare()
		test.capture [[
<Files>
	<Filter
		Name="src"
		>
		<File
			RelativePath="src\hello.cpp"
			>
		</File>
	</Filter>
	<File
		RelativePath="so_long.cpp"
		>
	</File>
		]]
	end


--
-- Check the structure of a file contained in multiple folders.
--

	function suite.file_onMultipleFolderLevels()
		files { "src/greetings/hello.cpp", "so_long.cpp" }
		prepare()
		test.capture [[
<Files>
	<Filter
		Name="src"
		>
		<Filter
			Name="greetings"
			>
			<File
				RelativePath="src\greetings\hello.cpp"
				>
			</File>
		</Filter>
	</Filter>
	<File
		RelativePath="so_long.cpp"
		>
	</File>
		]]
	end


--
-- Check the structure of a file with a virtual path.
--

	function suite.file_onVpath()
		files { "src/hello.cpp", "so_long.h" }
		vpaths { ["Source Files"] = "**.cpp" }
		prepare()
		test.capture [[
<Files>
	<Filter
		Name="Source Files"
		>
		<File
			RelativePath="src\hello.cpp"
			>
		</File>
	</Filter>
		]]
	end


--
-- Make sure that the special "build a C code" logic only gets triggered
-- by actual C source code files.
--

	function suite.file_markedAsNonBuildable_onSupportFiles()
		language "C"
		files { "hello.lua" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.lua"
		>
	</File>
		]]
	end


--
-- When a C code file is listed in a C++ project, it should still be
-- compiled as C (and not C++), and vice versa.
--

	function suite.compileAsSet_onCFileInCppProject()
		language "C++"
		files { "hello.c" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.c"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="1"
		]]
	end


	function suite.compileAsSet_onCppFileInCProject()
		language "C"
		files { "hello.cpp" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
		]]
	end

--
-- Check handling of per-file compileas options.
--

	function suite.onCompileAs_C_as_CPP()
		language "C"
		files { "hello.c" }
		filter {"files:hello.c"}
			compileas "C++"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.c"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
			/>
		</FileConfiguration>
	</File>
</Files>
		]]
	end

	-- make sure compileas is still omitted when it matches the language.
	function suite.onCompileAs_C_as_CPP_in_CPP()
		language "C++"
		files { "hello.c" }
		filter {"files:hello.c"}
			compileas "C++"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.c"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
			/>
		</FileConfiguration>
	</File>
</Files>
		]]
	end

	function suite.onCompileAs_C_as_CPP_release()
		language "C"
		files { "hello.c" }
		filter {"files:hello.c", "configurations:release"}
			compileas "C++"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.c"
		>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="2"
			/>
		</FileConfiguration>
	</File>
</Files>
		]]
	end

	function suite.onCompileAs_CPP_as_C()
		language "C++"
		files { "hello.cpp" }
		filter {"files:hello.cpp"}
			compileas "C"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="1"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="1"
			/>
		</FileConfiguration>
	</File>
</Files>
		]]
	end

	function suite.onCompileAs_CPP_as_C_release()
		language "C++"
		files { "hello.cpp" }
		filter {"files:hello.cpp", "configurations:release"}
			compileas "C"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				CompileAs="1"
			/>
		</FileConfiguration>
	</File>
</Files>
		]]
	end


--
-- A PCH source file should be marked as such.
--

	function suite.usePrecompiledHeadersSet_onPchSource()
		files { "afxwin.cpp" }
		pchsource "afxwin.cpp"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="afxwin.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				UsePrecompiledHeader="1"
		]]
	end


--
-- A file flagged with NoPCH should be marked as such.
--

	function suite.useNoPCHFlag()
		files { "test.cpp" }
		filter { "files:test.cpp" }
			flags { "NoPCH" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="test.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				UsePrecompiledHeader="0"
		]]
	end


--
-- A file excluded from a specific configuration should be marked as such.
--

	function suite.excludedFromBuild_onExcludedFile()
		files { "hello.cpp" }
		filter "Debug"
		removefiles { "hello.cpp" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
	</File>
		]]
	end

	function suite.excludedFromBuild_onExcludeFlag()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
	</File>
		]]
	end

	function suite.excludedFromBuild_onBuildActionNone()
		files { "hello.cpp" }
		filter "files:hello.cpp"
		buildaction "None"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
	</File>
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
<Files>
	<File
		RelativePath="hello.cg"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCLCompilerTool"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			>
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
<Files>
	<File
		RelativePath="hello.cg"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cgc $(InputFile)"
				Outputs="$(InputName).obj"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			ExcludedFromBuild="true"
			>
		]]
	end

	
	function suite.excludedFromBuild_onCustomBuildRule_buildActionNone()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
			buildaction "None"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cg"
		>
		<FileConfiguration
			Name="Debug|Win32"
			ExcludedFromBuild="true"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cgc $(InputFile)"
				Outputs="$(InputName).obj"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			ExcludedFromBuild="true"
			>
		]]
	end


--
-- If a custom build rule is supplied, the custom build tool settings should be used.
--

	function suite.customBuildTool_onBuildRule()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cxc -c "$(InputFile)" -o "$(IntDir)/$(InputName).xo"',
				'c2o -c "$(IntDir)/$(InputName).xo" -o "$(IntDir)/$(InputName).obj"'
			}
			buildoutputs { "$(IntDir)/$(InputName).obj" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.x"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cxc -c &quot;$(InputFile)&quot; -o &quot;$(IntDir)/$(InputName).xo&quot;&#x0D;&#x0A;c2o -c &quot;$(IntDir)/$(InputName).xo&quot; -o &quot;$(IntDir)/$(InputName).obj&quot;"
				Outputs="$(IntDir)/$(InputName).obj"
			/>
		</FileConfiguration>
		]]
	end

	function suite.customBuildTool_onBuildRuleMultipleBuildOutputs()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cp "$(InputFile)" "$(IntDir)/$(InputName).a"',
				'cp "$(InputFile)" "$(IntDir)/$(InputName).b"'
			}
			buildoutputs { "$(IntDir)/$(InputName).a", "$(IntDir)/$(InputName).b" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.x"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cp &quot;$(InputFile)&quot; &quot;$(IntDir)/$(InputName).a&quot;&#x0D;&#x0A;cp &quot;$(InputFile)&quot; &quot;$(IntDir)/$(InputName).b&quot;"
				Outputs="$(IntDir)/$(InputName).a;$(IntDir)/$(InputName).b"
			/>
		</FileConfiguration>
		]]
	end

	function suite.customBuildTool_onBuildRuleWithTokens()
		files { "hello.x" }
		objdir "../tmp/%{cfg.name}"
		filter "files:**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cxc -c %{file.relpath} -o %{cfg.objdir}/%{file.basename}.xo',
				'c2o -c %{cfg.objdir}/%{file.basename}.xo -o %{cfg.objdir}/%{file.basename}.obj'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.x"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cxc -c hello.x -o ../tmp/Debug/hello.xo&#x0D;&#x0A;c2o -c ../tmp/Debug/hello.xo -o ../tmp/Debug/hello.obj"
				Outputs="../tmp/Debug/hello.obj"
			/>
		</FileConfiguration>
		]]
	end

	function suite.customBuildTool_onBuildRuleWithAdditionalInputs()
		files { "hello.x" }
		filter "files:**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cxc -c "$(InputFile)" -o "$(IntDir)/$(InputName).xo"',
				'c2o -c "$(IntDir)/$(InputName).xo" -o "$(IntDir)/$(InputName).obj"'
			}
			buildoutputs { "$(IntDir)/$(InputName).obj" }
			buildinputs { "common.x.inc", "common.x.inc2" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.x"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCustomBuildTool"
				CommandLine="cxc -c &quot;$(InputFile)&quot; -o &quot;$(IntDir)/$(InputName).xo&quot;&#x0D;&#x0A;c2o -c &quot;$(IntDir)/$(InputName).xo&quot; -o &quot;$(IntDir)/$(InputName).obj&quot;"
				Outputs="$(IntDir)/$(InputName).obj"
				AdditionalDependencies="common.x.inc;common.x.inc2"
			/>
		</FileConfiguration>
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
<Files>
	<Filter
		Name="greetings"
		>
		<File
			RelativePath="greetings\hello.cpp"
			>
		</File>
	</Filter>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				ObjectFile="$(IntDir)\hello1.obj"
			/>
		</FileConfiguration>
		<FileConfiguration
			Name="Release|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				ObjectFile="$(IntDir)\hello1.obj"
			/>
		</FileConfiguration>
	</File>
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
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				ForcedIncludeFiles="..\include\force1.h;..\include\force2.h"
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
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				AdditionalOptions="/Xc"
		]]
	end


--
-- Check handling of per-file optimization levels.
--

	function suite.onOptimize()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "On"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="3"
		]]
	end


	function suite.onOptimizeSize()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "Size"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="1"
		]]
	end

	function suite.onOptimizeSpeed()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "Speed"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="2"
		]]
	end

	function suite.onOptimizeFull()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "Full"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="3"
		]]
	end

	function suite.onOptimizeOff()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "Off"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
		]]
	end

	function suite.onOptimizeDebug()
		files { "hello.cpp" }
		filter "files:**.cpp"
			optimize "Debug"
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
		]]
	end



--
-- Check handling of per-file defines.
--

	function suite.defines()
		files { "hello.cpp" }
		filter "files:hello.cpp"
			defines { "HELLO" }
		prepare()
		test.capture [[
<Files>
	<File
		RelativePath="hello.cpp"
		>
		<FileConfiguration
			Name="Debug|Win32"
			>
			<Tool
				Name="VCCLCompilerTool"
				PreprocessorDefinitions="HELLO"
		]]
	end

--
-- tests/actions/vstudio/vc200x/test_files.lua
-- Validate generation of <files/> block in Visual Studio 200x projects.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs200x_files")
	local vc200x = premake.vstudio.vc200x


--
-- Setup
--

	local sln, prj

	function suite.setup()
		io.esc = premake.vstudio.vs2005.esc
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		vc200x.files(prj)
	end


--
-- Check the structure of an individual file element.
--

	function suite.file_onDefaults()
		files { "hello.cpp" }
		prepare()
		test.capture [[
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
-- A PCH source file should be marked as such.
--

	function suite.usePrecompiledHeadersSet_onPchSource()
		files { "afxwin.cpp" }
		pchsource "afxwin.cpp"
		prepare()
		test.capture [[
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
-- A file excluded from a specific configuration should be marked as such.
--

	function suite.excludedFromBuild_onExcludedFile()
		files { "hello.cpp" }
		configuration "Debug"
		removefiles { "hello.cpp" }
		prepare()
		test.capture [[
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
		configuration "hello.cpp"
		flags { "ExcludeFromBuild" }
		prepare()
		test.capture [[
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


--
-- If a custom build rule is supplied, the custom build tool settings should be used.
--

	function suite.customBuildTool_onBuildRule()
		files { "hello.x" }
		configuration "**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cxc -c "$(InputFile)" -o "$(IntDir)/$(InputName).xo"',
				'c2o -c "$(IntDir)/$(InputName).xo" -o "$(IntDir)/$(InputName).obj"'
			}
			buildoutputs { "$(IntDir)/$(InputName).obj" }
		prepare()
		test.capture [[
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

	function suite.customBuildTool_onBuildRuleWithTokens()
		files { "hello.x" }
		objdir "../tmp/%{cfg.name}"
		configuration "**.x"
			buildmessage "Compiling $(InputFile)"
			buildcommands {
				'cxc -c %{file.relpath} -o %{cfg.objdir}/%{file.basename}.xo',
				'c2o -c %{cfg.objdir}/%{file.basename}.xo -o %{cfg.objdir}/%{file.basename}.obj'
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.obj" }
		prepare()
		test.capture [[
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


--
-- If two files at different folder levels have the same name, a different
-- object file name should be used for each.
--

	function suite.uniqueObjectNames_onSourceNameCollision()
		files { "hello.cpp", "greetings/hello.cpp" }
		prepare()
		test.capture [[
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
		language "C++"
		files { "hello.cpp" }
		configuration "**.cpp"
			forceincludes { "../include/force1.h", "../include/force2.h" }

		prepare()
		test.capture [[
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
		language "C++"
		files { "hello.cpp" }
		configuration "**.cpp"
			buildoptions { "/Xc" }

		prepare()
		test.capture [[
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

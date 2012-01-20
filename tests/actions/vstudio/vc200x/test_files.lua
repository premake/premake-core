--
-- tests/actions/vstudio/vc200x/test_files.lua
-- Validate generation of <files/> block in Visual Studio 200x projects.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs200x_files = { }
	local suite = T.vstudio_vs200x_files
	local vc200x = premake.vstudio.vc200x


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		vc200x.files_ng(prj)
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

	function suite.file_inSingleLevelFolder()
		files { "src/hello.cpp" }
		prepare()
		test.capture [[
		<Filter
			Name="src"
			Filter=""
			>
			<File
				RelativePath="src\hello.cpp"
				>
			</File>
		</Filter>
		]]
	end


--
-- Check the structure of a file contained in multiple folders.
--

	function suite.file_onMultipleFolderLevels()
		files { "src/greetings/hello.cpp" }
		prepare()
		test.capture [[
		<Filter
			Name="src"
			Filter=""
			>
			<Filter
				Name="greetings"
				Filter=""
				>
				<File
					RelativePath="src\greetings\hello.cpp"
					>
				</File>
			</Filter>
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
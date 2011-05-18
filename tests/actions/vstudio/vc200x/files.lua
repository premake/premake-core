--
-- tests/actions/vstudio/vc200x/files.lua
-- Validate generation of <files/> block in Visual Studio 200x projects.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
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
		premake.bake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		vc200x.Files(prj)
	end


--
-- Test grouping and nesting
--

	function suite.SimpleSourceFile()
		files { "hello.c" }
		prepare()
		test.capture [[
		<File
			RelativePath="hello.c"
			>
		</File>
		]]
	end

	function suite.SingleFolderLevel()
		files { "src/hello.c" }
		prepare()
		test.capture [[
		<Filter
			Name="src"
			Filter=""
			>
			<File
				RelativePath="src\hello.c"
				>
			</File>
		</Filter>
		]]
	end

	function suite.MultipleFolderLevels()
		files { "src/greetings/hello.c" }
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
					RelativePath="src\greetings\hello.c"
					>
				</File>
			</Filter>
		</Filter>
		]]
	end


--
-- PCH support
--

	function suite.OnPCH_OnWindows()
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
				/>
			</FileConfiguration>
			<FileConfiguration
				Name="Release|Win32"
				>
				<Tool
					Name="VCCLCompilerTool"
					UsePrecompiledHeader="1"
				/>
			</FileConfiguration>
		</File>
		]]
	end
	
	function suite.Files_OnPCH_OnXbox360()
		files { "afxwin.cpp" }
		pchsource "afxwin.cpp"
		platforms { "Xbox360" }
		prepare()
		test.capture [[
		<File
			RelativePath="afxwin.cpp"
			>
			<FileConfiguration
				Name="Debug|Xbox 360"
				>
				<Tool
					Name="VCCLX360CompilerTool"
					UsePrecompiledHeader="1"
				/>
			</FileConfiguration>
			<FileConfiguration
				Name="Release|Xbox 360"
				>
				<Tool
					Name="VCCLX360CompilerTool"
					UsePrecompiledHeader="1"
				/>
			</FileConfiguration>
		</File>
		]]
	end


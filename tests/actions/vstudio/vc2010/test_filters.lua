--
-- tests/actions/vstudio/vc2010/test_filters.lua
-- Validate generation of filter blocks in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vs2010_filters = { }
	local suite = T.vs2010_filters
	local vc2010 = premake.vstudio.vc2010	


--
-- Setup/teardown
--

	local sln, prj
	local os_uuid
	
	function suite.setup()
		os_uuid = os.uuid
		os.uuid = function() return "00112233-4455-6677-8888-99AABBCCDDEE" end
		
		_ACTION = "vs2010"
		sln, prj = test.createsolution()
	end
	
	function suite.teardown()
		os.uuid = os_uuid
	end

	local function get_buffer()
		premake.bake.buildconfigs()
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		vc2010.generate_filters(prj)
		buffer = io.endcapture()
		return buffer
	end	

	local function prepare()
		premake.bake.buildconfigs()
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
	end


--
-- Tests
--

	function suite.path_noPath_returnsNil()
		local result = vc2010.file_path("foo.h")
		test.isequal(nil,result)
	end
		
	function suite.path_hasOneDirectoryPath_returnsIsFoo()
		local path = "foo"
		local result = vc2010.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function suite.path_hasTwoDirectoryPath_returnsIsFooSlashBar()
		local path = "foo\\bar"
		local result = vc2010.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function suite.path_hasTwoDirectoryPath_returnsIsFooSlashBar_Baz()
		local path = "foo\\bar_baz"
		local result = vc2010.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function suite.path_extensionWithHyphen_returnsIsFoo()
		local path = "foo"
		local result = vc2010.file_path(path .."\\foo-bar.h")
		test.isequal(path,result)
	end
	
	function suite.path_extensionWithNumber_returnsIs2Foo()
		local path = "foo"
		local result = vc2010.file_path(path .."\\2foo.h")
		test.isequal(path,result)
	end
	
	function suite.path_hasThreeDirectoryPath_returnsIsFooSlashBarSlashBaz()
		local path = "foo\\bar\\baz"
		local result = vc2010.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function suite.path_hasDotDotSlashDirectoryPath_returnsNil()
		local path = ".."
		local result = vc2010.file_path(path .."\\foo.h")
		test.isequal(nil,result)
	end
	
	function suite.removeRelativePath_noRelativePath_returnsInput()
		local path = "foo.h"
		local result = vc2010.remove_relative_path(path)
		test.isequal("foo.h",result)
	end
	
	function suite.removeRelativePath_dotDotSlashFoo_returnsFoo()
		local path = "..\\foo"
		local result = vc2010.remove_relative_path(path)
		test.isequal("foo",result)
	end
	
	function suite.removeRelativePath_dotDotSlashDotDotSlashFoo_returnsFoo()
		local path = "..\\..\\foo"
		local result = vc2010.remove_relative_path(path)
		test.isequal("foo",result)
	end
	
	function suite.removeRelativePath_DotSlashFoo_returnsFoo()
		local path = ".\\foo"
		local result = vc2010.remove_relative_path(path)
		test.isequal("foo",result)
	end	

	function suite.clIncludeFilter_oneInputFile_bufferContainsTagClInclude()
		files 
		{ 
			"dontCare.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClInclude')
	end
	
	function suite.clIncludeFilter_oneInputFileWithoutDirectory_bufferContainsTagClIncludeOnOneLine()
		files 
		{ 
			"foo.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClInclude Include="foo.h" />')
	end
	
	function suite.clCompileFilter_oneInputFile_bufferContainsTagClCompile()
		files 
		{ 
			"dontCare.cpp"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile')
	end
	
	function suite.noneFilter_oneInputFile_bufferContainsTagNone()
		files 
		{ 
			"dontCare.ext"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<None')
	end
	
	function suite.resourceCompileFilter_oneInputFile_bufferContainsTagResourceCompile()
		files 
		{ 
			"dontCare.rc"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ResourceCompile')
	end


--
-- Filter identifiers sections
--

	function suite.UniqueIdentifiers_IsEmpty_OnRootFilesOnly()
		files { "hello.c", "goodbye.c" }
		prepare()
		vc2010.filteridgroup(prj)
		test.isemptycapture()
	end


	function suite.UniqueIdentifiers_MergeCommonSubfolders()
		files { "src/hello.c", "src/goodbye.c" }
		prepare()
		vc2010.filteridgroup(prj)
		test.capture [[
	<ItemGroup>
		<Filter Include="src">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end


	function suite.UniqueIdentifiers_ListAllSubfolders()
		files { "src/hello.c", "src/departures/goodbye.c" }
		prepare()
		vc2010.filteridgroup(prj)
		test.capture [[
	<ItemGroup>
		<Filter Include="src">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
		<Filter Include="src\departures">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end


	function suite.UniqueIdentifiers_ListVpaths()
		files { "hello.c", "goodbye.c" }
		vpaths { ["**.c"] = "Source Files" }
		prepare()
		vc2010.filteridgroup(prj)
		test.capture [[
	<ItemGroup>
		<Filter Include="Source Files">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end


	function suite.UniqueIdentifiers_ListRealAndVpaths()
		files { "hello.h", "goodbye.c" }
		vpaths { ["*.c"] = "Source Files", ["*.h"] = "Header Files" }
		prepare()
		vc2010.filteridgroup(prj)
		test.capture [[
	<ItemGroup>
		<Filter Include="Header Files">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
		<Filter Include="Source Files">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end


--
-- File/filter assignment tests
--

	function suite.FileFilters_NoFilter_OnRootFile()
		files { "hello.c", "goodbye.c" }
		prepare()
		vc2010.filefiltergroup(prj, "ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="hello.c" />
		<ClCompile Include="goodbye.c" />
	</ItemGroup>
		]]
	end


	function suite.FileFilters_NoFilter_OnRealPath()
		files { "src/hello.c" }
		prepare()
		vc2010.filefiltergroup(prj, "ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="src\hello.c">
			<Filter>src</Filter>
		</ClCompile>
	</ItemGroup>
		]]
	end


	function suite.FileFilters_HasFilter_OnVpath()
		files { "src/hello.c" }
		vpaths { ["**.c"] = "Source Files" }		
		prepare()
		vc2010.filefiltergroup(prj, "ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="src\hello.c">
			<Filter>Source Files</Filter>
		</ClCompile>
	</ItemGroup>
		]]
	end


	function suite.FileFilters_OnIncludeSection()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare()
		vc2010.filefiltergroup(prj, "ClInclude")
		test.capture [[
	<ItemGroup>
		<ClInclude Include="hello.h" />
	</ItemGroup>
		]]
	end


	function suite.FileFilters_OnResourceSection()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare()
		vc2010.filefiltergroup(prj, "ResourceCompile")
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="hello.rc" />
	</ItemGroup>
		]]
	end


	function suite.FileFilters_OnNoneSection()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare()
		vc2010.filefiltergroup(prj, "None")
		test.capture [[
	<ItemGroup>
		<None Include="hello.txt" />
	</ItemGroup>
		]]
	end
	
	
	-- one file needs a filter, another doesn't
	
	-- assigns to real paths
	
	-- assigns to vpaths
	
	-- writes none filter
	
	-- writes include filter
	
	-- writes resource filter
	-- anything else?
	
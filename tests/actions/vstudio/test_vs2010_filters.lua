	T.vs2010_filters = { }
	local vs10_filters = T.vs2010_filters
	local vs10_helpers = premake.vstudio.vs10_helpers	

	
	local sln, prj
	function vs10_filters.setup()
		_ACTION = "vs2010"
		sln = solution "MySolution"
		configurations { "Debug" }
		platforms {}
	
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
	end

	local function get_buffer()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		premake.vs2010_vcxproj_filters(prj)
		buffer = io.endcapture()
		return buffer
	end

	function vs10_filters.path_noPath_returnsNil()
		local result = vs10_helpers.file_path("foo.h")
		test.isequal(nil,result)
	end
		
	function vs10_filters.path_hasOneDirectoryPath_returnsIsFoo()
		local path = "foo"
		local result = vs10_helpers.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_hasTwoDirectoryPath_returnsIsFooSlashBar()
		local path = "foo\\bar"
		local result = vs10_helpers.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_hasTwoDirectoryPath_returnsIsFooSlashBar_Baz()
		local path = "foo\\bar_baz"
		local result = vs10_helpers.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_extensionWithHyphen_returnsIsFoo()
		local path = "foo"
		local result = vs10_helpers.file_path(path .."\\foo-bar.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_extensionWithNumber_returnsIs2Foo()
		local path = "foo"
		local result = vs10_helpers.file_path(path .."\\2foo.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_hasThreeDirectoryPath_returnsIsFooSlashBarSlashBaz()
		local path = "foo\\bar\\baz"
		local result = vs10_helpers.file_path(path .."\\foo.h")
		test.isequal(path,result)
	end
	
	function vs10_filters.path_hasDotDotSlashDirectoryPath_returnsNil()
		local path = ".."
		local result = vs10_helpers.file_path(path .."\\foo.h")
		test.isequal(nil,result)
	end
	
	function vs10_filters.removeRelativePath_noRelativePath_returnsInput()
		local path = "foo.h"
		local result = vs10_helpers.remove_relative_path(path)
		test.isequal("foo.h",result)
	end
	
	function vs10_filters.removeRelativePath_dotDotSlashFoo_returnsFoo()
		local path = "..\\foo"
		local result = vs10_helpers.remove_relative_path(path)
		test.isequal("foo",result)
	end
	
	function vs10_filters.removeRelativePath_dotDotSlashDotDotSlashFoo_returnsFoo()
		local path = "..\\..\\foo"
		local result = vs10_helpers.remove_relative_path(path)
		test.isequal("foo",result)
	end
	
	function vs10_filters.removeRelativePath_DotSlashFoo_returnsFoo()
		local path = ".\\foo"
		local result = vs10_helpers.remove_relative_path(path)
		test.isequal("foo",result)
	end	
	
	function vs10_filters.listOfDirectories_oneDirectory_returnsSizeIsOne()
		local result = vs10_helpers.list_of_directories_in_path("foo\\bar.h")
		test.isequal(1,#result)
	end
	
	function vs10_filters.listOfDirectories_oneDirectory_returnsContainsFoo()
		local result = vs10_helpers.list_of_directories_in_path("foo\\bar.h")
		test.contains(result,"foo")
	end
	
	function vs10_filters.listOfDirectories_twoDirectories_returnsSizeIsTwo()
		local result = vs10_helpers.list_of_directories_in_path("foo\\bar\\bar.h")
		test.isequal(2,#result)
	end
	
	function vs10_filters.listOfDirectories_twoDirectories_secondEntryIsFooSlashBar()
		local result = vs10_helpers.list_of_directories_in_path("foo\\bar\\bar.h")
		test.isequal("foo\\bar",result[2])
	end
	
	function vs10_filters.listOfDirectories_dotSlash_returnsIsEmpty()
		local result = vs10_helpers.list_of_directories_in_path(".\\bar.h")
		test.isequal(0,#result)
	end
	
	function vs10_filters.tableOfFileFilters_returnSizeIsTwo()
		local t =
		{
			foo = {'foo\\bar.h'},
			bar = {'foo\\bar.h'},
			baz = {'baz\\bar.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		test.isequal(2,#result)
	end
	
	function vs10_filters.tableOfFileFilters_returnContainsFoo()
		local t =
		{
			foo = {'foo\\bar.h'},
			bar = {'foo\\bar.h'},
			baz = {'baz\\bar.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		--order is not defined
		test.contains(result,'foo')
	end
	
	function vs10_filters.tableOfFileFilters_returnContainsBaz()
		local t =
		{
			foo = {'foo\\bar.h'},
			bar = {'foo\\bar.h'},
			baz = {'baz\\bar.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		--order is not defined
		test.contains(result,'baz')
	end
	
	function vs10_filters.tableOfFileFilters_returnSizeIsFour()
		local t =
		{
			foo = {'foo\\bar.h'},
			bar = {'foo\\bar\\bar.h'},
			baz = {'bar\\bar.h'},
			bazz = {'bar\\foo\\bar.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		--order is not defined
		test.isequal(4,#result)
	end
	
	function vs10_filters.tableOfFileFilters_tableHasSubTableWithTwoEntries_returnSizeIsTwo()
		local t =
		{
			foo = {'foo\\bar.h','foo\\bar\\bar.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		--order is not defined
		test.isequal(2,#result)
	end
	
	
	function vs10_filters.noInputFiles_bufferDoesNotContainTagFilter()
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,"<Filter")
	end
	
	function vs10_filters.noInputFiles_bufferDoesNotContainTagItemGroup()
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,"<ItemGroup>")
	end
	
	function vs10_filters.oneInputFileYetNoDirectory_bufferDoesNotContainTagFilter()
		files 
		{ 
			"dontCare.h"
		}
		local buffer = get_buffer()
		test.string_does_not_contain(buffer,"<Filter")
	end
	
	function vs10_filters.oneInputFileWithDirectory_bufferContainsTagFilter()
		files 
		{ 
			"dontCare\\dontCare.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,"<Filter")
	end
	
	function vs10_filters.oneInputFileWithDirectory_bufferContainsTagFilterInsideItemGroupTag()
		files 
		{ 
			"dontCare\\dontCare.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,"<ItemGroup>.*<Filter.*</Filter>.*</ItemGroup>")
	end
	
	function vs10_filters.oneInputFileWithDirectory_bufferContainsTagFilterWithIncludeSetToFoo()
		files 
		{ 
			"foo\\dontCare.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<Filter Include="foo">')
	end
	
	function vs10_filters.clIncludeFilter_oneInputFile_bufferContainsTagClInclude()
		files 
		{ 
			"dontCare.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClInclude')
	end
	
	function vs10_filters.clIncludeFilter_oneInputFileWithoutDirectory_bufferContainsTagClIncludeOnOneLine()
		files 
		{ 
			"foo.h"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClInclude Include="foo.h" />')
	end
	
	function vs10_filters.clCompileFilter_oneInputFile_bufferContainsTagClCompile()
		files 
		{ 
			"dontCare.cpp"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ClCompile')
	end
	
	function vs10_filters.noneFilter_oneInputFile_bufferContainsTagNone()
		files 
		{ 
			"dontCare.ext"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<None')
	end

	function vs10_filters.tableOfFileFilters_filterContainsDots_resultsLengthIsThree()
		t =
		{
			foo = {'src\\host\\lua-5.1.4\\foo.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		test.isequal(3,#result)
	end	
	
	function vs10_filters.tableOfFileFilters_filterContainsDots_resultContainsTheEntry()
		t =
		{
			foo = {'src\\host\\lua-5.1.4\\foo.h'}
		}
		local result = vs10_helpers.table_of_file_filters(t)
		test.contains(result,'src\\host\\lua-5.1.4')
	end	
	
	function vs10_filters.listOfDirectories_filterContainsDots_resultContainsTheEntry()
		local result = vs10_helpers.list_of_directories_in_path('src\\host\\lua.4\\foo.h')
		test.contains(result,'src\\host\\lua.4')
	end	
	
	function vs10_filters.resourceCompileFilter_oneInputFile_bufferContainsTagResourceCompile()
		files 
		{ 
			"dontCare.rc"
		}
		local buffer = get_buffer()
		test.string_contains(buffer,'<ResourceCompile')
	end

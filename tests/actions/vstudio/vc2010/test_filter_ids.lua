--
-- tests/actions/vstudio/vc2010/test_filter_ids.lua
-- Validate generation of filter unique identifiers.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vs2010_filter_ids = { }
	local suite = T.vs2010_filter_ids
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
		sln = test.createsolution()
	end
	
	function suite.teardown()
		os.uuid = os_uuid
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		vc2010.filters_uniqueidentifiers(prj)
	end


--
-- Files in the root folder (the same one as the project) don't get identifiers.
--

	function suite.groupIsEmpty_onOnlyRootFiles()
		files { "hello.c", "goodbye.c" }
		prepare()
		test.isemptycapture()
	end


--
-- Folders shared between multiple files should be reduced to a single identifier.
--

	function suite.singleIdentifier_onMultipleFilesInSameFolder()
		files { "src/hello.c", "src/goodbye.c", "so_long.h" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Filter Include="src">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end


--
-- Nested folders should each get their own unique identifier.
--

	function suite.multipleIdentifiers_forNestedFolders()
		files { "src/hello.c", "src/departures/goodbye.c", "so_long.h" }
		prepare()
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


--
-- If a file has a virtual path, that should be used to build the filters.
--

	function suite.filterUsesVpath_onVpath()
		files { "hello.c", "goodbye.h" }
		vpaths { ["Source Files"] = "**.c" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Filter Include="Source Files">
			<UniqueIdentifier>{00112233-4455-6677-8888-99AABBCCDDEE}</UniqueIdentifier>
		</Filter>
	</ItemGroup>
		]]
	end

	function suite.filterUsesVpath_onMultipleVpaths()
		files { "hello.h", "goodbye.c" }
		vpaths { ["Source Files"] = "*.c", ["Header Files"] = "*.h" }
		prepare()
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

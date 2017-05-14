--
-- tests/actions/vstudio/vc2010/test_filter_ids.lua
-- Validate generation of filter unique identifiers.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_filter_ids")
	local vc2010 = p.vstudio.vc2010


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks)
		vc2010.uniqueIdentifiers(prj)
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
		<UniqueIdentifier>{2DAB880B-99B4-887C-2230-9F7C8E38947C}</UniqueIdentifier>
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
		<UniqueIdentifier>{2DAB880B-99B4-887C-2230-9F7C8E38947C}</UniqueIdentifier>
	</Filter>
	<Filter Include="src\departures">
		<UniqueIdentifier>{BB36ED8F-A704-E195-9098-51BC7C05BDFA}</UniqueIdentifier>
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
		<UniqueIdentifier>{E9C7FDCE-D52A-8D73-7EB0-C5296AF258F6}</UniqueIdentifier>
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
		<UniqueIdentifier>{21EB8090-0D4E-1035-B6D3-48EBA215DCB7}</UniqueIdentifier>
	</Filter>
	<Filter Include="Source Files">
		<UniqueIdentifier>{E9C7FDCE-D52A-8D73-7EB0-C5296AF258F6}</UniqueIdentifier>
	</Filter>
</ItemGroup>
		]]
	end

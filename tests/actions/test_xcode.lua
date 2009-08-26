--
-- tests/actions/test_xcode.lua
-- Automated test suite for the "clean" action.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3 = { }
	local xcode = premake.xcode


--
-- Configure a solution for testing
--

	local sln, old_newid
	function T.xcode3.setup()
		_ACTION = 'xcode3'

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		
		old_newid = xcode.newid
		local next_id = 0
		xcode.newid = function()
			next_id = next_id + 1
			return string.format("%012d", next_id)
		end
	end

	function T.xcode3.teardown()
		xcode.newid = old_newid
	end
	
	local ctx
	local function prepare()
		io.capture()
		premake.buildconfigs()
		ctx = xcode.buildcontext(sln)
	end


--
-- File header/footer tests
--

	function T.xcode3.Header()
		prepare()
		xcode.header()
		test.capture [[
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 45;
	objects = {

		]]
	end

	function T.xcode3.Footer()
		prepare()
		xcode.footer()
		test.capture [[
	};
	rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;
}
		]]
	end


--
-- PBXBuildFile section tests
--

	function T.xcode3.PBXBuildFile_ListsBuildableFiles()
		files {
			"source.h", "source.c", "source.cpp",
		}
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		000000000005 /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 000000000004 /* source.c */; };
		000000000007 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 000000000006 /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end


	function T.xcode3.PBXBuildFile_ListsResourceFilesOnlyOnceWithGroupID()
		files {
			"English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib"
		}
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		000000000005 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 000000000006 /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end



--
-- PBXFileReference section tests
--

	function T.xcode3.PBXFileReference_ListsTarget()
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000004 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

		
	function T.xcode3.PBXFileReference_ListSourceTypesCorrectly()
		files {
			"source.h", "source.c", "source.cpp"
		}
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000003 /* source.h */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.h; name = source.h; path = source.h; sourceTree = "<group>"; };
		000000000004 /* source.c */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		000000000006 /* source.cpp */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.cpp.cpp; name = source.cpp; path = source.cpp; sourceTree = "<group>"; };
		]]
	end


	function T.xcode3.PBXFileReference_ListResourcesCorrectly()
		files {
			"English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib"
		}
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000004 /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		000000000008 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end



--
-- PBXVariantGroup section tests
--

	function T.xcode3.PBXVariantGroup_ListsResourceGroups()
		files {
			"English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib"
		}
		prepare()
		xcode.PBXVariantGroup(ctx)
		test.capture [[
/* Begin PBXVariantGroup section */
		000000000006 /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				000000000004 /* English */,
				000000000008 /* French */,
			);
			name = MainMenu.xib;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */
		]]
	end



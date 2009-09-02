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
		xcode.newid = function()
			return string.format("000000000000")
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
	
	local function project2()
		project "MyProject2"
		language "C++"
		kind "ConsoleApp"
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

	function T.xcode3.PBXBuildFile_ListsBuildableSources()
		files {
			"source.h", "source.c", "source.cpp", "Info.plist",
		}
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		000000000000 /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000 /* source.c */; };
		000000000000 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000 /* source.cpp */; };
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
		000000000000 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 000000000000 /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function T.xcode3.PBXBuildFile_SeparatesResourcesByProject()
		files { "MyProject/English.lproj/MainMenu.xib", "MyProject/French.lproj/MainMenu.xib" }
		project2()
		files { "MyProject2/English.lproj/MainMenu.xib", "MyProject2/French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		000000000000 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 000000000000 /* MainMenu.xib */; };
		000000000000 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 000000000000 /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function T.xcode3.PBXBuildFile_ListsFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		000000000000 /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 000000000000 /* Cocoa.framework */; };
/* End PBXBuildFile section */
		]]
	end



--
-- PBXFileReference section tests
--

	function T.xcode3.PBXFileReference_ListsConsoleTarget()
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000000 /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function T.xcode3.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000000 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
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
		000000000000 /* source.h */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.h; name = source.h; path = source.h; sourceTree = "<group>"; };
		000000000000 /* source.c */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		000000000000 /* source.cpp */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.cpp.cpp; name = source.cpp; path = source.cpp; sourceTree = "<group>"; };
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
		000000000000 /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		000000000000 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end


	function T.xcode3.PBXFileReference_SeparatesResourcesByProject()
		files { "MyProject/English.lproj/MainMenu.xib", "MyProject/French.lproj/MainMenu.xib" }
		project2()
		files { "MyProject2/English.lproj/MainMenu.xib", "MyProject2/French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000000 /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		000000000000 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		000000000000 /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		000000000000 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end

		
	function T.xcode3.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000000 /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = /System/Library/Frameworks/Cocoa.framework; sourceTree = "<absolute>"; };
		]]
	end

		
	function T.xcode3.PBXFileReference_ListPListCorrectly()
		files { "Info.plist" }
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		000000000000 /* Info.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; name = Info.plist; path = Info.plist; sourceTree = "<group>"; };
		000000000000 /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end



--
-- PBXFrameworksBuildPhase section tests
--

	function T.xcode3.PBXFrameworksBuild_OnNoFiles()
		prepare()
		xcode.PBXFrameworksBuildPhase(ctx)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		000000000000 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


	function T.xcode3.PBXFrameworksBuild_ListsFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFrameworksBuildPhase(ctx)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		000000000000 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				000000000000 /* Cocoa.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


--
-- PBXGroup section tests
--

	function T.xcode3.PBXGroup_OnNoFiles()
		prepare()
		xcode.PBXGroup(ctx)
		test.capture [[
/* Begin PBXGroup section */
		000000000000 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* Resources */,
				000000000000 /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_RootFilesInMainGroup()
		files { "source.h" }
		prepare()
		xcode.PBXGroup(ctx)
		test.capture [[
/* Begin PBXGroup section */
		000000000000 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* source.h */,
				000000000000 /* Resources */,
				000000000000 /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_CreateSubGroups()
		files { "include/source.h" }
		prepare()
		xcode.PBXGroup(ctx)
		test.capture [[
/* Begin PBXGroup section */
		000000000000 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* include */,
				000000000000 /* Resources */,
				000000000000 /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		000000000000 /* include */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* source.h */,
			);
			name = include;
			path = include;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_CreatesResourceSubgroup()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXGroup(ctx)
		test.capture [[
/* Begin PBXGroup section */
		000000000000 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* Resources */,
				000000000000 /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		000000000000 /* Resources */ = {
			isa = PBXGroup;
			children = (
				000000000000 /* MainMenu.xib */,
				000000000000 /* Info.plist */,
			);
			name = Resources;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
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
		000000000000 /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				000000000000 /* French */,
				000000000000 /* English */,
			);
			name = MainMenu.xib;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */
		]]
	end

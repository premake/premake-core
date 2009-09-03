--
-- tests/actions/test_xcode.lua
-- Automated test suite for the "clean" action.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3 = { }
	local xcode = premake.xcode


--
-- Replacement for xcode.newid(). This one creates a synthetic ID based on the node name,
-- it's intended usage (file ID, build ID, etc.) and it's place in the tree. This makes
-- it easier to tell if the right ID is being used in the right places.
--

	local used_ids = {}
	local function newtestableid(node, usage)
		if not usage and #node.children == 0 then
			if node.languages then
				usage = "group"
			elseif not node.stageid then
				usage = "file"
			end
		end

		local name = node.name
		if usage then
			name = name .. ":" .. usage
		end
		
		if used_ids[name] then
			local count = used_ids[name] + 1
			used_ids[name] = count
			name = name .. "(" .. count .. ")"
		else
			used_ids[name] = 1
		end
		return "[" .. name .. "]"
	end


--
-- Configure a solution for testing
--

	local sln, old_newid
	function T.xcode3.setup()
		_ACTION = 'xcode3'

		old_newid = xcode.newid
		xcode.newid = newtestableid
		used_ids = { }
		
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
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
		[source.c:build] /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = [source.c:file] /* source.c */; };
		[source.cpp:build] /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = [source.cpp:file] /* source.cpp */; };
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
		[MainMenu.xib:build] /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = [MainMenu.xib:group] /* MainMenu.xib */; };
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
		[MainMenu.xib:build] /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = [MainMenu.xib:group] /* MainMenu.xib */; };
		[MainMenu.xib:build(2)] /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = [MainMenu.xib:group(2)] /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function T.xcode3.PBXBuildFile_ListsFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXBuildFile(ctx)
		test.capture [[
/* Begin PBXBuildFile section */
		[Cocoa.framework:build] /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = [Cocoa.framework:file] /* Cocoa.framework */; };
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
		[MyProject:file] /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function T.xcode3.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:file] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[source.h:file] /* source.h */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.h; name = source.h; path = source.h; sourceTree = "<group>"; };
		[source.c:file] /* source.c */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		[source.cpp:file] /* source.cpp */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.cpp.cpp; name = source.cpp; path = source.cpp; sourceTree = "<group>"; };
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
		[MainMenu.xib:file] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[MainMenu.xib:file(2)] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
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
		[MainMenu.xib:file] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[MainMenu.xib:file(2)] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[MainMenu.xib:file(3)] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[MainMenu.xib:file(4)] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end

		
	function T.xcode3.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		[Cocoa.framework:file] /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = /System/Library/Frameworks/Cocoa.framework; sourceTree = "<absolute>"; };
		]]
	end

		
	function T.xcode3.PBXFileReference_ListPListCorrectly()
		files { "Info.plist" }
		prepare()
		xcode.PBXFileReference(ctx)
		test.capture [[
/* Begin PBXFileReference section */
		[Info.plist:file] /* Info.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; name = Info.plist; path = Info.plist; sourceTree = "<group>"; };
		[MyProject:file] /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[MyProject:frameworks] /* Frameworks */ = {
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
		[MyProject:frameworks] /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[Cocoa.framework:build] /* Cocoa.framework in Frameworks */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Resources] /* Resources */,
				[Frameworks] /* Frameworks */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[source.h:file] /* source.h */,
				[Resources] /* Resources */,
				[Frameworks] /* Frameworks */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[include] /* include */,
				[Resources] /* Resources */,
				[Frameworks] /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[include] /* include */ = {
			isa = PBXGroup;
			children = (
				[source.h:file] /* source.h */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Resources] /* Resources */,
				[Frameworks] /* Frameworks */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Resources] /* Resources */ = {
			isa = PBXGroup;
			children = (
				[MainMenu.xib:group] /* MainMenu.xib */,
				[Info.plist:file] /* Info.plist */,
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
		[MainMenu.xib:group] /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				[MainMenu.xib:file(2)] /* French */,
				[MainMenu.xib:file] /* English */,
			);
			name = MainMenu.xib;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */
		]]
	end

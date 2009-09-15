--
-- tests/actions/test_xcode.lua
-- Automated test suite for the "clean" action.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3 = { }
	local xcode = premake.xcode


--
-- Replacement for xcode.newid(). Creates a synthetic ID based on the node name,
-- it's intended usage (file ID, build ID, etc.) and its place in the tree. This 
-- makes it easier to tell if the right ID is being used in the right places.
--

	local used_ids = {}
	
	xcode.newid = function(node, usage)
		-- assign special usages depending on where this node lives in the tree,
		-- to help distinguish nodes that are likely to have the same name
		if not usage and node.parent then
			local grandparent = node.parent.parent
			if grandparent then
				if node.parent == grandparent.products then
					usage = "product"
				end
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
-- Setup
--

	local sln, tr
	function T.xcode3.setup()
		-- reset the list of generated IDs
		used_ids = { }
		sln = test.createsolution()
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		tr = xcode.buildtree(sln)
	end



---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function T.xcode3.PBXBuildFile_ListsBuildableSources()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[source.c:build] /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = [source.c] /* source.c */; };
		[source.cpp:build] /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = [source.cpp] /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end



---------------------------------------------------------------------------
-- PBXFileReference tests
---------------------------------------------------------------------------

	function T.xcode3.PBXFileReference_ListsConsoleTarget()
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; name = MyProject; path = ../MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function T.xcode3.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:product] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = ../MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function T.xcode3.PBXFileReference_ConvertsProjectTargetsToSolutionRelative()
		targetdir "../bin"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = compiled.mach-o.executable; includeInIndex = 0; name = MyProject; path = ../../bin/MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function T.xcode3.PBXFileReference_ListsSourceFiles()
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[source.c] /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		]]
	end

	function T.xcode3.PBXFileReference_ConvertsProjectSourcesToSolutionRelative()
		location "ProjectFolder"
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[source.c] /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		]]
	end
	
	function T.xcode3.PBXFileReference_ListResourcesCorrectly()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[English] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[French] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end
	
	
	function T.xcode3.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[Cocoa.framework] /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = /System/Library/Frameworks/Cocoa.framework; sourceTree = "<absolute>"; };
		]]
	end




---------------------------------------------------------------------------
-- PBXGroup tests
---------------------------------------------------------------------------

	function T.xcode3.PBXGroup_OnOneProjectNoFiles()
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_OnMultipleProjectsNoFiles()
		test.createproject(sln)
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MySolution] /* MySolution */ = {
			isa = PBXGroup;
			children = (
				[MyProject] /* MyProject */,
				[MyProject2] /* MyProject2 */,
				[Products] /* Products */,
			);
			name = MySolution;
			sourceTree = "<group>";
		};
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[MyProject2] /* MyProject2 */ = {
			isa = PBXGroup;
			children = (
			);
			name = MyProject2;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
				[MyProject2:product] /* MyProject2 */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_OnSourceFiles()
		files { "source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_OnSourceSubdirs()
		files { "include/source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[include] /* include */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[include] /* include */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
			);
			name = include;
			path = include;
			sourceTree = "<group>";
		};
		]]
	end


	function T.xcode3.PBXGroup_OnResourceFiles()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Info.plist] /* Info.plist */,
				[MainMenu.xib] /* MainMenu.xib */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_OnFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Frameworks] /* Frameworks */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Frameworks] /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				[Cocoa.framework] /* Cocoa.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
		]]
	end
	
--
-- tests/actions/xcode/test_xcode_dependencies.lua
-- Automated test suite for Xcode project dependencies.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3_deps = { }
	
	local suite = T.xcode3_deps
	local xcode = premake.xcode


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local sln, tr
	function suite.setup()
		premake.action.set("xcode3")
		xcode.used_ids = { } -- reset the list of generated IDs

		sln = test.createsolution()
		links { "MyProject2" }
		test.createproject(sln)
		kind "StaticLib"
		configuration "Debug"
		targetsuffix "-d"
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		xcode.preparesolution(sln)
		local prj = premake.solution.getproject(sln, 1)
		tr = xcode.buildprjtree(prj)
	end


---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function suite.PBXBuildFile_ListsDependencyTargets()
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[libMyProject2-d.a:build] /* libMyProject2-d.a in Frameworks */ = {isa = PBXBuildFile; fileRef = [libMyProject2-d.a] /* libMyProject2-d.a */; };
/* End PBXBuildFile section */
		]]
	end


---------------------------------------------------------------------------
-- PBXContainerItemProxy tests
---------------------------------------------------------------------------

	function suite.PBXContainerItemProxy_ListsProjectConfigs()
		prepare()
		xcode.PBXContainerItemProxy(tr)
		test.capture [[
/* Begin PBXContainerItemProxy section */
		[MyProject2.xcodeproj:prodprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [MyProject2.xcodeproj] /* MyProject2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = [libMyProject2-d.a:product];
			remoteInfo = "libMyProject2-d.a";
		};
		[MyProject2.xcodeproj:targprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [MyProject2.xcodeproj] /* MyProject2.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = [libMyProject2-d.a:target];
			remoteInfo = "libMyProject2-d.a";
		};
/* End PBXContainerItemProxy section */
		]]		
	end


---------------------------------------------------------------------------
-- PBXFileReference tests
---------------------------------------------------------------------------

	function suite.PBXFileReference_ListsDependencies()
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = "MyProject"; path = "MyProject"; sourceTree = BUILT_PRODUCTS_DIR; };
		[MyProject2.xcodeproj] /* MyProject2.xcodeproj */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "MyProject2.xcodeproj"; path = "MyProject2.xcodeproj"; sourceTree = SOURCE_ROOT; };
/* End PBXFileReference section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXFrameworksBuildPhase_ListsDependencies()
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		[MyProject:fxs] /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[libMyProject2-d.a:build] /* libMyProject2-d.a in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end

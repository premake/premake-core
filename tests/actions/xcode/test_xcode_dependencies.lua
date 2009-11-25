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
		[MyProject2.xcodeproj:remote] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [MyProject2.xcodeproj] /* MyProject2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = [Product ID];
			remoteInfo = "libMyProject2-d.a";
		};
		967BE4EA10B5D6F200E9EC24 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 967BE4E010B5D6C900E9EC24 /* MyLibrary.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = [Native target ID];
			remoteInfo = "libMyLibrary2-d.a";
		};
/* End PBXContainerItemProxy section */
		]]		
	end

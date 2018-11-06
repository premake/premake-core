--
-- tests/actions/xcode/test_xcode_dependencies.lua
-- Automated test suite for Xcode project dependencies.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

	local suite = test.declare("xcode_external")
	local p = premake
	local xcode = p.modules.xcode


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, eprj1, etrg1, etrg2, tr

	function suite.teardown()
		wks = nil
		prj = nil
		eprj1 = nil
		etrg1 = nil
		etrg2 = nil
		tr = nil
	end

	function suite.setup()
		_TARGET_OS = "macosx"
		p.action.set('xcode4')
		xcode.used_ids = { } -- reset the list of generated IDs

		wks, prj = test.createWorkspace()
		links { "External1", "Target1@External2", "Target2@External2" }

		local function createExternalProject(name)
			local prj = externalproject(name)
			kind "StaticLib"
			language "C"
			return prj
		end

		eprj1 = createExternalProject("External1")
		etrg1 = createExternalProject("Target1@External2")
		etrg2 = createExternalProject("Target2@External2")
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		xcode.prepareWorkspace(wks)
		local prj3 = p.workspace.getproject(wks, 1)
		--prj2 = test.getproject(wks, 2)
		tr = xcode.buildprjtree(prj3)
	end


---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function suite.PBXBuildFile_ListsDependencyTargets_OnExternalProject()
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[libExternal1.a:build] /* libExternal1.a in Frameworks */ = {isa = PBXBuildFile; fileRef = [libExternal1.a] /* libExternal1.a */; };
		[libTarget1@External2.a:build] /* libTarget1.a in Frameworks */ = {isa = PBXBuildFile; fileRef = [libTarget1@External2.a] /* libTarget1.a */; };
		[libTarget2@External2.a:build] /* libTarget2.a in Frameworks */ = {isa = PBXBuildFile; fileRef = [libTarget2@External2.a] /* libTarget2.a */; };
/* End PBXBuildFile section */
		]]
	end


---------------------------------------------------------------------------
-- PBXContainerItemProxy tests
---------------------------------------------------------------------------

	function suite.PBXContainerItemProxy_ListsProjectConfigs_OnExternalProject()
		prepare()
		xcode.PBXContainerItemProxy(tr)
		test.capture [[
/* Begin PBXContainerItemProxy section */
		[External1.xcodeproj:prodprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [External1.xcodeproj] /* External1.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = [External1:product];
			remoteInfo = External1;
		};
		[External1.xcodeproj:targprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [External1.xcodeproj] /* External1.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = [External1:target];
			remoteInfo = External1;
		};
		[Target1@External2.xcodeproj:prodprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [Target1@External2.xcodeproj] /* External2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = [Target1@External2:product];
			remoteInfo = Target1;
		};
		[Target1@External2.xcodeproj:targprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [Target1@External2.xcodeproj] /* External2.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = [Target1@External2:target];
			remoteInfo = Target1;
		};
		[Target2@External2.xcodeproj:prodprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [Target2@External2.xcodeproj] /* External2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = [Target2@External2:product];
			remoteInfo = Target2;
		};
		[Target2@External2.xcodeproj:targprox] /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = [Target2@External2.xcodeproj] /* External2.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = [Target2@External2:target];
			remoteInfo = Target2;
		};
/* End PBXContainerItemProxy section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFileReference tests
---------------------------------------------------------------------------

	function suite.PBXFileReference_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[External1.xcodeproj] /* libExternal1.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "External1.xcodeproj"; path = External1.xcodeproj; sourceTree = SOURCE_ROOT; };
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		[Target1@External2.xcodeproj] /* libTarget1.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "External2.xcodeproj"; path = External2.xcodeproj; sourceTree = SOURCE_ROOT; };
		[Target2@External2.xcodeproj] /* libTarget2.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "External2.xcodeproj"; path = External2.xcodeproj; sourceTree = SOURCE_ROOT; };
/* End PBXFileReference section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXFrameworksBuildPhase_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		[MyProject:fxs] /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[libExternal1.a:build] /* libExternal1.a in Frameworks */,
				[libTarget1@External2.a:build] /* libTarget1.a in Frameworks */,
				[libTarget2@External2.a:build] /* libTarget2.a in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXGroup tests
---------------------------------------------------------------------------

	function suite.PBXGroup_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[External1.xcodeproj:prodgrp] /* Products */ = {
			isa = PBXGroup;
			children = (
				[libExternal1.a] /* libExternal1.a */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Products] /* Products */,
				[Projects] /* Projects */,
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
		[Projects] /* Projects */ = {
			isa = PBXGroup;
			children = (
				[External1.xcodeproj] /* External1.xcodeproj */,
				[Target1@External2.xcodeproj] /* External2.xcodeproj */,
				[Target2@External2.xcodeproj] /* External2.xcodeproj */,
			);
			name = Projects;
			sourceTree = "<group>";
		};
		[Target1@External2.xcodeproj:prodgrp] /* Products */ = {
			isa = PBXGroup;
			children = (
				[libTarget1@External2.a] /* libTarget1.a */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		[Target2@External2.xcodeproj:prodgrp] /* Products */ = {
			isa = PBXGroup;
			children = (
				[libTarget2@External2.a] /* libTarget2.a */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


---------------------------------------------------------------------------
-- PBXNativeTarget tests
---------------------------------------------------------------------------

	function suite.PBXNativeTarget_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		[MyProject:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[MyProject:rez] /* Resources */,
				[MyProject:src] /* Sources */,
				[MyProject:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
				[External1.xcodeproj:targdep] /* PBXTargetDependency */,
				[Target1@External2.xcodeproj:targdep] /* PBXTargetDependency */,
				[Target2@External2.xcodeproj:targdep] /* PBXTargetDependency */,
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXProject tests
---------------------------------------------------------------------------

	function suite.PBXProject_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = [MyProject] /* MyProject */;
			projectDirPath = "";
			projectReferences = (
				{
					ProductGroup = [External1.xcodeproj:prodgrp] /* Products */;
					ProjectRef = [External1.xcodeproj] /* External1.xcodeproj */;
				},
				{
					ProductGroup = [Target1@External2.xcodeproj:prodgrp] /* Products */;
					ProjectRef = [Target1@External2.xcodeproj] /* External2.xcodeproj */;
				},
				{
					ProductGroup = [Target2@External2.xcodeproj:prodgrp] /* Products */;
					ProjectRef = [Target2@External2.xcodeproj] /* External2.xcodeproj */;
				},
			);
			projectRoot = "";
			targets = (
				[MyProject:target] /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


---------------------------------------------------------------------------
-- PBXReferenceProxy tests
---------------------------------------------------------------------------

	function suite.PBXReferenceProxy_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXReferenceProxy(tr)
		test.capture [[
/* Begin PBXReferenceProxy section */
		[libExternal1.a] /* libExternal1.a */ = {
			isa = PBXReferenceProxy;
			fileType = archive.ar;
			path = libExternal1.a;
			remoteRef = [External1.xcodeproj:prodprox] /* PBXContainerItemProxy */;
			sourceTree = BUILT_PRODUCTS_DIR;
		};
		[libTarget1@External2.a] /* libTarget1.a */ = {
			isa = PBXReferenceProxy;
			fileType = archive.ar;
			path = libTarget1.a;
			remoteRef = [Target1@External2.xcodeproj:prodprox] /* PBXContainerItemProxy */;
			sourceTree = BUILT_PRODUCTS_DIR;
		};
		[libTarget2@External2.a] /* libTarget2.a */ = {
			isa = PBXReferenceProxy;
			fileType = archive.ar;
			path = libTarget2.a;
			remoteRef = [Target2@External2.xcodeproj:prodprox] /* PBXContainerItemProxy */;
			sourceTree = BUILT_PRODUCTS_DIR;
		};
/* End PBXReferenceProxy section */
		]]
	end


---------------------------------------------------------------------------
-- PBXTargetDependency tests
---------------------------------------------------------------------------

	function suite.PBXTargetDependency_ListsDependencies_OnExternalProject()
		prepare()
		xcode.PBXTargetDependency(tr)
		test.capture [[
/* Begin PBXTargetDependency section */
		[External1.xcodeproj:targdep] /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			name = libExternal1.a;
			targetProxy = [External1.xcodeproj:targprox] /* PBXContainerItemProxy */;
		};
		[Target1@External2.xcodeproj:targdep] /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			name = libTarget1.a;
			targetProxy = [Target1@External2.xcodeproj:targprox] /* PBXContainerItemProxy */;
		};
		[Target2@External2.xcodeproj:targdep] /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			name = libTarget2.a;
			targetProxy = [Target2@External2.xcodeproj:targprox] /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */
		]]
	end

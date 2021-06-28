--
-- tests/actions/xcode/test_xcode_dependencies.lua
-- Automated test suite for Xcode project dependencies.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

	local suite = test.declare("xcode_deps")
	local p = premake
	local xcode = p.modules.xcode


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, prj2, tr

	function suite.teardown()
		wks = nil
		prj = nil
		prj2 = nil
		tr = nil
	end

	function suite.setup()
		_TARGET_OS = "macosx"
		p.action.set('xcode4')

		wks, prj = test.createWorkspace()
		links { "MyProject2" }

		prj2 = test.createproject(wks)
		kind "StaticLib"
		configuration "Debug"
		targetsuffix "-d"
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

	function suite.PBXBuildFile_ListsDependencyTargets_OnStaticLib()
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		5931FBCA4D31453CD21C5A0A /* libMyProject2-d.a in Frameworks */ = {isa = PBXBuildFile; fileRef = CCB6C53210CA9664049C1B72 /* libMyProject2-d.a */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDependencyTargets_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		1BC538B0FA67D422AF49D6F0 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 107168B810144BEA4A68FEF8 /* libMyProject2-d.dylib */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDependencyTargets_OnSharedLibWhenEmbedding()
		kind "SharedLib"

		project "MyProject"
		embed { "MyProject2" }

		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		1BC538B0FA67D422AF49D6F0 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 107168B810144BEA4A68FEF8 /* libMyProject2-d.dylib */; };
		6514841E8D4F3CD074EACA5E /* libMyProject2-d.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 107168B810144BEA4A68FEF8 /* libMyProject2-d.dylib */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDependencyTargets_OnSharedLibWhenEmbeddingAndSigning()
		kind "SharedLib"

		project "MyProject"
		embedAndSign { "MyProject2" }

		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		1BC538B0FA67D422AF49D6F0 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 107168B810144BEA4A68FEF8 /* libMyProject2-d.dylib */; };
		6514841E8D4F3CD074EACA5E /* libMyProject2-d.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 107168B810144BEA4A68FEF8 /* libMyProject2-d.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
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
		17DF877139AB34A376605DB1 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = CBD893DEB01F9C10340CCA1E /* MyProject2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = E052136F28C2F7A16D61C9AF;
			remoteInfo = "libMyProject2-d.a";
		};
		6A19FA0A8BE5A73CC89AD04A /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = CBD893DEB01F9C10340CCA1E /* MyProject2.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = DA5DB975C549DF670D2FA7B5;
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
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		CBD893DEB01F9C10340CCA1E /* libMyProject2-d.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "MyProject2.xcodeproj"; path = MyProject2.xcodeproj; sourceTree = SOURCE_ROOT; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_UsesRelativePaths()
		prj.location = "MyProject"
		prj2.location = "MyProject2"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		149CF6C96C0269BB1E108509 /* libMyProject2-d.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "MyProject2.xcodeproj"; path = ../MyProject2.xcodeproj; sourceTree = SOURCE_ROOT; };
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXFrameworksBuildPhase_ListsDependencies_OnStaticLib()
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		9FDD37564328C0885DF98D96 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				5931FBCA4D31453CD21C5A0A /* libMyProject2-d.a in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end

	function suite.PBXFrameworksBuildPhase_ListsDependencies_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		9FDD37564328C0885DF98D96 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				1BC538B0FA67D422AF49D6F0 /* libMyProject2-d.dylib in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end

function suite.PBXFrameworksBuildPhase_ListsDependencies_OnSharedLibWithTargetExtension()
		kind "SharedLib"
		targetextension ".plugin"
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		9FDD37564328C0885DF98D96 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				6B7205267D294518F2973366 /* libMyProject2-d.plugin in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end
---------------------------------------------------------------------------
-- PBXCopyFilesBuildPhaseForEmbedFrameworks tests
---------------------------------------------------------------------------

	function suite.PBXCopyFilesBuildPhaseForEmbedFrameworks_ListsDependencies_OnSharedLib()
		kind "SharedLib"

		project "MyProject"
		embed { "MyProject2" }

		prepare()
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		test.capture [[
/* Begin PBXCopyFilesBuildPhase section */
		E1D3B542862652F4985E9B82 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
				6514841E8D4F3CD074EACA5E /* MyProject2 in Projects */,
			);
			name = "Embed Libraries";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
		]]
	end

---------------------------------------------------------------------------
-- PBXGroup tests
---------------------------------------------------------------------------

	function suite.PBXGroup_ListsDependencies()
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				A6C936B49B3FADE6EA134CF4 /* Products */,
				9D968EAA920D05DCE0E0A4EA /* Projects */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		9D968EAA920D05DCE0E0A4EA /* Projects */ = {
			isa = PBXGroup;
			children = (
				CBD893DEB01F9C10340CCA1E /* MyProject2.xcodeproj */,
			);
			name = Projects;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		C7F36A91F7853983D29278D1 /* Products */ = {
			isa = PBXGroup;
			children = (
				CCB6C53210CA9664049C1B72 /* libMyProject2-d.a */,
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

	function suite.PBXNativeTarget_ListsDependencies()
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				0FC4B7F6B3104128CDE10E36 /* Resources */,
				7971D14D1CBD5A7F378E278D /* Sources */,
				9FDD37564328C0885DF98D96 /* Frameworks */,
				E1D3B542862652F4985E9B82 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
				B5ABA79AE53D768CC04AB5DA /* PBXTargetDependency */,
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 19A5C4E61D1697189E833B26 /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXProject tests
---------------------------------------------------------------------------

	function suite.PBXProject_ListsDependencies()
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = 12F5A37D963B00EFBF8281BD /* MyProject */;
			projectDirPath = "";
			projectReferences = (
				{
					ProductGroup = C7F36A91F7853983D29278D1 /* Products */;
					ProjectRef = CBD893DEB01F9C10340CCA1E /* MyProject2.xcodeproj */;
				},
			);
			projectRoot = "";
			targets = (
				48B5980C775BEBFED09D464C /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


---------------------------------------------------------------------------
-- PBXReferenceProxy tests
---------------------------------------------------------------------------

	function suite.PBXReferenceProxy_ListsDependencies()
		prepare()
		xcode.PBXReferenceProxy(tr)
		test.capture [[
/* Begin PBXReferenceProxy section */
		CCB6C53210CA9664049C1B72 /* libMyProject2-d.a */ = {
			isa = PBXReferenceProxy;
			fileType = archive.ar;
			path = "libMyProject2-d.a";
			remoteRef = 17DF877139AB34A376605DB1 /* PBXContainerItemProxy */;
			sourceTree = BUILT_PRODUCTS_DIR;
		};
/* End PBXReferenceProxy section */
		]]
	end


---------------------------------------------------------------------------
-- PBXTargetDependency tests
---------------------------------------------------------------------------

	function suite.PBXTargetDependency_ListsDependencies()
		prepare()
		xcode.PBXTargetDependency(tr)
		test.capture [[
/* Begin PBXTargetDependency section */
		B5ABA79AE53D768CC04AB5DA /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			name = "libMyProject2-d.a";
			targetProxy = 6A19FA0A8BE5A73CC89AD04A /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */
		]]
	end

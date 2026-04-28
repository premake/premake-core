--
-- tests/actions/xcode/test_xcode_dependencies.lua
-- Automated test suite for Xcode project dependencies.
-- Copyright (c) 2009-2011 Jess Perkins and the Premake project
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
		filter { "configurations:Debug" }
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
		2F94773A02AA944E30F15EB3 /* libMyProject2-d.a in Frameworks */ = {isa = PBXBuildFile; fileRef = E0BB4A5ECEA9F79291B44FDE /* libMyProject2-d.a */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDependencyTargets_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		1D069AC79B8AAE38BF343B15 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 333AB282CB1B2A216C4859C9 /* libMyProject2-d.dylib */; };
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
		1D069AC79B8AAE38BF343B15 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 333AB282CB1B2A216C4859C9 /* libMyProject2-d.dylib */; };
		6BC26EEF1B0718BCCE190FC0 /* libMyProject2-d.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 333AB282CB1B2A216C4859C9 /* libMyProject2-d.dylib */; };
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
		1D069AC79B8AAE38BF343B15 /* libMyProject2-d.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 333AB282CB1B2A216C4859C9 /* libMyProject2-d.dylib */; };
		6BC26EEF1B0718BCCE190FC0 /* libMyProject2-d.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 333AB282CB1B2A216C4859C9 /* libMyProject2-d.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
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
		09112916D122CACC9994A304 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 026A2D9F664E1FB990F29FAF /* MyProject2.xcodeproj */;
			proxyType = 2;
			remoteGlobalIDString = 40A82D46749A09A676592446;
			remoteInfo = "libMyProject2-d.a";
		};
		D976322FD9860EA24851484C /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 026A2D9F664E1FB990F29FAF /* MyProject2.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = A679A446400799097E12FCA9;
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
		026A2D9F664E1FB990F29FAF /* libMyProject2-d.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "MyProject2.xcodeproj"; path = MyProject2.xcodeproj; sourceTree = SOURCE_ROOT; };
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
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
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		F600AA92BED2D479CE828780 /* libMyProject2-d.a */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = "MyProject2.xcodeproj"; path = ../MyProject2.xcodeproj; sourceTree = SOURCE_ROOT; };
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
		80C3A7BC2BDDF59FD06C145A /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				2F94773A02AA944E30F15EB3 /* libMyProject2-d.a in Frameworks */,
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
		80C3A7BC2BDDF59FD06C145A /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				1D069AC79B8AAE38BF343B15 /* libMyProject2-d.dylib in Frameworks */,
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
		80C3A7BC2BDDF59FD06C145A /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				37CE8D67AE0E879481A5551F /* libMyProject2-d.plugin in Frameworks */,
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
		9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
				6BC26EEF1B0718BCCE190FC0 /* MyProject2 in Projects */,
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
		0428AEAFE473CF24256EC332 /* Products */ = {
			isa = PBXGroup;
			children = (
				E0BB4A5ECEA9F79291B44FDE /* libMyProject2-d.a */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				990A9E97AA7ABFD9D0C572FA /* Products */,
				EC3797AC2F8E8FF50A219880 /* Projects */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		EC3797AC2F8E8FF50A219880 /* Projects */ = {
			isa = PBXGroup;
			children = (
				026A2D9F664E1FB990F29FAF /* MyProject2.xcodeproj */,
			);
			name = Projects;
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
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				6CE3CBF45F92A436D14B9854 /* Resources */,
				0E6E09EDF485325B3B2F59FC /* Sources */,
				80C3A7BC2BDDF59FD06C145A /* Frameworks */,
				9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
				516749527AB8F602ACAC6ABD /* PBXTargetDependency */,
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 27CCF7ECD6074ECEF6698AFF /* MyProject */;
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
			mainGroup = 92D64CFF9D6F878B547A3D17 /* MyProject */;
			projectDirPath = "";
			projectReferences = (
				{
					ProductGroup = 0428AEAFE473CF24256EC332 /* Products */;
					ProjectRef = 026A2D9F664E1FB990F29FAF /* MyProject2.xcodeproj */;
				},
			);
			projectRoot = "";
			targets = (
				C12DD7380DD8DCCCA0B1C207 /* MyProject */,
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
		E0BB4A5ECEA9F79291B44FDE /* libMyProject2-d.a */ = {
			isa = PBXReferenceProxy;
			fileType = archive.ar;
			path = "libMyProject2-d.a";
			remoteRef = 09112916D122CACC9994A304 /* PBXContainerItemProxy */;
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
		516749527AB8F602ACAC6ABD /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			name = "libMyProject2-d.a";
			targetProxy = D976322FD9860EA24851484C /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */
		]]
	end

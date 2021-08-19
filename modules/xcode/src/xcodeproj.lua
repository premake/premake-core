---
-- Xcode project (.xcodeproj) exporter
---

local export = require('export')
local path = require('path')
local premake = require('premake')

local wl = export.writeLine

local xcodeproj = {}


---
-- Element lists describe the contents of each section of the workspace file
---

xcodeproj.elements = {
	root = function (wks)
		return {
			xcodeproj.header,
			xcodeproj.hardcoded,
			xcodeproj.footer
		}
	end,
}


function xcodeproj.export(prj)
	premake.export(prj, prj.exportPath, function ()
		export.eol('\n')
		export.indentString('\t')
		premake.callArray(xcodeproj.elements.root, wks)
	end)
end


function xcodeproj.filename(prj)
	return path.join(prj.location, prj.filename .. '.xcodeproj', 'project.pbxproj')
end


---
-- Handlers for structural elements, in the order in which they appear in the .vcxproj.
-- Handlers for individual setting elements are at the bottom of the file.
---

function xcodeproj.header()
	wl('// !$*UTF8*$!')
	wl('{')
	export.indent()
end


function xcodeproj.hardcoded()
	wl([[
archiveVersion = 1;
	classes = {
	};
	objectVersion = 50;
	objects = {

/* Begin PBXBuildFile section */
		494786F926C49D560069B031 /* main.m in Sources */ = {isa = PBXBuildFile; fileRef = 494786F826C49D560069B031 /* main.m */; };
/* End PBXBuildFile section */

/* Begin PBXCopyFilesBuildPhase section */
		494786F326C49D560069B031 /* CopyFiles */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = /usr/share/man/man1/;
			dstSubfolderSpec = 0;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 1;
		};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
		494786F526C49D560069B031 /* Premake */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = Premake; sourceTree = BUILT_PRODUCTS_DIR; };
		494786F826C49D560069B031 /* main.m */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = main.m; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		494786F226C49D560069B031 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		494786EC26C49D560069B031 = {
			isa = PBXGroup;
			children = (
				494786F726C49D560069B031 /* Premake */,
				494786F626C49D560069B031 /* Products */,
			);
			sourceTree = "<group>";
		};
		494786F626C49D560069B031 /* Products */ = {
			isa = PBXGroup;
			children = (
				494786F526C49D560069B031 /* Premake */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		494786F726C49D560069B031 /* Premake */ = {
			isa = PBXGroup;
			children = (
				494786F826C49D560069B031 /* main.m */,
			);
			path = Premake;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		494786F426C49D560069B031 /* Premake */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 494786FC26C49D560069B031 /* Build configuration list for PBXNativeTarget "Premake" */;
			buildPhases = (
				494786F126C49D560069B031 /* Sources */,
				494786F226C49D560069B031 /* Frameworks */,
				494786F326C49D560069B031 /* CopyFiles */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Premake;
			productName = Premake;
			productReference = 494786F526C49D560069B031 /* Premake */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		494786ED26C49D560069B031 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				LastUpgradeCheck = 1250;
				TargetAttributes = {
					494786F426C49D560069B031 = {
						CreatedOnToolsVersion = 12.5.1;
					};
				};
			};
			buildConfigurationList = 494786F026C49D560069B031 /* Build configuration list for PBXProject "Premake" */;
			compatibilityVersion = "Xcode 9.3";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 494786EC26C49D560069B031;
			productRefGroup = 494786F626C49D560069B031 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				494786F426C49D560069B031 /* Premake */,
			);
		};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		494786F126C49D560069B031 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				494786F926C49D560069B031 /* main.m in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		494786FA26C49D560069B031 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 11.3;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
			};
			name = Debug;
		};
		494786FB26C49D560069B031 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 11.3;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
			};
			name = Release;
		};
		494786FD26C49D560069B031 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = 6ZE8WYKX26;
				ENABLE_HARDENED_RUNTIME = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
			};
			name = Debug;
		};
		494786FE26C49D560069B031 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = 6ZE8WYKX26;
				ENABLE_HARDENED_RUNTIME = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		494786F026C49D560069B031 /* Build configuration list for PBXProject "Premake" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				494786FA26C49D560069B031 /* Debug */,
				494786FB26C49D560069B031 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		494786FC26C49D560069B031 /* Build configuration list for PBXNativeTarget "Premake" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				494786FD26C49D560069B031 /* Debug */,
				494786FE26C49D560069B031 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 494786ED26C49D560069B031 /* Project object */;]])
end


function xcodeproj.footer()
	export.outdent()
	wl('}')
end


return xcodeproj

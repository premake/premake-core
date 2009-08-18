--
-- xcode_pbxproj.lua
-- Generate an Xcode project, which incorporates the entire Premake structure.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode


--
-- Retrieve the Xcode file type for a given file, based on the file extension.
--
-- @returns
--    An Xcode file type, string.
--

	function xcode.getfiletype(fname)
		local x = path.getextension(fname)
		if x == ".c" then
			return "sourcecode.c.c"
		elseif x == ".css" then
			return "text.css"
		elseif x == ".gif" then
			return "image.gif"
		elseif x == ".h" then
			return "sourcecode.c.h"
		elseif x == ".html" then
			return "text.html"
		elseif x == ".lua" then
			return "sourcecode.lua"
		else
			return "text"
		end
	end


--
-- Create a unique 12 byte ID.
--
-- @returns
--    A 24-character string representing the 12 byte ID.
--

	function xcode.newid()
		return string.format("%04X%04X%04X%012d", math.random(0, 32767), math.random(0, 32767), math.random(0, 32767), os.time())
	end


--
-- Generate the project.pbxproj file.
--
-- @param sln
--    The target solution.
--

	function premake.xcode.pbxproj(sln)

		-- Xcode munges all the files from all of the projects together into one tree. 
		-- Convert the lists of file names from project relative to absolute, merge
		-- duplicates, and add some additional Xcode specific metadata.
		local files = { }
		local names = { }
		for prj in premake.eachproject(sln) do
			for i, fname in ipairs(prj.files) do
				-- convert from project-relative to absolute path to catch duplicates
				local fullpath = path.join(prj.location, fname)
				
				-- build metadata for file
				local file = names[fullpath]
				if not file then
					file = {
						path = fullpath,
						name = path.getname(fname),
						id = xcode.newid()
					}
					
					if path.iscppfile(fname) then
						file.buildid = xcode.newid()
					end
					
					-- add it to the list and lookup table
					table.insert(files, file)
					names[fullpath] = file
				end
				
				-- replace project's filename with the metadata object
				prj.files[i] = file
			end
		end
		
		-- Begin file generation --
		_p('// !$*UTF8*$!')
		_p('{')
		_p('	archiveVersion = 1;')
		_p('	classes = {')
		_p('	};')
		_p('	objectVersion = 45;')
		_p('	objects = {')
		_p('')
		
		_p('/* Begin PBXBuildFile section */')
		for _, file in ipairs(files) do
			if file.buildid then
				_p('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s /* %s */; };', 
					file.buildid, file.name, file.id, file.name)
			end
		end
		_p('/* End PBXBuildFile section */')
		_p('')


		-- BEGIN HARDCODED --
		_p('/* Begin PBXCopyFilesBuildPhase section */')
		_p('		8DD76FAF0486AB0100D96B5E /* CopyFiles */ = {')
		_p('			isa = PBXCopyFilesBuildPhase;')
		_p('			buildActionMask = 8;')
		_p('			dstPath = /usr/share/man/man1/;')
		_p('			dstSubfolderSpec = 0;')
		_p('			files = (')
		_p('			);')
		_p('			runOnlyForDeploymentPostprocessing = 1;')
		_p('		};')
		_p('/* End PBXCopyFilesBuildPhase section */')
		_p('')
		-- END HARDCODED --

		
		_p('/* Begin PBXFileReference section */')
		for _, file in ipairs(files) do
			_p('\t\t%s /* %s */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = %s; path = %s; sourceTree = "<group>"; };',
				file.id, file.name, xcode.getfiletype(file.name), file.name)
		end
		_p('		8DD76FB20486AB0100D96B5E /* CConsoleApp */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = CConsoleApp; path = /Users/jason/Temp/CConsoleApp/build/Debug/CConsoleApp; sourceTree = "<absolute>"; };')
		-- HARDCODED ^ --
		_p('/* End PBXFileReference section */')
		_p('')
				
		
		-- BEGIN HARDCODED --
		_p('/* Begin PBXFrameworksBuildPhase section */')
		_p('		8DD76FAD0486AB0100D96B5E /* Frameworks */ = {')
		_p('			isa = PBXFrameworksBuildPhase;')
		_p('			buildActionMask = 2147483647;')
		_p('			files = (')
		_p('			);')
		_p('			runOnlyForDeploymentPostprocessing = 0;')
		_p('		};')
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
		-- END HARDCODED --
		

		_p('/* Begin PBXGroup section */')
		for prj in premake.eachproject(sln) do
			_p('		08FB7794FE84155DC02AAC07 /* CConsoleApp */ = {')  -- < HARDCODED --
			_p('\t\t\tisa = PBXGroup;')
			_p('\t\t\tchildren = (')
			for _, file in ipairs(prj.files) do
				_p('\t\t\t\t%s /* %s */,', file.id, file.name)
			end
			_p('\t\t\t);')
			_p('			name = CConsoleApp;')  -- < HARDCODED --
			_p('\t\t\tsourceTree = "<group>";')
			_p('\t\t};')
		end
		_p('/* End PBXGroup section */')
		_p('')
		
				
		-- BEGIN HARDCODED --
		_p('/* Begin PBXNativeTarget section */')
		_p('		8DD76FA90486AB0100D96B5E /* CConsoleApp */ = {')
		_p('			isa = PBXNativeTarget;')
		_p('			buildConfigurationList = 1DEB928508733DD80010E9CD /* Build configuration list for PBXNativeTarget "CConsoleApp" */;')
		_p('			buildPhases = (')
		_p('				8DD76FAB0486AB0100D96B5E /* Sources */,')
		_p('				8DD76FAD0486AB0100D96B5E /* Frameworks */,')
		_p('				8DD76FAF0486AB0100D96B5E /* CopyFiles */,')
		_p('			);')
		_p('			buildRules = (')
		_p('			);')
		_p('			dependencies = (')
		_p('			);')
		_p('			name = CConsoleApp;')
		_p('			productInstallPath = "$(HOME)/bin";')
		_p('			productName = CConsoleApp;')
		_p('			productReference = 8DD76FB20486AB0100D96B5E /* CConsoleApp */;')
		_p('			productType = "com.apple.product-type.tool";')
		_p('		};')
		_p('/* End PBXNativeTarget section */')
		_p('')
		_p('/* Begin PBXProject section */')
		_p('		08FB7793FE84155DC02AAC07 /* Project object */ = {')
		_p('			isa = PBXProject;')
		_p('			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "CConsoleApp" */;')
		_p('			compatibilityVersion = "Xcode 3.1";')
		_p('			hasScannedForEncodings = 1;')
		_p('			mainGroup = 08FB7794FE84155DC02AAC07 /* CConsoleApp */;')
		_p('			projectDirPath = "";')
		_p('			projectRoot = "";')
		_p('			targets = (')
		_p('				8DD76FA90486AB0100D96B5E /* CConsoleApp */,')
		_p('			);')
		_p('		};')
		_p('/* End PBXProject section */')
		_p('')
		-- END HARDCODED --
		
		_p('/* Begin PBXSourcesBuildPhase section */')
		_p('\t\t8DD76FAB0486AB0100D96B5E /* Sources */ = {')
		_p('\t\t\tisa = PBXSourcesBuildPhase;')
		_p('\t\t\tbuildActionMask = 2147483647;')
		_p('\t\t\tfiles = (')
		for _, file in ipairs(files) do
			if file.buildid then
				_p('\t\t\t\t%s /* %s in Sources */,', file.buildid, file.name)
			end
		end
		_p('\t\t\t);')
		_p('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
		_p('\t\t};')
		_p('/* End PBXSourcesBuildPhase section */')
		_p('')

		
		-- BEGIN HARDCODED --
		_p('/* Begin XCBuildConfiguration section */')
		_p('		1DEB928608733DD80010E9CD /* Debug */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ALWAYS_SEARCH_USER_PATHS = NO;')
		_p('				COPY_PHASE_STRIP = NO;')
		_p('				GCC_DYNAMIC_NO_PIC = NO;')
		_p('				GCC_ENABLE_FIX_AND_CONTINUE = YES;')
		_p('				GCC_MODEL_TUNING = G5;')
		_p('				GCC_OPTIMIZATION_LEVEL = 0;')
		_p('				INSTALL_PATH = /usr/local/bin;')
		_p('				PRODUCT_NAME = CConsoleApp;')
		_p('			};')
		_p('			name = Debug;')
		_p('		};')
		_p('		1DEB928708733DD80010E9CD /* Release */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ALWAYS_SEARCH_USER_PATHS = NO;')
		_p('				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
		_p('				GCC_MODEL_TUNING = G5;')
		_p('				INSTALL_PATH = /usr/local/bin;')
		_p('				PRODUCT_NAME = CConsoleApp;')
		_p('			};')
		_p('			name = Release;')
		_p('		};')
		_p('		1DEB928A08733DD80010E9CD /* Debug */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p('				GCC_C_LANGUAGE_STANDARD = c99;')
		_p('				GCC_OPTIMIZATION_LEVEL = 0;')
		_p('				GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p('				GCC_WARN_UNUSED_VARIABLE = YES;')
		_p('				ONLY_ACTIVE_ARCH = YES;')
		_p('				PREBINDING = NO;')
		_p('				SDKROOT = macosx10.5;')
		_p('			};')
		_p('			name = Debug;')
		_p('		};')
		_p('		1DEB928B08733DD80010E9CD /* Release */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p('				GCC_C_LANGUAGE_STANDARD = c99;')
		_p('				GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p('				GCC_WARN_UNUSED_VARIABLE = YES;')
		_p('				PREBINDING = NO;')
		_p('				SDKROOT = macosx10.5;')
		_p('			};')
		_p('			name = Release;')
		_p('		};')
		_p('/* End XCBuildConfiguration section */')
		_p('')
		_p('/* Begin XCConfigurationList section */')
		_p('		1DEB928508733DD80010E9CD /* Build configuration list for PBXNativeTarget "CConsoleApp" */ = {')
		_p('			isa = XCConfigurationList;')
		_p('			buildConfigurations = (')
		_p('				1DEB928608733DD80010E9CD /* Debug */,')
		_p('				1DEB928708733DD80010E9CD /* Release */,')
		_p('			);')
		_p('			defaultConfigurationIsVisible = 0;')
		_p('			defaultConfigurationName = Release;')
		_p('		};')
		_p('		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "CConsoleApp" */ = {')
		_p('			isa = XCConfigurationList;')
		_p('			buildConfigurations = (')
		_p('				1DEB928A08733DD80010E9CD /* Debug */,')
		_p('				1DEB928B08733DD80010E9CD /* Release */,')
		_p('			);')
		_p('			defaultConfigurationIsVisible = 0;')
		_p('			defaultConfigurationName = Release;')
		_p('		};')
		_p('/* End XCConfigurationList section */')
		_p('	};')
		_p('	rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')

	end

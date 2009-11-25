--
-- xcode_common.lua
-- Functions to generate the different sections of an Xcode project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree  = premake.tree


--
-- Return the Xcode build category for a given file, based on the file extension.
--
-- @param node
--    The node to identify.
-- @returns
--    An Xcode build category, one of "Sources", "Resources", "Frameworks", or nil.
--

	function xcode.getbuildcategory(node)
		local categories = {
			[".a"] = "Frameworks",
			[".c"] = "Sources",
			[".cc"] = "Sources",
			[".cpp"] = "Sources",
			[".cxx"] = "Sources",
			[".framework"] = "Frameworks",
			[".m"] = "Sources",
			[".strings"] = "Resources",
			[".nib"] = "Resources",
			[".xib"] = "Resources",
		}
		return categories[path.getextension(node.name)]
	end

	
--
-- Return the Xcode type for a given file, based on the file extension.
--
-- @param fname
--    The file name to identify.
-- @returns
--    An Xcode file type, string.
--

	function xcode.getfiletype(node)
		local types = {
			[".c"]         = "sourcecode.c.c",
			[".cc"]        = "sourcecode.cpp.cpp",
			[".cpp"]       = "sourcecode.cpp.cpp",
			[".css"]       = "text.css",
			[".cxx"]       = "sourcecode.cpp.cpp",
			[".framework"] = "wrapper.framework",
			[".gif"]       = "image.gif",
			[".h"]         = "sourcecode.c.h",
			[".html"]      = "text.html",
			[".lua"]       = "sourcecode.lua",
			[".m"]         = "sourcecode.c.objc",
			[".nib"]       = "wrapper.nib",
			[".pch"]       = "sourcecode.c.h",
			[".plist"]     = "text.plist.xml",
			[".strings"]   = "text.plist.strings",
			[".xib"]       = "file.xib",
		}
		return types[path.getextension(node.path)] or "text"
	end


--
-- Return the Xcode product type, based target kind.
--
-- @param node
--    The product node to identify.
-- @returns
--    An Xcode product type, string.
--

	function xcode.getproducttype(node)
		local types = {
			ConsoleApp  = "com.apple.product-type.tool",
			WindowedApp = "com.apple.product-type.application",
			StaticLib   = "com.apple.product-type.library.static",
			SharedLib   = "com.apple.product-type.library.dynamic",
		}
		return types[node.cfg.kind]
	end


--
-- Return the Xcode target type, based on the target file extension.
--
-- @param node
--    The product node to identify.
-- @returns
--    An Xcode target type, string.
--

	function xcode.gettargettype(node)
		local types = {
			ConsoleApp  = "\"compiled.mach-o.executable\"",
			WindowedApp = "wrapper.application",
			StaticLib   = "archive.ar",
			SharedLib   = "\"compiled.mach-o.dylib\"",
		}
		return types[node.cfg.kind]
	end


--
-- Return a unique file name for a project. Since Xcode uses .xcodeproj's to 
-- represent both solutions and projects there is a likely change of a name
-- collision. Tack on a number to differentiate them.
--
-- @param prj
--    The project being queried.
-- @returns
--    A uniqued file name
--

	function xcode.getxcodeprojname(prj)
		-- if there is a solution with matching name, then use "projectname1.xcodeproj"
		-- just get something working for now
		local fname = premake.project.getfilename(prj, "%%.xcodeproj")
		return fname
	end


--
-- Returns true if the file name represents a framework.
--
-- @param fname
--    The name of the file to test.
--

	function xcode.isframework(fname)
		return (path.getextension(fname) == ".framework")
	end


--
-- Retrieves a unique 12 byte ID for an object. This function accepts and ignores two
-- parameters 'node' and 'usage', which are used by an alternative implementation of
-- this function for testing.
--
-- @returns
--    A 24-character string representing the 12 byte ID.
--

	function xcode.newid()
		return string.format("%04X%04X%04X%012d", math.random(0, 32767), math.random(0, 32767), math.random(0, 32767), os.time())
	end


--
-- Assign required Xcode specific information to each project, which is used
-- to connect dependent projects together, and to build the solution.
--
-- @param sln
--    The solution to prepare.
-- @returns
--    Nothing; information is added to the project objects.
--

	function xcode.preparesolution(sln)
		for prj in premake.solution.eachproject(sln) do
			-- create a tree node to represent the pro
			-- prj.xcode = tree.new
			-- prj.xcode.productid = xcode.newid(
		end
	end


---------------------------------------------------------------------------
-- Section generator functions, in the same order in which they appear
-- in the .pbxproj file
---------------------------------------------------------------------------

	function xcode.Header()
		_p('// !$*UTF8*$!')
		_p('{')
		_p(1,'archiveVersion = 1;')
		_p(1,'classes = {')
		_p(1,'};')
		_p(1,'objectVersion = 45;')
		_p(1,'objects = {')
		_p('')
	end


	function xcode.PBXBuildFile(tr)
		_p('/* Begin PBXBuildFile section */')
		tree.traverse(tr, {
			onnode = function(node)
				if node.buildid then
					_p(2,'%s /* %s in %s */ = {isa = PBXBuildFile; fileRef = %s /* %s */; };', 
						node.buildid, node.name, xcode.getbuildcategory(node), node.id, node.name)
				end
			end
		})
		_p('/* End PBXBuildFile section */')
		_p('')
	end


	function xcode.PBXContainerItemProxy(tr)
		_p('/* Begin PBXContainerItemProxy section */')
		for _, node in ipairs(tr.projects.children) do
			_p(2,'%s /* PBXContainerItemProxy */ = {', node.remoteid)
			_p(3,'isa = PBXContainerItemProxy;')
			_p(3,'containerPortal = %s /* %s */;', node.id, path.getname(node.path))
			_p(3,'proxyType = 2;')
			_p(3,'remoteGlobalIDString = 7DF44AF45AB7001258659540;')
		end
		_p('/* End PBXContainerItemProxy section */')
		
--[[
			remoteGlobalIDString = 7DF44AF45AB7001258659540;
			remoteInfo = "libMyLibrary-d.a";
		};
		967BE4EA10B5D6F200E9EC24 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 967BE4E010B5D6C900E9EC24 /* MyLibrary.xcodeproj */;
			proxyType = 1;
			remoteGlobalIDString = 4EE55BCC4CE5001258659540;
			remoteInfo = "libMyLibrary-d.a";
		};
]]
	end


	function xcode.PBXFileReference(tr)
		_p('/* Begin PBXFileReference section */')
		
		tree.traverse(tr, {
			onleaf = function(node)
				-- I'm only listing files here, so ignore anything without a path
				if not node.path then
					return
				end
				
				if node.kind == "product" then
					_p(2,'%s /* %s */ = {isa = PBXFileReference; explicitFileType = %s; includeInIndex = 0; name = "%s"; path = "%s"; sourceTree = BUILT_PRODUCTS_DIR; };',
						node.id, node.name, xcode.gettargettype(node), node.name, path.getname(node.cfg.buildtarget.bundlepath))
				else
					local pth, src
					if xcode.isframework(node.path) then
						-- I need to figure out how to locate frameworks; this is just to get something working
						pth = "/System/Library/Frameworks/" .. node.path
						src = "absolute"
					else
						-- something else; probably a source code file
						pth = tree.getlocalpath(node)
						src = "group"
					end
					
					_p(2,'%s /* %s */ = {isa = PBXFileReference; lastKnownFileType = %s; name = "%s"; path = "%s"; sourceTree = "<%s>"; };',
						node.id, node.name, xcode.getfiletype(node), node.name, pth, src)
				end
			end
		})
		
		_p('/* End PBXFileReference section */')
		_p('')
	end


	function xcode.PBXFrameworksBuildPhase(tr)
		_p('/* Begin PBXFrameworksBuildPhase section */')
		for _, node in ipairs(tr.products.children) do
			_p(2,'%s /* Frameworks */ = {', node.fxstageid)
			_p(3,'isa = PBXFrameworksBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			for _, link in ipairs(node.cfg.links) do
				local fxnode = tr.frameworks.children[path.getname(link)]
				_p(4,'%s /* %s in Frameworks */,', fxnode.buildid, fxnode.name)
			end
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
	end


	function xcode.PBXGroup(tr)
		_p('/* Begin PBXGroup section */')

		tree.traverse(tr, {
			onnode = function(node)
				-- Skip over anything that isn't a proper group
				if (node.path and #node.children == 0) or node.kind == "vgroup" then
					return
				end
				
				_p(2,'%s /* %s */ = {', node.id, node.name)
				_p(3,'isa = PBXGroup;')
				_p(3,'children = (')
				for _, childnode in ipairs(node.children) do
					_p(4,'%s /* %s */,', childnode.id, childnode.name)
				end
				_p(3,');')
				_p(3,'name = %s;', node.name)
				
				if node.path then
					local p = node.path
					if node.parent.path then
						p = path.getrelative(node.parent.path, node.path)
					end
					_p(3,'path = %s;', p)
				end
				
				_p(3,'sourceTree = "<group>";')
				_p(2,'};')
			end
			
		}, true)
				
		_p('/* End PBXGroup section */')
		_p('')
	end	


	function xcode.PBXNativeTarget(tr)
		_p('/* Begin PBXNativeTarget section */')
		for _, node in ipairs(tr.products.children) do
			-- trim ".app" from WindowedApps
			local name = iif(node.cfg.kind == "WindowedApp", string.sub(node.name, 1, -5), node.name)
			
			_p(2,'%s /* %s */ = {', node.targetid, name)
			_p(3,'isa = PBXNativeTarget;')
			_p(3,'buildConfigurationList = %s /* Build configuration list for PBXNativeTarget "%s" */;', node.cfgsection, name)
			_p(3,'buildPhases = (')
			_p(4,'%s /* Resources */,', node.resstageid)
			_p(4,'%s /* Sources */,', node.sourcesid)
			_p(4,'%s /* Frameworks */,', node.fxstageid)
			_p(3,');')
			_p(3,'buildRules = (')
			_p(3,');')
			_p(3,'dependencies = (')
			_p(3,');')
			_p(3,'name = %s;', name)
			
			local p
			if node.cfg.kind == "ConsoleApp" then
				p = "$(HOME)/bin"
			elseif node.cfg.kind == "WindowedApp" then
				p = "$(HOME)/Applications"
			end
			if p then
				_p(3,'productInstallPath = "%s";', p)
			end
			
			_p(3,'productName = %s;', name)
			_p(3,'productReference = %s /* %s */;', node.id, node.name)
			_p(3,'productType = "%s";', xcode.getproducttype(node))
			_p(2,'};')
		end
		_p('/* End PBXNativeTarget section */')
		_p('')
	end


	function xcode.PBXProject(tr)
		_p('/* Begin PBXProject section */')
		_p(2,'08FB7793FE84155DC02AAC07 /* Project object */ = {')
		_p(3,'isa = PBXProject;')
		_p(3,'buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */;', tr.name)
		_p(3,'compatibilityVersion = "Xcode 3.1";')
		_p(3,'hasScannedForEncodings = 1;')
		_p(3,'mainGroup = %s /* %s */;', tr.id, tr.name)
		_p(3,'projectDirPath = "";')
		_p(3,'projectRoot = "";')
		_p(3,'targets = (')
		for _, node in ipairs(tr.products.children) do
			_p(4,'%s /* %s */,', node.targetid, node.name)
		end
		_p(3,');')
		_p(2,'};')
		_p('/* End PBXProject section */')
		_p('')
	end


	function xcode.PBXResourcesBuildPhase(tr)
		_p('/* Begin PBXResourcesBuildPhase section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Resources */ = {', target.resstageid)
			_p(3,'isa = PBXResourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			tree.traverse(tr, {
				onnode = function(node)
					if xcode.getbuildcategory(node) == "Resources" then
						_p(4,'%s /* %s in Resources */,', node.buildid, node.name)
					end
				end
			})
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXResourcesBuildPhase section */')
		_p('')
	end


	function xcode.PBXSourcesBuildPhase(tr)
		_p('/* Begin PBXSourcesBuildPhase section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Sources */ = {', target.sourcesid)
			_p(3,'isa = PBXSourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			tree.traverse(tr, {
				onleaf = function(node)
					if xcode.getbuildcategory(node) == "Sources" then
						_p(4,'%s /* %s in Sources */,', node.buildid, node.name)
					end
				end
			})
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXSourcesBuildPhase section */')
		_p('')
	end


	function xcode.PBXVariantGroup(tr)
		_p('/* Begin PBXVariantGroup section */')
		tree.traverse(tr, {
			onbranch = function(node)
				if node.kind == "vgroup" then
					_p(2,'%s /* %s */ = {', node.id, node.name)
					_p(3,'isa = PBXVariantGroup;')
					_p(3,'children = (')
					for _, lang in ipairs(node.children) do
						_p(4,'%s /* %s */,', lang.id, lang.name)
					end
					_p(3,');')
					_p(3,'name = %s;', node.name)
					_p(3,'sourceTree = "<group>";')
					_p(2,'};')
				end
			end
		})
		_p('/* End PBXVariantGroup section */')
		_p('')
	end


	function xcode.XCBuildConfiguration_Target(tr, target, cfg)
		_p(2,'%s /* %s */ = {', target.configids[cfg.name], cfg.name)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ALWAYS_SEARCH_USER_PATHS = NO;')

		if not cfg.flags.Symbols then
			_p(4,'DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
		end
		
		local outdir = path.getdirectory(cfg.buildtarget.bundlepath)
		if outdir ~= "." then
			_p(4,'CONFIGURATION_BUILD_DIR = %s;', outdir)
		end

		if cfg.flags.Symbols then
			_p(4,'COPY_PHASE_STRIP = NO;')
		end

		_p(4,'GCC_DYNAMIC_NO_PIC = NO;')

		if cfg.flags.Symbols then
			_p(4,'GCC_ENABLE_FIX_AND_CONTINUE = YES;')
		end

		_p(4,'GCC_MODEL_TUNING = G5;')

		if #cfg.defines > 0 then
			_p(4,'GCC_PREPROCESSOR_DEFINITIONS = (')
			_p(table.implode(cfg.defines, "\t\t\t\t", ",\n"))
			_p(4,');')
		end

		if tr.infoplist then
			_p(4,'INFOPLIST_FILE = "%s";', tr.infoplist.path)
		end

		_p(4,'PRODUCT_NAME = "%s";', cfg.buildtarget.basename .. cfg.buildtarget.suffix)

		local p
		if cfg.kind == "ConsoleApp" then
			p = '/usr/local/bin'
		elseif cfg.kind == "WindowedApp" then
			p = '"$(HOME)/Applications"'
		end
		if p then
			_p(4,'INSTALL_PATH = %s;', p)
		end
		
		_p(3,'};')
		_p(3,'name = %s;', cfg.name)
		_p(2,'};')
	end
	
	
	function xcode.XCBuildConfiguration_Project(tr, cfg)
		_p(2,'%s /* %s */ = {', tr.configids[cfg.name], cfg.name)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";')
		
		local targetdir = path.getdirectory(cfg.buildtarget.bundlepath)
		if targetdir ~= "." then
			_p(4,'CONFIGURATION_BUILD_DIR = "$(SYMROOT)";');
		end
		
		_p(4,'CONFIGURATION_TEMP_DIR = "$(OBJROOT)";')
		_p(4,'GCC_C_LANGUAGE_STANDARD = gnu99;')
		
		if cfg.flags.Optimize or cfg.flags.OptimizeSize then
			_p(4,'GCC_OPTIMIZATION_LEVEL = s;')
		elseif cfg.flags.OptimizeSpeed then
			_p(4,'GCC_OPTIMIZATION_LEVEL = 3;')
		else
			_p(4,'GCC_OPTIMIZATION_LEVEL = 0;')
		end
		
		_p(4,'GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p(4,'GCC_WARN_UNUSED_VARIABLE = YES;')
		_p(4,'OBJROOT = "%s";', cfg.objectsdir)
		_p(4,'ONLY_ACTIVE_ARCH = YES;')
		_p(4,'PREBINDING = NO;')
		
		if targetdir ~= "." then
			_p(4,'SYMROOT = "%s";', targetdir)
		end
		
		_p(3,'};')
		_p(3,'name = %s;', cfg.name)
		_p(2,'};')
	end


	function xcode.XCBuildConfiguration(tr)
		_p('/* Begin XCBuildConfiguration section */')
		for _, target in ipairs(tr.products.children) do
			for cfg in premake.eachconfig(tr.project) do
				xcode.XCBuildConfiguration_Target(tr, target, cfg)
			end
		end
		for cfg in premake.eachconfig(tr.project) do
			xcode.XCBuildConfiguration_Project(tr, cfg)
		end
		_p('/* End XCBuildConfiguration section */')
		_p('')
	end


	function xcode.XCBuildConfigurationList(tr)
		local sln = tr.project.solution
		
		_p('/* Begin XCConfigurationList section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Build configuration list for PBXNativeTarget "%s" */ = {', target.cfgsection, target.name)
			_p(3,'isa = XCConfigurationList;')
			_p(3,'buildConfigurations = (')
			for _, cfgname in ipairs(sln.configurations) do
				_p(4,'%s /* %s */,', target.configids[cfgname], cfgname)
			end
			_p(3,');')
			_p(3,'defaultConfigurationIsVisible = 0;')
			_p(3,'defaultConfigurationName = %s;', sln.configurations[1])
			_p(2,'};')
		end
		_p(2,'1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */ = {', tr.name)
		_p(3,'isa = XCConfigurationList;')
		_p(3,'buildConfigurations = (')
		for _, cfgname in ipairs(sln.configurations) do
			_p(4,'%s /* %s */,', tr.configids[cfgname], cfgname)
		end
		_p(3,');')
		_p(3,'defaultConfigurationIsVisible = 0;')
		_p(3,'defaultConfigurationName = %s;', sln.configurations[1])
		_p(2,'};')
		_p('/* End XCConfigurationList section */')
		_p('')
	end


	function xcode.Footer()
		_p(1,'};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
	end

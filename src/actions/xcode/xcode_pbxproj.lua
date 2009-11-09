--
-- xcode_pbxproj.lua
-- Generate an Xcode project, which incorporates the entire Premake structure.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree  = premake.tree


--
-- Create a solution tree corresponding to what is shown in the Xcode project 
-- browser pane, with nodes for files and folders, resources, frameworks, and
-- products.
--
-- @param sln
--    The solution being generated.
-- @returns
--    A tree, loaded with metadata, which mirrors Xcode's view of the solution.
--

	function xcode.buildtree(sln)
		local node
		
		-- create a solution level node and add each project to it; remember which
		-- node goes with which project for later reference
		local tr = tree.new(sln.name)
		local prjnodes = {}
		for prj in premake.solution.eachproject(sln) do
			prjnodes[prj] = tree.insert(tr, premake.project.buildsourcetree(prj))
		end

		-- if there is only one project, use that as the tree root instead of the
		-- solution. This avoids an otherwise empty level in the tree
		if #tr.children == 1 then
			tr = tr.children[1]
			tr.parent = nil
		end
		tr.solution = sln

		-- convert localized resources from their filesystem layout (English.lproj/MainMenu.xib)
		-- to Xcode's display layout (MainMenu.xib/English).
		tree.traverse(tr, {
			onbranch = function(node)
				if path.getextension(node.name) == ".lproj" then
					local lang = path.getbasename(node.name)  -- "English", "French", etc.
					
					-- create a new language group for each file it contains
					for _, filenode in ipairs(node.children) do
						local grpnode = node.parent.children[filenode.name]
						if not grpnode then
							grpnode = tree.insert(node.parent, tree.new(filenode.name))
							grpnode.kind = "vgroup"
						end
						
						-- convert the file node to a language node and add to the group
						filenode.name = path.getbasename(lang)
						tree.insert(grpnode, filenode)
					end
					
					-- remove this directory from the tree
					tree.remove(node)
				end
			end
		})
		
		-- the special folder "Frameworks" lists all of the frameworks used in the solution.
		-- Only add it to the tree if there are frameworks in use.
		tr.frameworks = tree.new("Frameworks")
		frameworks = { }  -- remember which frameworks have already been added
		for prj in premake.solution.eachproject(sln) do
			for cfg in premake.eachconfig(prj) do
				for _, link in ipairs(cfg.links) do
					local name = path.getname(link)
					if xcode.isframework(name) and not frameworks[name] then
						frameworks[name] = name
						node = tree.insert(tr.frameworks, tree.new(name))
						node.path = link
					end
				end
			end
		end
		
		if #tr.frameworks.children > 0 then 
			tree.insert(tr, tr.frameworks)
		end
		
		-- the special folder "Products" lists all of the generated targets, one target
		-- for each target kind (ConsoleApp, SharedLibrary, etc.) produced by a project.
		tr.products = tree.insert(tr, tree.new("Products"))
		for prj in premake.solution.eachproject(sln) do
			local kinds = {}  -- remember which kinds have already been added
			for cfg in premake.eachconfig(prj) do
				if not kinds[cfg.kind] then
					kinds[cfg.kind] = true
					node = tree.insert(tr.products, tree.new(path.getname(cfg.buildtarget.bundlepath)))
					node.kind = "product"
					node.prjnode = prjnodes[prj]
					node.cfg  = cfg
					node.path = cfg.buildtarget.fullpath
					node.targetid   = xcode.newid(node, "target")
					node.cfgsection = xcode.newid(node, "cfg")
					node.resstageid = xcode.newid(node, "rez")
					node.sourcesid  = xcode.newid(node, "src")
					node.fxstageid  = xcode.newid(node, "fxs")
					
					-- assign IDs for each configuration
					node.configids = {}
					for _, cfgname in ipairs(sln.configurations) do
						node.configids[cfgname] = xcode.newid(node, cfgname)
					end
				end
			end
		end
		
		-- also assign solution-level configuration IDs
		tr.configids = {}
		for _, cfgname in ipairs(sln.configurations) do
			tr.configids[cfgname] = xcode.newid(node, cfgname)
		end
		
		-- Final setup
		local prjnode
		tree.traverse(tr, {
			onnode = function(node)
				if node.project then
					prjnode = node
				end
				
				-- assign IDs to every node in the tree
				node.id = xcode.newid(node)
				
				-- assign build IDs to buildable files
				if xcode.getbuildcategory(node) then
					node.buildid = xcode.newid(node, "build")
				end
											
				-- Premake is setup for the idea of a solution file referencing multiple project files,
				-- but Xcode uses a single file for everything. Convert the file paths from project
				-- location relative to solution (the one Xcode file) location relative to compensate.
				if node.path then
					node.path = xcode.rebase(prjnode.project, node.path)
				end
				
				-- remember key files that are needed elsewhere
				if node.name == "Info.plist" then
					prjnode.infoplist = node
				end						
			end
		}, true)
		
		return tr
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
-- Converts a path or list of paths from project-relative to solution-relative.
--
-- @param prj
--    The project containing the path.
-- @param p
--    A path or list of paths.
-- @returns
--    The rebased path or paths.
--

	function xcode.rebase(prj, p)
		if type(p) == "string" then
			return path.getrelative(prj.solution.location, path.join(prj.location, p))
		else
			local result = { }
			for i, v in ipairs(p) do
				result[i] = xcode.rebase(p[i])
			end
			return result
		end
	end



---------------------------------------------------------------------------
-- Section generator functions, in the same order in which they appear
-- in the .pbxproj file
---------------------------------------------------------------------------



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


	function xcode.XCBuildConfigurationBlock(target, cfg)
		local prj = target.prjnode.project
		
		_p(2,'%s /* %s */ = {', target.configids[cfg.name], cfg.name)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ALWAYS_SEARCH_USER_PATHS = NO;')

		_p(4,'CONFIGURATION_BUILD_DIR = %s;', xcode.rebase(prj, path.getdirectory(cfg.buildtarget.bundlepath)))

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

		if target.prjnode.infoplist then
			_p(4,'INFOPLIST_FILE = %s;', target.prjnode.infoplist.path)
		end

		_p(4,'PRODUCT_NAME = %s;', cfg.buildtarget.basename)

		_p(4,'SYMROOT = %s;', xcode.rebase(prj, cfg.objectsdir))
		_p(3,'};')
		_p(3,'name = %s;', cfg.name)
		_p(2,'};')
	end
	
	
	function xcode.XCBuildConfigurationDefault(tr, cfgname)
		_p(2,'%s /* %s */ = {', tr.configids[cfgname], cfgname)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p(4,'GCC_C_LANGUAGE_STANDARD = c99;')
		_p(4,'GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p(4,'GCC_WARN_UNUSED_VARIABLE = YES;')
		_p(4,'ONLY_ACTIVE_ARCH = YES;')
		_p(4,'PREBINDING = NO;')
		_p(4,'SDKROOT = macosx10.5;')
		-- I don't have any concept of a solution-level objdir; use the first target cfg
		local target = tr.products.children[1]
		local prj = target.prjnode.project
		local cfg = premake.getconfig(prj, cfgname)
		_p(4,'SYMROOT = %s;', xcode.rebase(prj, cfg.objectsdir))
		_p(3,'};')
		_p(3,'name = %s;', cfgname)
		_p(2,'};')
	end


	function xcode.XCBuildConfiguration(tr)
		_p('/* Begin XCBuildConfiguration section */')
		for _, target in ipairs(tr.products.children) do
			for cfg in premake.eachconfig(target.prjnode.project) do
				xcode.XCBuildConfigurationBlock(target, cfg)
			end
		end
		for _, cfgname in ipairs(tr.solution.configurations) do
			xcode.XCBuildConfigurationDefault(tr, cfgname)
		end
		_p('/* End XCBuildConfiguration section */')
		_p('')
	end


	function xcode.XCBuildConfigurationList(tr)
		_p('/* Begin XCConfigurationList section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Build configuration list for PBXNativeTarget "%s" */ = {', target.cfgsection, target.name)
			_p(3,'isa = XCConfigurationList;')
			_p(3,'buildConfigurations = (')
			for _, cfgname in ipairs(tr.solution.configurations) do
				_p(4,'%s /* %s */,', target.configids[cfgname], cfgname)
			end
			_p(3,');')
			_p(3,'defaultConfigurationIsVisible = 0;')
			_p(3,'defaultConfigurationName = %s;', tr.solution.configurations[1])
			_p(2,'};')
		end
		_p(2,'1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */ = {', tr.name)
		_p(3,'isa = XCConfigurationList;')
		_p(3,'buildConfigurations = (')
		for _, cfgname in ipairs(tr.solution.configurations) do
			_p(4,'%s /* %s */,', tr.configids[cfgname], cfgname)
		end
		_p(3,');')
		_p(3,'defaultConfigurationIsVisible = 0;')
		_p(3,'defaultConfigurationName = %s;', tr.solution.configurations[1])
		_p(2,'};')
		_p('/* End XCConfigurationList section */')
		_p('')
	end



---------------------------------------------------------------------------
-- Xcode project generator function
---------------------------------------------------------------------------

	function premake.xcode.pbxproj(sln)
		tr = xcode.buildtree(sln)
		xcode.Header(tr)  -- done
		xcode.PBXBuildFile(tr)  -- done
		xcode.PBXFileReference(tr) -- done
		xcode.PBXFrameworksBuildPhase(tr) -- done
		xcode.PBXGroup(tr) -- done
		xcode.PBXNativeTarget(tr) -- done
		xcode.PBXProject(tr) -- done
		xcode.PBXResourcesBuildPhase(tr)
		xcode.PBXSourcesBuildPhase(tr)
		xcode.PBXVariantGroup(tr)
		xcode.XCBuildConfiguration(tr)
		xcode.XCBuildConfigurationList(tr)
		xcode.Footer(tr)  -- done
	end

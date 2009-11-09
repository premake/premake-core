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


---------------------------------------------------------------------------
-- Section generator functions, in the same order in which they appear
-- in the .pbxproj file
---------------------------------------------------------------------------

	function xcode.Header()
		_p('// !$*UTF8*$!')
		_p('{')
		_p('\tarchiveVersion = 1;')
		_p('\tclasses = {')
		_p('\t};')
		_p('\tobjectVersion = 45;')
		_p('\tobjects = {')
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


	function xcode.PBXFileReference(tr)
		_p('/* Begin PBXFileReference section */')
		
		tree.traverse(tr, {
			onleaf = function(node)
				-- I'm only listing files here, so ignore anything without a path
				if not node.path then
					return
				end
				
				if node.kind == "product" then
					local targpath = path.getrelative(tr.project.location, node.cfg.buildtarget.bundlepath)
					_p(2,'%s /* %s */ = {isa = PBXFileReference; explicitFileType = %s; includeInIndex = 0; name = "%s"; path = "%s"; sourceTree = BUILT_PRODUCTS_DIR; };',
						node.id, node.name, xcode.gettargettype(node), node.name, targpath)
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
					_p(3,'path = %s;', node.path)
				end
				_p(3,'sourceTree = "<group>";')
				_p(2,'};')
			end
			
		}, true)
				
		_p('/* End PBXGroup section */')
		_p('')
	end	


	function xcode.Footer()
		_p(1,'};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
	end

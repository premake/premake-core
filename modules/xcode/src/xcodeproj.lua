---
-- Xcode project (.xcodeproj) exporter
---

local array = require('array')
local Buffer = require('buffer')
local export = require('export')
local path = require('path')
local premake = require('premake')
local tree = require('tree')

local xcode = select(1, ...)

local indent = export.indent
local outdent = export.outdent
local al = export.appendLine
local wl = export.writeLine

local xcodeproj = {}

local AUDIO_WAV = 'audio.wav'
local FILE_STORYBOARD = 'file.storyboard'
local FILE_XIB = 'file.xib'
local FOLDER_ASSETCATALOG = 'folder.assetcatalog'
local GROUP = '"<group>"'
local IMAGE_BMP = 'image.bmp'
local IMAGE_GIF = 'image.gif'
local IMAGE_ICNS = 'image.icns'
local IMAGE_PNG = 'image.png'
local SOURCECODE_ASM = 'sourcecode.asm'
local SOURCECODE_C_C = 'sourcecode.c.c'
local SOURCECODE_C_H = 'sourcecode.c.h'
local SOURCECODE_C_OBJC = 'sourcecode.c.objc'
local SOURCECODE_CPP_CPP = 'sourcecode.cpp.cpp'
local SOURCECODE_CPP_H = 'sourcecode.cpp.h'
local SOURCECODE_LUA = 'sourcecode.lua'
local SOURCECODE_METAL = 'sourcecode.metal'
local SOURCECODE_SWIFT = 'sourcecode.swift'
local TEXT = 'text'
local TEXT_CSS = 'text.css'
local TEXT_HTML = 'text.html'
local TEXT_PLIST_STRINGS = 'text.plist.strings'
local TEXT_PLIST_XML = 'text.plist.xml'
local WRAPPER_NIB = 'wrapper.nib'


---
-- Element lists describe the contents of each section of the workspace file
---

xcodeproj.elements = {
	root = function (prj)
		return {
			xcodeproj.archiveVersion,
			xcodeproj.classes,
			xcodeproj.objectVersion,
			xcodeproj.objects,
			xcodeproj.rootObject,
		}
	end,

	objects = function (prj)
		return {
			xcodeproj.pbxBuildFileSection,
			xcodeproj.pbxCopyFilesBuildPhaseSection,
			xcodeproj.pbxFileReferenceSection,
			xcodeproj.pbxFrameworksBuildPhaseSection,
			xcodeproj.pbxGroupSection,
			xcodeproj.pbxNativeTargetSection,
			xcodeproj.pbxProjectSection,
			xcodeproj.pbxSourcesBuildPhaseSection,
			xcodeproj.pbxVariantGroupSection,
			xcodeproj.xcBuildConfigurationSection,
			xcodeproj.xcConfigurationListSection
		}
	end,

	pbxFileReferenceSection = function (prj)
		return {
			xcodeproj.pbxProductFileReference,
			xcodeproj.pbxSourceFileReferences
		}
	end,

	pbxGroupSection = function (prj)
		return {
			xcodeproj.pbxFileGroups,
			xcodeproj.pbxProductsGroup
		}
	end,

	xcBuildConfigurationSection = function(prj)
		return {
			xcodeproj.xcProjectBuildConfiguration,
			xcodeproj.xcTargetBuildConfiguration
		}
	end,

	xcBuildConfiguration = function (cfg)
		return {
			xcodeproj.ALWAYS_SEARCH_USER_PATHS,
			xcodeproj.CLANG_ANALYZER_NONNULL,
			xcodeproj.CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION,
			xcodeproj.CLANG_CXX_LANGUAGE_STANDARD,
			xcodeproj.CLANG_CXX_LIBRARY,
			xcodeproj.CLANG_ENABLE_MODULES,
			xcodeproj.CLANG_ENABLE_OBJC_ARC,
			xcodeproj.CLANG_ENABLE_OBJC_WEAK,
			xcodeproj.CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING,
			xcodeproj.CLANG_WARN_BOOL_CONVERSION,
			xcodeproj.CLANG_WARN_COMMA,
			xcodeproj.CLANG_WARN_CONSTANT_CONVERSION,
			xcodeproj.CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS,
			xcodeproj.CLANG_WARN_DIRECT_OBJC_ISA_USAGE,
			xcodeproj.CLANG_WARN_DOCUMENTATION_COMMENTS,
			xcodeproj.CLANG_WARN_EMPTY_BODY,
			xcodeproj.CLANG_WARN_ENUM_CONVERSION,
			xcodeproj.CLANG_WARN_INFINITE_RECURSION,
			xcodeproj.CLANG_WARN_INT_CONVERSION,
			xcodeproj.CLANG_WARN_NON_LITERAL_NULL_CONVERSION,
			xcodeproj.CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF,
			xcodeproj.CLANG_WARN_OBJC_LITERAL_CONVERSION,
			xcodeproj.CLANG_WARN_OBJC_ROOT_CLASS,
			xcodeproj.CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER,
			xcodeproj.CLANG_WARN_RANGE_LOOP_ANALYSIS,
			xcodeproj.CLANG_WARN_STRICT_PROTOTYPES,
			xcodeproj.CLANG_WARN_SUSPICIOUS_MOVE,
			xcodeproj.CLANG_WARN_UNGUARDED_AVAILABILITY,
			xcodeproj.CLANG_WARN_UNREACHABLE_CODE,
			xcodeproj.CLANG_WARN__DUPLICATE_METHOD_MATCH,
			xcodeproj.COPY_PHASE_STRIP,
			xcodeproj.DEBUG_INFORMATION_FORMAT,
			xcodeproj.ENABLE_NS_ASSERTIONS,
			xcodeproj.ENABLE_STRICT_OBJC_MSGSEND,
			xcodeproj.ENABLE_TESTABILITY,
			xcodeproj.GCC_C_LANGUAGE_STANDARD,
			xcodeproj.GCC_DYNAMIC_NO_PIC,
			xcodeproj.GCC_NO_COMMON_BLOCKS,
			xcodeproj.GCC_OPTIMIZATION_LEVEL,
			xcodeproj.GCC_PREPROCESSOR_DEFINITIONS,
			xcodeproj.GCC_WARN_64_TO_32_BIT_CONVERSION,
			xcodeproj.GCC_WARN_ABOUT_RETURN_TYPE,
			xcodeproj.GCC_WARN_UNDECLARED_SELECTOR,
			xcodeproj.GCC_WARN_UNINITIALIZED_AUTOS,
			xcodeproj.GCC_WARN_UNUSED_FUNCTION,
			xcodeproj.GCC_WARN_UNUSED_VARIABLE,
			xcodeproj.MACOSX_DEPLOYMENT_TARGET,
			xcodeproj.MTL_ENABLE_DEBUG_INFO,
			xcodeproj.MTL_FAST_MATH,
			xcodeproj.ONLY_ACTIVE_ARCH,
			xcodeproj.SDKROOT,
			xcodeproj.USER_HEADER_SEARCH_PATHS
		}
	end,

	xcTargetBuildConfiguration = function (cfg)
		return {
			xcodeproj.CODE_SIGN_STYLE,
			xcodeproj.DEVELOPMENT_TEAM,
			xcodeproj.ENABLE_HARDENED_RUNTIME,
			xcodeproj.PRODUCT_NAME
		}
	end,

	xcConfigurationListSection = function (prj)
		return {
			xcodeproj.xcProjectConfigurationList,
			xcodeproj.xcTargetConfigurationList
		}
	end
}


---
-- Source file categorizations control how each type of source object is generated.
-- Categories are evaluated in the order in which they appear in the list.
---

xcodeproj.categories = {
	{
		extensions = premake.ASM_SOURCE_EXTENSIONS,
		fileType = SOURCECODE_ASM,
		isSource = true
	},
	{
		extensions = '.bmp',
		fileType = IMAGE_BMP
	},
	{
		extensions = premake.C_SOURCE_EXTENSIONS,
		fileType = SOURCECODE_C_C,
		isSource = true
	},
	{
		extensions = '.css',
		fileType = TEXT_CSS
	},
	{
		extensions = premake.CXX_HEADER_EXTENSIONS,
		fileType = SOURCECODE_CPP_H
	},
	{
		extensions = premake.CXX_SOURCE_EXTENSIONS,
		fileType = SOURCECODE_CPP_CPP,
		isSource = true
	},
	{
		extensions = '.gif',
		fileType = IMAGE_GIF
	},
	{
		extensions = '.html',
		fileType = TEXT_HTML
	},
	{
		extensions = '.icns',
		fileType = IMAGE_ICNS
	},
	{
		extensions = '.lua',
		fileType = SOURCECODE_LUA
	},
	{
		extensions = '.metal',
		fileType = SOURCECODE_METAL,
		isSource = true
	},
	{
		extensions = '.nib',
		fileType = WRAPPER_NIB
	},
	{
		extensions = premake.OBJC_SOURCE_EXTENSIONS,
		fileType = SOURCECODE_C_OBJC,
		isSource = true
	},
	{
		extensions = array.join(premake.C_HEADER_EXTENSIONS, '.pch'),
		fileType = SOURCECODE_C_H
	},
	{
		extensions = '.plist',
		fileType = TEXT_PLIST_XML
	},
	{
		extensions = '.png',
		fileType = IMAGE_PNG
	},
	{
		extensions = '.storyboard',
		fileType = FILE_STORYBOARD
	},
	{
		extensions = '.strings',
		fileType = TEXT_PLIST_STRINGS
	},
	{
		extensions = '.swift',
		fileType = SOURCECODE_SWIFT,
		isSource = true
	},
	{
		extensions = '.wav',
		fileType = AUDIO_WAV
	},
	{
		extensions = '.xcassets',
		fileType = FOLDER_ASSETCATALOG
	},
	{
		extensions = '.xib',
		fileType = FILE_XIB
	},
	{
		extensions = '',
		fileEncoding = 4,
		fileType = TEXT
	}
}


---
-- A simple mock toolset, to enable testing file level switches. Will get removed
-- once the real toolset work is done.
---

local function _getCompilerSwitches(cfg)
	local defines = table.map(cfg.defines, function (_, value)
		return '-D' .. value
	end)

	local includeDirs = table.map(cfg.includeDirs, function (_, value)
		return '-I' .. cfg.project:makeRelative(value)
	end)

	return array.join(defines, includeDirs)
end


---
-- Determine the .xcodeproj category for a project file.
---

local function _categorizeFile(file)
	local categories = xcodeproj.categories
	for i = 1, #categories do
		local category = categories[i]
		if string.endsWith(file, category.extensions) then
			return category
		end
	end
end


---
-- Escape special characters in string values.
---

local function _escape(value)
	value = value
		:gsub('\\', '\\\\')
		:gsub('"', '\\"')

	if not value:isAlphanumericOrAnyOf('./_') then
		value = value:quoted()
	end

	return value
end


---
-- Generates a deterministic 12 byte identifier for a set of string values.
--
-- @param ...
--    One or more string values which are used to seed the identifier.
-- @returns
--    A 24-character string representing the 12 byte ID.
---

local function _generateId(...)
	local seed = string.join('~~', ...)
	return string.format("%08X%08X%08X",
		string.hash(seed, 16777619),
		string.hash(seed, 2166136261),
		string.hash(46577619))
end


function xcodeproj.filename(prj)
	return path.join(prj.location, prj.filename .. '.xcodeproj', 'project.pbxproj')
end


function xcodeproj.export(prj)
	xcodeproj.prepare(prj)

	premake.export(prj, prj.exportPath, function ()
		export.eol('\n')
		export.indentString('\t')
		xcodeproj.root(prj)
	end)

	xcodeproj.cleanup(prj)
end


---
-- Precompute data sets that will be needed during export.
---

function xcodeproj.prepare(prj)
	-- Assign object identifiers, which get referenced in multiple places
	prj.xc_projectCfgListId = _generateId(prj.name, 'xc_projectCfgListId')
	prj.xc_targetCfgListId = _generateId(prj.name, 'xc_targetCfgListId')
	prj.xc_productFileRefId = _generateId(prj.name, 'xc_productFileRefId')

	for i = 1, #prj.configs do
		local cfg = prj.configs[i]
		cfg.xc_name = string.join(' ', cfg.configuration, cfg.platform)
		cfg.xc_projectId = _generateId(cfg.name, 'xc_projectId')
		cfg.xc_targetId = _generateId(cfg.name, 'xc_targetId')
	end

	-- Build the source file tree and assign identifiers
	local files = prj:collectAllSourceFiles()
	prj.sourceTree = prj:buildSourceTree(files)

	tree.traverse(prj.sourceTree, {
		onNode = function (node)
			node.xc_fileRefId = _generateId(node.path, 'xc_fileRefId')
		end,

		onLeaf = function (node, depth)
			if depth > 0 then
				node.xc_category = _categorizeFile(node.name)

				if node.xc_category.isSource then
					node.xc_sourceFileId = _generateId(node.path, 'xc_sourceFileId')
				end

				if node.parent ~= nil and string.endsWith(node.parent.name, '.lproj') then
					node.xc_variantFileId = _generateId(node.name, 'variantFileId')
				end
			end
		end
	}, tree.INCLUDE_ROOT)

	return prj
end


---
-- Release data sets that are no longer needed once project has been exported.
---

function xcodeproj.cleanup(prj)
	prj.sourceTree = nil
end


---
-- Handlers for structural elements, in the order in which they appear in the .vcxproj.
-- Handlers for individual setting elements are at the bottom of the file.
---

function xcodeproj.root(prj)
	wl('// !$*UTF8*$!')
	wl('{')
	indent()
	premake.callArray(xcodeproj.elements.root, prj)
	outdent()
	wl('}')
end


function xcodeproj.objects(prj)
	wl('objects = {')
	wl()
	indent()
	premake.callArray(xcodeproj.elements.objects, prj)
	outdent()
	wl('};')
end


function xcodeproj.pbxBuildFileSection(prj)
	al('/* Begin PBXBuildFile section */')

	tree.traverse(prj.sourceTree, {
		onLeaf = function (node)
			if node.xc_category.isSource then
				local settings

				local fileCfg = xcode.fetchFileConfig(prj, node.path)
				local switches = _getCompilerSwitches(fileCfg)
				if #switches > 0 then
					settings = string.format(' settings = {COMPILER_FLAGS = "%s"; };', table.concat(switches, ' '))
				end

				wl('%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s /* %s */;%s };',
					node.xc_sourceFileId, node.name, node.xc_fileRefId, node.name, settings or '')
			end
		end
	})

	al('/* End PBXBuildFile section */')
	wl()
end


function xcodeproj.pbxCopyFilesBuildPhaseSection(prj)
	al('/* Begin PBXCopyFilesBuildPhase section */')
	wl('494786F326C49D560069B031 /* CopyFiles */ = {')
	indent()
	wl('isa = PBXCopyFilesBuildPhase;')
	wl('buildActionMask = 2147483647;')
	wl('dstPath = /usr/share/man/man1/;')
	wl('dstSubfolderSpec = 0;')
	wl('files = (')
	wl(');')
	wl('runOnlyForDeploymentPostprocessing = 1;')
	outdent()
	wl('};')
	al('/* End PBXCopyFilesBuildPhase section */')
	wl()
end


function xcodeproj.pbxProductFileReference(prj)
	wl('%s /* %s */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = %s; sourceTree = BUILT_PRODUCTS_DIR; };',
		prj.xc_productFileRefId, prj.name, prj.name)
end


function xcodeproj.pbxFileReferenceSection(prj)
	al('/* Begin PBXFileReference section */')
	premake.callArray(xcodeproj.elements.pbxFileReferenceSection, prj)
	al('/* End PBXFileReference section */')
	wl()
end


function xcodeproj.pbxSourceFileReferences(prj)
	local buffer = Buffer.new()

	tree.traverse(prj.sourceTree, {
		onLeaf = function (node, depth)
			local category = node.xc_category

			local isLocalized = string.endsWith(node.parent.name, '.lproj')

			local name
			if isLocalized then
				name = path.getBaseName(path.getDirectory(node.path))
			else
				name = node.name
			end

			buffer:writef('%s /* %s */ = {isa = PBXFileReference;', node.xc_fileRefId, name)

			if category.fileEncoding then
				buffer:writef(' fileEncoding = %s;', category.fileEncoding)
			end

			buffer:writef(' lastKnownFileType = %s;', category.fileType)

			if name ~= node.name then
				buffer:writef(' name = %s;', name)
			end

			local filePath
			if isLocalized then
				filePath = node.path
			else
				filePath = node.name
			end

			buffer:writef(' path = %s; sourceTree = "<group>"; };', filePath)

			wl(buffer:toString())
			buffer:clear()
		end
	})

	buffer:close()
end


function xcodeproj.pbxFrameworksBuildPhaseSection(prj)
	al('/* Begin PBXFrameworksBuildPhase section */')
	wl('494786F226C49D560069B031 /* Frameworks */ = {')
	indent()
	wl('isa = PBXFrameworksBuildPhase;')
	wl('buildActionMask = 2147483647;')
	wl('files = (')
	wl(');')
	wl('runOnlyForDeploymentPostprocessing = 0;')
	outdent()
	wl('};')
	al('/* End PBXFrameworksBuildPhase section */')
	wl()
end


function xcodeproj.pbxGroupSection(prj)
	al('/* Begin PBXGroup section */')
	premake.callArray(xcodeproj.elements.pbxGroupSection, prj)
	al('/* End PBXGroup section */')
	wl()
end


function xcodeproj.pbxFileGroups(prj)
	local localizedFilesEncountered = {}

	tree.traverse(prj.sourceTree, {
		onBranchEnter = function (node, depth)
			if node.name then
				wl('%s /* %s */ = {', node.xc_fileRefId, node.name)
			else
				wl('%s = {', node.xc_fileRefId)
			end

			indent()
			wl('isa = PBXGroup;')
			wl('children = (')
			indent()

			-- collect all files contined by this folder, hoisting localized files
			local contents = {}
			local files = node.children
			for i = 1, #files do
				local file = files[i]
				if string.endsWith(file.name, '.lproj') then
					for j = 1, #file.children do
						contents[file.children[j].name] = file.children[j]
					end
				else
					contents[file.name] = file
				end
			end

			local names = table.sortedKeys(contents)
			for i = 1, #names do
				local file = contents[names[i]]
				wl('%s /* %s */,', file.xc_variantFileId or file.xc_fileRefId, file.name)
			end

			if depth == 0 then
				wl('494786F626C49D560069B031 /* Products */,')
			end

			outdent()
			wl(');')

			if depth > 0 then
				wl('path = %s;', node.name)
			end

			wl('sourceTree = "<group>";')
			outdent()
			wl('};')
		end
	}, tree.INCLUDE_ROOT)
end


function xcodeproj.pbxProductsGroup(prj)
	wl('494786F626C49D560069B031 /* Products */ = {')
	indent()
	wl('isa = PBXGroup;')
	wl('children = (')
	indent()
	wl('%s /* %s */,', prj.xc_productFileRefId, prj.name)
	outdent()
	wl(');')
	wl('name = Products;')
	wl('sourceTree = "<group>";')
	outdent()
	wl('};')
end


function xcodeproj.pbxNativeTargetSection(prj)
	al('/* Begin PBXNativeTarget section */')
	wl('494786F426C49D560069B031 /* Premake */ = {')
	indent()
	wl('isa = PBXNativeTarget;')
	wl('buildConfigurationList = FC0F0273FCC1FF65357F1A92 /* Build configuration list for PBXNativeTarget "Premake" */;')
	wl('buildPhases = (')
	indent()
	wl('494786F126C49D560069B031 /* Sources */,')
	wl('494786F226C49D560069B031 /* Frameworks */,')
	wl('494786F326C49D560069B031 /* CopyFiles */,')
	outdent()
	wl(');')
	wl('buildRules = (')
	wl(');')
	wl('dependencies = (')
	wl(');')
	wl('name = Premake;')
	wl('productName = Premake;')
	wl('productReference = %s /* Premake */;', prj.xc_productFileRefId)
	wl('productType = "com.apple.product-type.tool";')
	outdent()
	wl('};')
	al('/* End PBXNativeTarget section */')
	wl()
end


function xcodeproj.pbxProjectSection(prj)
	al('/* Begin PBXProject section */')
	wl('08FB7793FE84155DC02AAC07 /* Project object */ = {')
	indent()
	wl('isa = PBXProject;')
	wl('attributes = {')
	indent()
	wl('BuildIndependentTargetsInParallel = 1;')
	wl('LastUpgradeCheck = 1300;')
	wl('TargetAttributes = {')
	indent()
	wl('494786F426C49D560069B031 = {')
	indent()
	wl('CreatedOnToolsVersion = 13.0;')
	outdent()
	wl('};')
	outdent()
	wl('};')
	outdent()
	wl('};')
	wl('buildConfigurationList = 4CD7E94363EA8475357F1A92 /* Build configuration list for PBXProject "Premake" */;')
	wl('compatibilityVersion = "Xcode 13.0";')
	wl('developmentRegion = en;')
	wl('hasScannedForEncodings = 0;')
	wl('knownRegions = (')
	indent()
	wl('en,')
	wl('Base,')
	outdent()
	wl(');')
	wl('mainGroup = %s;', prj.sourceTree.xc_fileRefId)
	wl('productRefGroup = 494786F626C49D560069B031 /* Products */;')
	wl('projectDirPath = "";')
	wl('projectRoot = "";')
	wl('targets = (')
	indent()
	wl('494786F426C49D560069B031 /* Premake */,')
	outdent()
	wl(');')
	outdent()
	wl('};')
	al('/* End PBXProject section */')
	wl()
end


function xcodeproj.pbxSourcesBuildPhaseSection(prj)
	al('/* Begin PBXSourcesBuildPhase section */')
	wl('494786F126C49D560069B031 /* Sources */ = {')
	indent()
	wl('isa = PBXSourcesBuildPhase;')
	wl('buildActionMask = 2147483647;')
	wl('files = (')
	indent()

	tree.traverse(prj.sourceTree, {
		onLeaf = function (node)
			if node.xc_category.isSource then
				wl('%s /* %s in Sources */,', node.xc_sourceFileId, node.name)
			end
		end
	})

	outdent()
	wl(');')
	wl('runOnlyForDeploymentPostprocessing = 0;')
	outdent()
	wl('};')
	al('/* End PBXSourcesBuildPhase section */')
	wl()
end


function xcodeproj.pbxVariantGroupSection(prj)
	local localizations = tree.find(prj.sourceTree, function (node)
		return (string.endsWith(node.name, '.lproj'))
	end)

	-- Don't emit this section unless there are localized files
	if #localizations == 0 then
		return
	end

	-- Invert the relationship between the `.lproj` parent and the files they contain
	local localizedFiles = {}

	for i = 1, #localizations do
		local localizationNode = localizations[i]

		local children = localizationNode.children
		for j = 1, #children do
			local child = children[j]

			if localizedFiles[child.name] == nil then
				localizedFiles[child.name] = {
					node = child,
					localizations = { localizationNode }
				}
			else
				table.insert(localizedFiles[child.name].localizations, localizationNode)
			end
		end
	end

	local sortedNames = table.sortedKeys(localizedFiles)

	al('/* Begin PBXVariantGroup section */')

	for i = 1, #sortedNames do
		local file = localizedFiles[sortedNames[i]]
		local node = file.node
		local localizations = file.localizations

		wl('%s /* %s */ = {', node.xc_variantFileId, node.name)
		indent()
		wl('isa = PBXVariantGroup;')
		wl('children = (')
		indent()

		for j = 1, #localizations do
			local localization = localizations[j]
			wl('%s /* %s */,', localization.xc_fileRefId, path.getBaseName(localization.name))
		end

		outdent()
		wl(');')
		wl('name = %s;', node.name)
		wl('sourceTree = "<group>";')
		outdent()
		wl('};')
	end

	al('/* End PBXVariantGroup section */')
end


function xcodeproj.xcBuildConfigurationSection(prj)
	al('/* Begin XCBuildConfiguration section */')
	premake.callArray(xcodeproj.elements.xcBuildConfigurationSection, prj)
	al('/* End XCBuildConfiguration section */')
	wl()
end


function xcodeproj.xcProjectBuildConfiguration(prj)
	local configs = prj.configs
	for i = 1, #configs do
		local cfg = configs[i]
		wl('%s /* %s */ = {', cfg.xc_projectId, cfg.xc_name)
		indent()
		wl('isa = XCBuildConfiguration;')
		wl('buildSettings = {')
		indent()
		premake.callArray(xcodeproj.elements.xcBuildConfiguration, cfg)
		outdent()
		wl('};')
		wl('name = %s;', _escape(cfg.xc_name))
		outdent()
		wl('};')
	end
end


function xcodeproj.xcTargetBuildConfiguration(prj)
	local configs = prj.configs
	for i = 1, #configs do
		local cfg = configs[i]
		wl('%s /* %s */ = {', cfg.xc_targetId, cfg.xc_name)
		indent()
		wl('isa = XCBuildConfiguration;')
		wl('buildSettings = {')
		indent()
		premake.callArray(xcodeproj.elements.xcTargetBuildConfiguration, cfg)
		outdent()
		wl('};')
		wl('name = %s;', _escape(cfg.xc_name))
		outdent()
		wl('};')
	end
end


function xcodeproj.xcConfigurationListSection(prj)
	al('/* Begin XCConfigurationList section */')
	premake.callArray(xcodeproj.elements.xcConfigurationListSection, prj)
	al('/* End XCConfigurationList section */')
end


function xcodeproj.xcProjectConfigurationList(prj)
	wl('%s /* Build configuration list for PBXProject "%s" */ = {', prj.xc_projectCfgListId, prj.name)
	indent()
	wl('isa = XCConfigurationList;')
	wl('buildConfigurations = (')
	indent()

	local configs = prj.configs
	for i = 1, #configs do
		local cfg = configs[i]
		wl('%s /* %s */,', cfg.xc_projectId, cfg.xc_name)
	end

	outdent()
	wl(');')
	wl('defaultConfigurationIsVisible = 0;')
	wl('defaultConfigurationName = %s;', _escape(configs[1].xc_name))
	outdent()
	wl('};')
end


function xcodeproj.xcTargetConfigurationList(prj)
	wl('%s /* Build configuration list for PBXNativeTarget "%s" */ = {', prj.xc_targetCfgListId, prj.name)
	indent()
	wl('isa = XCConfigurationList;')
	wl('buildConfigurations = (')
	indent()

	local configs = prj.configs
	for i = 1, #configs do
		local cfg = configs[i]
		wl('%s /* %s */,', cfg.xc_targetId, cfg.xc_name)
	end

	outdent()
	wl(');')
	wl('defaultConfigurationIsVisible = 0;')
	wl('defaultConfigurationName = %s;', _escape(configs[1].xc_name))
	outdent()
	wl('};')
end


---
-- Handlers for individual setting elements, in alpha order.
---


function xcodeproj.archiveVersion()
	wl('archiveVersion = 1;')
end


function xcodeproj.ALWAYS_SEARCH_USER_PATHS(cfg)
	wl('ALWAYS_SEARCH_USER_PATHS = NO;')
end


function xcodeproj.CLANG_ANALYZER_NONNULL(cfg)
	wl('CLANG_ANALYZER_NONNULL = YES;')
end


function xcodeproj.CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION(cfg)
	wl('CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;')
end


function xcodeproj.CLANG_CXX_LANGUAGE_STANDARD(cfg)
	wl('CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";')
end


function xcodeproj.CLANG_CXX_LIBRARY(cfg)
	wl('CLANG_CXX_LIBRARY = "libc++";')
end


function xcodeproj.CLANG_ENABLE_MODULES(cfg)
	wl('CLANG_ENABLE_MODULES = YES;')
end


function xcodeproj.CLANG_ENABLE_OBJC_ARC(cfg)
	wl('CLANG_ENABLE_OBJC_ARC = YES;')
end


function xcodeproj.CLANG_ENABLE_OBJC_WEAK(cfg)
	wl('CLANG_ENABLE_OBJC_WEAK = YES;')
end


function xcodeproj.CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING(cfg)
	wl('CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;')
end


function xcodeproj.CLANG_WARN_BOOL_CONVERSION(cfg)
	wl('CLANG_WARN_BOOL_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_COMMA(cfg)
	wl('CLANG_WARN_COMMA = YES;')
end


function xcodeproj.CLANG_WARN_CONSTANT_CONVERSION(cfg)
	wl('CLANG_WARN_CONSTANT_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS(cfg)
	wl('CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;')
end


function xcodeproj.CLANG_WARN_DIRECT_OBJC_ISA_USAGE(cfg)
	wl('CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;')
end


function xcodeproj.CLANG_WARN_DOCUMENTATION_COMMENTS(cfg)
	wl('CLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
end


function xcodeproj.CLANG_WARN_EMPTY_BODY(cfg)
	wl('CLANG_WARN_EMPTY_BODY = YES;')
end


function xcodeproj.CLANG_WARN_ENUM_CONVERSION(cfg)
	wl('CLANG_WARN_ENUM_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_INFINITE_RECURSION(cfg)
	wl('CLANG_WARN_INFINITE_RECURSION = YES;')
end


function xcodeproj.CLANG_WARN_INT_CONVERSION(cfg)
	wl('CLANG_WARN_INT_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_NON_LITERAL_NULL_CONVERSION(cfg)
	wl('CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF(cfg)
	wl('CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;')
end


function xcodeproj.CLANG_WARN_OBJC_LITERAL_CONVERSION(cfg)
	wl('CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;')
end


function xcodeproj.CLANG_WARN_OBJC_ROOT_CLASS(cfg)
	wl('CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;')
end


function xcodeproj.CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER(cfg)
	wl('CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;')
end


function xcodeproj.CLANG_WARN_RANGE_LOOP_ANALYSIS(cfg)
	wl('CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;')
end


function xcodeproj.CLANG_WARN_STRICT_PROTOTYPES(cfg)
	wl('CLANG_WARN_STRICT_PROTOTYPES = YES;')
end


function xcodeproj.CLANG_WARN_SUSPICIOUS_MOVE(cfg)
	wl('CLANG_WARN_SUSPICIOUS_MOVE = YES;')
end


function xcodeproj.CLANG_WARN_UNGUARDED_AVAILABILITY(cfg)
	wl('CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;')
end


function xcodeproj.CLANG_WARN_UNREACHABLE_CODE(cfg)
	wl('CLANG_WARN_UNREACHABLE_CODE = YES;')
end


function xcodeproj.CLANG_WARN__DUPLICATE_METHOD_MATCH(cfg)
	wl('CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;')
end


function xcodeproj.classes()
	wl('classes = {')
	wl('};')
end


function xcodeproj.CODE_SIGN_STYLE(cfg)
	wl('CODE_SIGN_STYLE = Manual;')
end


function xcodeproj.COPY_PHASE_STRIP(cfg)
	wl('COPY_PHASE_STRIP = NO;')
end


function xcodeproj.DEBUG_INFORMATION_FORMAT(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('DEBUG_INFORMATION_FORMAT = dwarf;')
	else
		wl('DEBUG_INFORMATION_FORMAT = dwarf-with-dsym;')
	end
end


function xcodeproj.DEVELOPMENT_TEAM(cfg)
	wl('DEVELOPMENT_TEAM = "";')
end


function xcodeproj.ENABLE_HARDENED_RUNTIME(cfg)
	wl('ENABLE_HARDENED_RUNTIME = YES;')
end


function xcodeproj.ENABLE_NS_ASSERTIONS(cfg)
	-- for testing
	if cfg.name:startsWith('Release') then
		wl('ENABLE_NS_ASSERTIONS = NO;')
	end
end


function xcodeproj.ENABLE_STRICT_OBJC_MSGSEND(cfg)
	wl('ENABLE_STRICT_OBJC_MSGSEND = YES;')
end


function xcodeproj.ENABLE_TESTABILITY(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('ENABLE_TESTABILITY = YES;')
	end
end


function xcodeproj.GCC_C_LANGUAGE_STANDARD(cfg)
	wl('GCC_C_LANGUAGE_STANDARD = gnu11;')
end


function xcodeproj.GCC_DYNAMIC_NO_PIC(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('GCC_DYNAMIC_NO_PIC = NO;')
	end
end


function xcodeproj.GCC_NO_COMMON_BLOCKS(cfg)
	wl('GCC_NO_COMMON_BLOCKS = YES;')
end


function xcodeproj.GCC_OPTIMIZATION_LEVEL(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('GCC_OPTIMIZATION_LEVEL = 0;')
	end
end


function xcodeproj.GCC_PREPROCESSOR_DEFINITIONS(cfg)
	if #cfg.defines > 0 then
		wl('GCC_PREPROCESSOR_DEFINITIONS = (')
		indent()
		for i = 1, #cfg.defines do
			wl('%s,', _escape(cfg.defines[i]))
		end
		outdent()
		wl(');')
	end
end


function xcodeproj.GCC_WARN_64_TO_32_BIT_CONVERSION(cfg)
	wl('GCC_WARN_64_TO_32_BIT_CONVERSION = YES;')
end


function xcodeproj.GCC_WARN_ABOUT_RETURN_TYPE(cfg)
	wl('GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;')
end


function xcodeproj.GCC_WARN_UNDECLARED_SELECTOR(cfg)
	wl('GCC_WARN_UNDECLARED_SELECTOR = YES;')
end


function xcodeproj.GCC_WARN_UNINITIALIZED_AUTOS(cfg)
	wl('GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;')
end


function xcodeproj.GCC_WARN_UNUSED_FUNCTION(cfg)
	wl('GCC_WARN_UNUSED_FUNCTION = YES;')
end


function xcodeproj.GCC_WARN_UNUSED_VARIABLE(cfg)
	wl('GCC_WARN_UNUSED_VARIABLE = YES;')
end


function xcodeproj.MACOSX_DEPLOYMENT_TARGET(cfg)
	wl('MACOSX_DEPLOYMENT_TARGET = 11.3;')
end


function xcodeproj.MTL_ENABLE_DEBUG_INFO(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
	else
		wl('MTL_ENABLE_DEBUG_INFO = NO;')
	end
end


function xcodeproj.MTL_FAST_MATH(cfg)
	wl('MTL_FAST_MATH = YES;')
end


function xcodeproj.objectVersion()
	wl('objectVersion = %s;', xcode.targetVersion:map({
		['12'] = 50,
		['13'] = 55
	}))
end


function xcodeproj.ONLY_ACTIVE_ARCH(cfg)
	-- for testing
	if cfg.name:startsWith('Debug') then
		wl('ONLY_ACTIVE_ARCH = YES;')
	end
end


function xcodeproj.PRODUCT_NAME(cfg)
	wl('PRODUCT_NAME = "$(TARGET_NAME)";')
end


function xcodeproj.rootObject()
	wl('rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
end


function xcodeproj.SDKROOT(cfg)
	wl('SDKROOT = macosx;')
end


function xcodeproj.USER_HEADER_SEARCH_PATHS(cfg)
	if #cfg.includeDirs > 0 then
		wl('USER_HEADER_SEARCH_PATHS = (')
		indent()
		local relativePaths = cfg.project:makeRelative(cfg.includeDirs)
		for i = 1, #relativePaths do
			wl('%s,', _escape(relativePaths[i]))
		end
		outdent()
		wl(');')
	end
end


return xcodeproj

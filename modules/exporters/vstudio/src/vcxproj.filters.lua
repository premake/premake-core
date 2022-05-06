local export = require('export')
local path = require('path')
local premake = require('premake')
local tree = require('tree')
local xml = require('xml')

local vstudio = select(1, ...)
local vcxproj = vstudio.vcxproj

local esc = xml.escape
local wl = export.writeLine

local filters = {}


---
-- Element lists describe the contents of each section of the project file
---

filters.elements = {
	project = function (prj)
		return {
			vcxproj.xmlDeclaration,
			filters.project,
			filters.identifiers,
			filters.filters,
			vcxproj.endTag
		}
	end
}


---
-- Export the project's `.vcxproj.filters` file.
--
-- @return
--    True if the target `.vcxproj.filters` file was updated; false otherwise.
---

function filters.export(prj)
	if tree.hasBranches(prj.virtualSourceTree) then
		local exportPath = prj.exportPath .. '.filters'
		return premake.export(prj, exportPath, function ()
			export.eol('\r\n')
			export.indentString('  ')
			premake.callArray(filters.elements.project, prj)
		end)
	end
	return false
end


---
-- Handlers for structural elements, in the order in which they appear in the .vcxproj.filters file.
---

function filters.project()
	wl('<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
	export.indent()
end


---
-- Export the initial `<ItemGroup/>` which assigns unique identifiers to each folder
-- (which might be virtual) in the source tree.
---

function filters.identifiers(prj)
	local settings = export.capture(function ()
		export.indent()
		tree.traverse(prj.sourceTree, {
			onBranchEnter = function (node, depth)
				local filename = path.getRelative(prj.baseDirectory, node.path)
				wl('<Filter Include="%s">', path.translate(filename))
				export.indent()
				wl('<UniqueIdentifier>{%s}</UniqueIdentifier>', os.uuid(node.path))
				export.outdent()
				wl('</Filter>')
			end
		})
		export.outdent()
	end)

	if #settings > 0 then
		wl('<ItemGroup>')
		wl(settings)
		wl('</ItemGroup>')
	end
end


function filters.filters(prj)
	local categorizedFiles = prj.categorizedSourceFiles
	for ci = 1, #categorizedFiles do
		local category = vcxproj.categories[ci]
		local files = categorizedFiles[ci]
		if #files > 0 then
			wl('<ItemGroup>')
			export.indent()
			for fi = 1, #files do
				filters.emitFileItem(prj, category, files[fi])
			end
			export.outdent()
			wl('</ItemGroup>')
		end
	end
end


function filters.emitFileItem(prj, category, filePath)
	filePath = path.getRelative(prj.baseDirectory, filePath)

	-- TODO: use virtual paths here when available
	local virtualPath = filePath
	local virtualGroup = path.getDirectory(virtualPath)

	if virtualGroup == '.' then
		wl('<%s Include="%s" />', category.tag, path.translate(filePath))
	else
		wl('<%s Include="%s">', category.tag, path.translate(filePath))
		export.indent()
		wl('<Filter>%s</Filter>', path.translate(virtualGroup))
		export.outdent()
		wl('</%s>', category.tag)
	end
end


return filters

---
-- Xcode workspace (.xcworkspace) exporter
---

local export = require('export')
local path = require('path')
local premake = require('premake')

local wl = export.writeLine

local xcworkspace = {}


---
-- Element lists describe the contents of each section of the workspace file
---

xcworkspace.elements = {
	root = function (wks)
		return {
			xcworkspace.xmlDeclaration,
			xcworkspace.workspace,
			xcworkspace.fileRefs,
			xcworkspace.endTag,
		}
	end,
}


function xcworkspace.export(wks)
	export.eol('\n')
	export.indentString('   ')
	premake.callArray(xcworkspace.elements.root, wks)
end


function xcworkspace.filename(wks)
	return path.join(wks.location, wks.filename .. '.xcworkspace', 'contents.xcworkspacedata')
end


---
-- Handlers for structural elements, in the order in which they appear in the .vcxproj.
-- Handlers for individual setting elements are at the bottom of the file.
---

function xcworkspace.xmlDeclaration()
	wl('<?xml version="1.0" encoding="UTF-8"?>')
end


function xcworkspace.workspace()
	wl('<Workspace')
	export.indent()
	wl('version = "1.0">')
end


function xcworkspace.fileRefs()
	wl([[
	<FileRef
		location = "group:Premake.xcodeproj">
	</FileRef>]])
end


function xcworkspace.endTag(prj)
	export.outdent()
	wl('</Workspace>')
end


return xcworkspace

---
-- Xcode workspace (.xcworkspace) exporter
---

local export = require('export')
local path = require('path')
local premake = require('premake')
local xml = require('xml')

local esc = xml.escape
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
			xcworkspace.projects,
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


function xcworkspace.projects(wks)
	local projects = wks.projects
	for i = 1, #projects do
		xcworkspace.fileRef(projects[i])
	end
end


function xcworkspace.endTag()
	export.outdent()
	wl('</Workspace>')
end


---
-- Handlers for individual setting elements, in alpha order
---

function xcworkspace.fileRef(prj)
	-- Paths will arrive like "MyWorkspace.xcworkspace/contents.xcworkspacedata" and
	-- "MyProject.xcodeproj/project.pbx". Need to trim off the internal file name parts
	-- in order to get a correct relative path
	local wksRoot = path.getDirectory(prj.workspace.exportPath)
	local prjRoot = path.getDirectory(prj.exportPath)
	local relativePath = path.getRelativeFile(wksRoot, prjRoot)

	wl('<FileRef')
	export.indent()
	wl('location = "group:%s">', esc(relativePath))
	export.outdent()
	wl('</FileRef>')
end


return xcworkspace

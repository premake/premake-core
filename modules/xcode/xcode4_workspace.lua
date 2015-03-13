---
-- xcode/xcode4_workspace.lua
-- Generate an Xcode workspace.
-- Author Mihai Sebea
-- Modified by Jason Perkins
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
---

	local p = premake
	local m = p.modules.xcode



---
-- Generate an Xcode contents.xcworkspacedata file.
---

	m.elements.workspace = function(sln)
		return {
			m.xmlDeclaration,
			m.workspace,
			m.workspaceFileRefs,
			m.workspaceTail,
		}
	end

	function m.generateWorkspace(sln)
		m.preparesolution(sln)
		p.callArray(m.elements.workspace, sln)
	end


	function m.workspace()
		p.push('<Workspace')
		p.w('version = "1.0">')
	end


	function m.workspaceTail()
		-- Don't output final newline.  Xcode doesn't.
		premake.out('</Workspace>')
	end


---
-- Generate the list of project references.
---

	m.elements.workspaceFileRef = function(prj)
		return {
			m.workspaceLocation,
		}
	end

	function m.workspaceFileRefs(sln)
		for prj in p.solution.eachproject(sln) do
			p.push('<FileRef')
			local contents = p.capture(function()
				p.callArray(m.elements.workspaceFileRef, prj)
			end)
			p.out(contents .. ">")
			p.pop('</FileRef>')
		end
	end



---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------


	function m.workspaceLocation(prj)
		local fname = p.filename(prj, ".xcodeproj")
		fname = path.getrelative(prj.solution.location, fname)
		p.w('location = "group:%s"', fname)
	end


	function m.xmlDeclaration()
		p.xmlUtf8(true)
	end

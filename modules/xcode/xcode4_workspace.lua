---
-- xcode/xcode4_workspace.lua
-- Generate an Xcode workspace.
-- Author Mihai Sebea
-- Modified by Jason Perkins
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
---

	local p = premake
	local m = p.modules.xcode
	local tree = p.tree


---
-- Generate an Xcode contents.xcworkspacedata file.
---

	m.elements.workspace = function(wks)
		return {
			m.xmlDeclaration,
			m.workspace,
			m.reorderProjects,
			m.workspaceFileRefs,
			m.workspaceTail,
		}
	end

	function m.generateWorkspace(wks)
		m.prepareWorkspace(wks)
		p.callArray(m.elements.workspace, wks)
	end


	function m.workspace()
		p.push('<Workspace')
		p.w('version = "1.0">')
	end


	function m.workspaceTail()
		-- Don't output final newline.  Xcode doesn't.
		p.out('</Workspace>')
	end


--
-- If a startup project is specified, move it (and any enclosing groups)
-- to the front of the project list. This will make Visual Studio treat
-- it like a startup project.
--
-- I force the new ordering into the tree so that it will get applied to
-- all sections of the solution; otherwise the first change to the solution
-- in the IDE will cause the orderings to get rewritten.
--

	function m.reorderProjects(wks)
		if wks.startproject then
			local np
			local tr = p.workspace.grouptree(wks)
			tree.traverse(tr, {
				onleaf = function(n)
					if n.project.name == wks.startproject then
						np = n
					end
				end
			})

			while np and np.parent do
				local p = np.parent
				local i = table.indexof(p.children, np)
				table.remove(p.children, i)
				table.insert(p.children, 1, np)
				np = p
			end
		end
	end


---
-- Generate the list of project references.
---

	m.elements.workspaceFileRef = function(prj)
		return {
			m.workspaceLocation,
		}
	end

	function m.workspaceFileRefs(wks)
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				p.push('<FileRef')
				local contents = p.capture(function()
					p.callArray(m.elements.workspaceFileRef, prj)
				end)
				p.outln(contents .. ">")
				p.pop('</FileRef>')
			end,

			onbranchenter = function(n)
				local prj = n.project

				p.push('<Group')
				p.w('location = "container:"')
				p.w('name = "%s">', n.name)
			end,
			
			onbranchexit = function(n)
				p.pop('</Group>')
			end,
		})
	end

---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------


	function m.workspaceLocation(prj)
		local fname = p.filename(prj, ".xcodeproj")
		fname = path.getrelative(prj.workspace.location, fname)
		p.w('location = "group:%s"', fname)
	end


	function m.xmlDeclaration()
		p.xmlUtf8(true)
	end

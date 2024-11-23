--
-- vs2010_vcxproj_filters.lua
-- Generate a Visual Studio 201x C/C++ filters file.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	local project = p.project
	local tree = p.tree

	local m = p.vstudio.vc2010


--
-- Generate a Visual Studio 201x C++ project, with support for the new platforms API.
--

	m.elements.filters = function(prj)
		return {
			m.xmlDeclaration,
			m.filtersProject,
			m.uniqueIdentifiers,
			m.filterGroups,
		}
	end

	function m.generateFilters(prj)
		p.utf8()
		p.callArray(m.elements.filters, prj)
		p.out('</Project>')
	end


--
-- Output the XML declaration and opening <Project> tag.
--

	function m.filtersProject()
		local action = p.action.current()
		p.push('<Project ToolsVersion="%s" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">',
			action.vstudio.filterToolsVersion or action.vstudio.toolsVersion)
	end



	function m.filterGroups(prj)
		local groups = m.categorizeSources(prj)
		for _, group in ipairs(groups) do
			group.category.emitFilter(prj, group)
		end
	end



--
-- The first portion of the filters file assigns unique IDs to each
-- directory or virtual group. Would be cool if we could automatically
-- map vpaths like "**.h" to an <Extensions>h</Extensions> element.
--

	function m.uniqueIdentifiers(prj)
		-- This map contains the sort key for the known filters.
		local knownFilters = {
			['Source Files'] = 1,
			['Header Files'] = 2,
			['Resource Files'] = 3,
		}

		local sortInFilterOrder = function (a,b)
			if #a.children > 0 or #b.children > 0 then
				local orderA = knownFilters[a.name] or 999
				local orderB = knownFilters[b.name] or 999
				if orderA < orderB then
					return true
				end
				if orderA > orderB then
					return false
				end
				-- This can only happen if both filters are
				-- unknown, fall back on default comparison.
			end

			-- Use default order
			return a.name < b.name
		end

		local tr = project.getsourcetree(prj, sortInFilterOrder)
		local contents = p.capture(function()
			p.push()
			tree.traverse(tr, {
				onbranch = function(node, depth)
					p.push('<Filter Include="%s">', path.translate(node.path, '\\'))
					p.w('<UniqueIdentifier>{%s}</UniqueIdentifier>', os.uuid(node.path))
					p.pop('</Filter>')
				end
			}, false)
			p.pop()
		end)

		if #contents > 0 then
			p.push('<ItemGroup>')
			p.outln(contents)
			p.pop('</ItemGroup>')
		end
	end


	function m.filterGroup(prj, group, tag)
		local files = group.files
		if files and #files > 0 then
			p.push('<ItemGroup>')
			for _, file in ipairs(files) do
				local rel = path.translate(file.relpath)

				-- SharedItems projects paths are prefixed with a magical variable
				if prj.kind == p.SHAREDITEMS then
					rel = "$(MSBuildThisFileDirectory)" .. rel
				end

				if file.parent.path then
					p.push('<%s Include=\"%s\">', tag, rel)
					p.w('<Filter>%s</Filter>', path.translate(file.parent.path, '\\'))
					p.pop('</%s>', tag)
				else
					p.w('<%s Include=\"%s\" />', tag, rel)
				end
			end
			p.pop('</ItemGroup>')
		end
	end


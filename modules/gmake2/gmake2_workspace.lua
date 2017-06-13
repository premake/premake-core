--
-- gmake2_workspace.lua
-- Generate a workspace-level makefile.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local gmake2 = p.modules.gmake2

	local tree    = p.tree
	local project = p.project

--
-- Generate a GNU make "workspace" makefile, with support for the new platforms API.
--

	function gmake2.generate_workspace(wks)
		p.eol("\n")

		gmake2.header(wks)

		gmake2.configmap(wks)
		gmake2.projects(wks)

		gmake2.workspacePhonyRule(wks)
		gmake2.groupRules(wks)

		gmake2.projectrules(wks)
		gmake2.cleanrules(wks)
		gmake2.helprule(wks)
	end


--
-- Write out the workspace's configuration map, which maps workspace
-- level configurations to the project level equivalents.
--

	function gmake2.configmap(wks)
		for cfg in p.workspace.eachconfig(wks) do
			_p('ifeq ($(config),%s)', cfg.shortname)
			for prj in p.workspace.eachproject(wks) do
				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg then
					_p('  %s_config = %s', gmake2.tovar(prj.name), prjcfg.shortname)
				end
			end
			_p('endif')
		end
		_p('')
	end


--
-- Write out the rules for the `make clean` action.
--

	function gmake2.cleanrules(wks)
		_p('clean:')
		for prj in p.workspace.eachproject(wks) do
			local prjpath = p.filename(prj, gmake2.getmakefilename(prj, true))
			local prjdir = path.getdirectory(path.getrelative(wks.location, prjpath))
			local prjname = path.getname(prjpath)
			_x(1,'@${MAKE} --no-print-directory -C %s -f %s clean', prjdir, prjname)
		end
		_p('')
	end


--
-- Write out the make file help rule and configurations list.
--

	function gmake2.helprule(wks)
		_p('help:')
		_p(1,'@echo "Usage: make [config=name] [target]"')
		_p(1,'@echo ""')
		_p(1,'@echo "CONFIGURATIONS:"')

		for cfg in p.workspace.eachconfig(wks) do
			_x(1, '@echo "  %s"', cfg.shortname)
		end

		_p(1,'@echo ""')

		_p(1,'@echo "TARGETS:"')
		_p(1,'@echo "   all (default)"')
		_p(1,'@echo "   clean"')

		for prj in p.workspace.eachproject(wks) do
			_p(1,'@echo "   %s"', prj.name)
		end

		_p(1,'@echo ""')
		_p(1,'@echo "For more information, see http://industriousone.com/premake/quick-start"')
	end


--
-- Write out the list of projects that comprise the workspace.
--

	function gmake2.projects(wks)
		_p('PROJECTS := %s', table.concat(p.esc(table.extract(wks.projects, "name")), " "))
		_p('')
	end

--
-- Write out the workspace PHONY rule
--

	function gmake2.workspacePhonyRule(wks)
		local groups = {}
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onbranch = function(n)
				table.insert(groups, n.path)
			end
		})

		_p('.PHONY: all clean help $(PROJECTS) ' .. table.implode(groups, '', '', ' '))
		_p('')
		_p('all: $(PROJECTS)')
		_p('')
	end

--
-- Write out the phony rules representing project groups
--
	function gmake2.groupRules(wks)
		-- Transform workspace groups into target aggregate
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onbranch = function(n)
				local rule = n.path .. ":"
				local projectTargets = {}
				local groupTargets = {}
				for i, c in pairs(n.children)
				do
					if type(i) == "string"
					then
						if c.project
						then
							table.insert(projectTargets, c.name)
						else
							table.insert(groupTargets, c.path)
						end
					end
				end
				if #groupTargets > 0 then
					table.sort(groupTargets)
					rule = rule .. " " .. table.concat(groupTargets, " ")
				end
				if #projectTargets > 0 then
					table.sort(projectTargets)
					rule = rule .. " " .. table.concat(projectTargets, " ")
				end
				_p(rule)
				_p('')
			end
		})
	end

--
-- Write out the rules to build each of the workspace's projects.
--

	function gmake2.projectrules(wks)
		for prj in p.workspace.eachproject(wks) do
			local deps = project.getdependencies(prj)
			deps = table.extract(deps, "name")
			_p('%s:%s', p.esc(prj.name), gmake2.list(deps))

			local cfgvar = gmake2.tovar(prj.name)
			_p('ifneq (,$(%s_config))', cfgvar)

			_p(1,'@echo "==== Building %s ($(%s_config)) ===="', prj.name, cfgvar)

			local prjpath = p.filename(prj, gmake2.getmakefilename(prj, true))
			local prjdir = path.getdirectory(path.getrelative(wks.location, prjpath))
			local prjname = path.getname(prjpath)

			_x(1,'@${MAKE} --no-print-directory -C %s -f %s config=$(%s_config)', prjdir, prjname, cfgvar)

			_p('endif')
			_p('')
		end
	end

--
-- make_solution.lua
-- Generate a solution-level makefile.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	local make = premake.make
	local solution = premake.solution
	local tree = premake.tree
	local project = premake.project


--
-- Generate a GNU make "solution" makefile, with support for the new platforms API.
--

	function make.generate_solution(sln)
		premake.eol("\n")

		make.header(sln)

		make.configmap(sln)
		make.projects(sln)

		make.solutionPhonyRule(sln)
		make.groupRules(sln)

		make.projectrules(sln)
		make.cleanrules(sln)
		make.helprule(sln)
	end


--
-- Write out the solution's configuration map, which maps solution
-- level configurations to the project level equivalents.
--

	function make.configmap(sln)
		for cfg in solution.eachconfig(sln) do
			_p('ifeq ($(config),%s)', cfg.shortname)
			for prj in solution.eachproject(sln) do
				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg then
					_p('  %s_config = %s', make.tovar(prj.name), prjcfg.shortname)
				end
			end
			_p('endif')
		end
		_p('')
	end


--
-- Write out the rules for the `make clean` action.
--

	function make.cleanrules(sln)
		_p('clean:')
		for prj in solution.eachproject(sln) do
			local prjpath = premake.filename(prj, make.getmakefilename(prj, true))
			local prjdir = path.getdirectory(path.getrelative(sln.location, prjpath))
			local prjname = path.getname(prjpath)
			_x(1,'@${MAKE} --no-print-directory -C %s -f %s clean', prjdir, prjname)
		end
		_p('')
	end


--
-- Write out the make file help rule and configurations list.
--

	function make.helprule(sln)
		_p('help:')
		_p(1,'@echo "Usage: make [config=name] [target]"')
		_p(1,'@echo ""')
		_p(1,'@echo "CONFIGURATIONS:"')

		for cfg in solution.eachconfig(sln) do
			_x(1, '@echo "  %s"', cfg.shortname)
		end

		_p(1,'@echo ""')

		_p(1,'@echo "TARGETS:"')
		_p(1,'@echo "   all (default)"')
		_p(1,'@echo "   clean"')

		for prj in solution.eachproject(sln) do
			_p(1,'@echo "   %s"', prj.name)
		end

		_p(1,'@echo ""')
		_p(1,'@echo "For more information, see http://industriousone.com/premake/quick-start"')
	end


--
-- Write out the list of projects that comprise the solution.
--

	function make.projects(sln)
		_p('PROJECTS := %s', table.concat(premake.esc(table.extract(sln.projects, "name")), " "))
		_p('')
	end

--
-- Write out the solution PHONY rule
--

	function make.solutionPhonyRule(sln)
		local groups = {}
		local tr = solution.grouptree(sln)
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
	function make.groupRules(sln)
		-- Transform solution groups into target aggregate
		local tr = solution.grouptree(sln)
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
-- Write out the rules to build each of the solution's projects.
--

	function make.projectrules(sln)
		for prj in solution.eachproject(sln) do
			local deps = project.getdependencies(prj)
			deps = table.extract(deps, "name")
			_p('%s:%s', premake.esc(prj.name), make.list(deps))

			local cfgvar = make.tovar(prj.name)
			_p('ifneq (,$(%s_config))', cfgvar)

			_p(1,'@echo "==== Building %s ($(%s_config)) ===="', prj.name, cfgvar)

			local prjpath = premake.filename(prj, make.getmakefilename(prj, true))
			local prjdir = path.getdirectory(path.getrelative(sln.location, prjpath))
			local prjname = path.getname(prjpath)

			_x(1,'@${MAKE} --no-print-directory -C %s -f %s config=$(%s_config)', prjdir, prjname, cfgvar)

			_p('endif')
			_p('')
		end
	end

--
-- _clean.lua
-- The "clean" action: removes all generated files.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Remove files created by an object's templates.
--

	local function cleantemplatefiles(this, templates)
		if (templates) then
			for _,tmpl in ipairs(templates) do
				local fname = premake.getoutputname(this, tmpl[1])
				os.remove(fname)
			end
		end
	end
	

--
-- Register the "clean" action.
--

	newaction {
		trigger     = "clean",
		description = "Remove all binaries and generated files",

		execute = function()
			local solutions = { }
			local projects = { }
			local targets = { }
			
			-- Walk the tree. Build a list of object names to pass to the cleaners,
			-- and delete any toolset agnostic files along the way.
			for _,sln in ipairs(_SOLUTIONS) do
				table.insert(solutions, path.join(sln.location, sln.name))
				
				for prj in premake.eachproject(sln) do
					table.insert(projects, path.join(prj.location, prj.name))
					
					if (prj.objdir) then
						os.rmdir(prj.objdir)
					end

					for cfg in premake.eachconfig(prj) do
						local target = premake.gettargetfile(cfg, "target")
						table.insert(targets, path.join(path.getdirectory(target), path.getbasename(target)))

						-- remove all possible permutations of the target binary
						os.remove(premake.gettargetfile(cfg, "target", "windows"))
						os.remove(premake.gettargetfile(cfg, "target", "linux"))
						os.remove(premake.gettargetfile(cfg, "target", "macosx"))

						-- if there is an import library, remove that too
						os.remove(premake.gettargetfile(cfg, "implib", "windows"))
						os.remove(premake.gettargetfile(cfg, "implib", "linux"))

						os.rmdir(cfg.objdir)
					end
				end
			end

			-- Walk the tree again. Delete templated and toolset-specific files
			for _,action in pairs(premake.actions) do
				for _,sln in ipairs(_SOLUTIONS) do
					cleantemplatefiles(sln, action.solutiontemplates)
					for prj in premake.eachproject(sln) do
						cleantemplatefiles(prj, action.projecttemplates)
					end
				end
				
				if (type(action.onclean) == "function") then
					action.onclean(solutions, projects, targets)
				end
			end

			-- global cleaner
			if (type(onclean) == "function") then
				onclean()
			end
		end,		
	}

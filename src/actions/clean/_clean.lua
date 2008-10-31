--
-- _clean.lua
-- The "clean" action: removes all generated files.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	clean = { }
	
--
-- Remove configuration specific files
--

	function clean.config(cfg)
		-- remove the target binary
		os.remove(cfg.target)

		-- if there is an import library, remove that too
		os.remove(premake.project.gettargetfile(cfg, "implib", "StaticLib", "linux"))
		os.remove(premake.project.gettargetfile(cfg, "implib", "StaticLib", "windows"))
		
		-- remove object directory
		-- os.rmdir(cfg.objdir)
	end
	
	
--
-- Remove files created by an object's templates.
--

	function clean.templatefiles(this, templates)
		if (templates) then
			for _,tmpl in ipairs(templates) do
				local fname = premake.getoutputname(this, tmpl[1])
				os.remove(fname)
			end
		end
	end
	

--
-- For each registered action, walk all of the objects in the session and
-- remove the files created by their templates.
--

	function clean.all()
		-- remove all template-driven files
		for _,action in pairs(premake.actions) do
			for _,sln in ipairs(_SOLUTIONS) do
				clean.templatefiles(sln, action.solutiontemplates)

				for prj in premake.project.projects(sln) do
					clean.templatefiles(prj, action.projecttemplates)
					
					for cfg in premake.project.configs(prj) do
						clean.config(cfg)
					end
				end
			end
		end
		
		-- project custom clean-up
		if (type(onclean) == "function") then
			onclean()
		end
	end


--
-- Register the "clean" action.
--

	premake.actions["clean"] = {
		description = "Remove all binaries and generated files",
		execute     = clean.all,
	}

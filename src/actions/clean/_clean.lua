--
-- _clean.lua
-- The "clean" action: removes all generated files.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	clean = { }
	
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
-- Remove solution specific files
--

	function clean.solution(sln)
		local base = path.join(sln.location, sln.name)
		
		-- Visual Studio files
		os.remove(base .. ".suo")
		os.remove(base .. ".ncb")
	end
	

-- 
-- Remove project specific files
--

	function clean.project(prj)
		local base = path.join(prj.location, prj.name)
		
		if (prj.objdir) then
			os.rmdir(prj.objdir)
		end
		
		-- Visual Studio files
		os.remove(base .. ".csproj.user")
		os.remove(base .. ".csproj.webinfo")
		
		local files = os.matchfiles(base .. ".vcproj.*.user", base .. ".csproj.*.user")
		for _, fname in ipairs(files) do
			os.remove(fname)
		end		
	end
	
		
--
-- Remove configuration specific files
--

	function clean.config(cfg)
		-- remove the target binary
		os.remove(premake.gettargetfile(cfg, "target", cfg.kind, "windows"))
		os.remove(premake.gettargetfile(cfg, "target", cfg.kind, "linux"))
		os.remove(premake.gettargetfile(cfg, "target", cfg.kind, "macosx"))

		-- if there is an import library, remove that too
		os.remove(premake.gettargetfile(cfg, "implib", "StaticLib", "linux"))
		os.remove(premake.gettargetfile(cfg, "implib", "StaticLib", "windows"))
		
		local target = premake.gettargetfile(cfg, "target")
		local base = path.join(path.getdirectory(target), path.getbasename(target))
		
		-- Visual Studio files
		os.remove(base .. ".pdb")
		os.remove(base .. ".idb")
		os.remove(base .. ".ilk")
		os.remove(base .. ".vshost.exe")
		os.remove(base .. ".exe.manifest")

		-- Mono files
		os.remove(base .. ".exe.mdb")
		os.remove(base .. ".dll.mdb")
		
		-- remove object directory
		-- os.rmdir(cfg.objdir)
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
				clean.solution(sln)

				for prj in premake.eachproject(sln) do
					clean.templatefiles(prj, action.projecttemplates)
					clean.project(prj)
					
					for cfg in premake.eachconfig(prj) do
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

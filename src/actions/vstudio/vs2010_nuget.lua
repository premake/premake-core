--
-- vs2010_nuget.lua
-- Generate a NuGet packages.config file.
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	premake.vstudio.nuget2010 = {}

	local p = premake
	local vstudio = p.vstudio
	local nuget2010 = p.vstudio.nuget2010
	local cs2005 = p.vstudio.cs2005


--
-- These functions take the package string as an argument and give you
-- information about it.
--

	function nuget2010.packageName(package)
		return package:gsub(":", ".")
	end

	function nuget2010.packageId(package)
		return package:sub(0, package:find(":") - 1)
	end

	function nuget2010.packageVersion(package)
		return package:sub(package:find(":") + 1, -1)
	end

	function nuget2010.packageFramework(prj)
		if p.project.isdotnet(prj) then
			local cfg = p.project.getfirstconfig(prj)
			local action = premake.action.current()
			local framework = cfg.dotnetframework or action.vstudio.targetFramework
			return cs2005.formatNuGetFrameworkVersion(framework)
		else
			return "native"
		end
	end


	local validatedPackages = {}

	function nuget2010.validatePackages(prj)
		if #prj.nuget == 0 then
			return
		end

		for _, package in ipairs(prj.nuget) do
			local id = nuget2010.packageId(package)
			local version = nuget2010.packageVersion(package)

			if not validatedPackages[id] then
				printf("Examining NuGet package '%s'...", id)
				io.flush()

				local response, err, code = http.get(string.format("https://api.nuget.org/v3/registration1/%s/index.json", id:lower()))

				if err ~= "OK" then
					if code == 404 then
						p.error("NuGet package '%s' for project '%s' couldn't be found in the repository", id, prj.name)
					else
						p.error("NuGet API error (%d)\n%s", code, err)
					end
				end
			end
			validatedPackages[id] = package
		end
	end


--
-- Generates the packages.config file.
--

	function nuget2010.generatePackagesConfig(prj)
		if #prj.nuget > 0 then
		p.w('<?xml version="1.0" encoding="utf-8"?>')
		p.push('<packages>')

			for _, package in ipairs(prj.nuget) do
				p.x('<package id="%s" version="%s" targetFramework="%s" />', nuget2010.packageId(package), nuget2010.packageVersion(package), nuget2010.packageFramework(prj))
		end

		p.pop('</packages>')
	end
	end

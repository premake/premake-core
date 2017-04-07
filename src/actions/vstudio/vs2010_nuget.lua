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

	local packageAPIInfos = {}

--
-- These functions take the package string as an argument and give you
-- information about it.
--

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

	function nuget2010.packageAPIInfo(package)
		return packageAPIInfos[package]
	end


	function nuget2010.validatePackages(prj)
		if #prj.nuget == 0 then
			return
		end

		for _, package in ipairs(prj.nuget) do
			local id = nuget2010.packageId(package)
			local version = nuget2010.packageVersion(package)

			if not packageAPIInfos[package] then
				local packageAPIInfo = {}

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

				response, err = json.decode(response)

				if not response then
					p.error("Failed to decode NuGet API response (%s)", err)
				end

				if not response.items or #response.items == 0 then
					p.error("Failed to understand NuGet API response (package '%s' contains no root-level items)", id)
				end

				if not response.items[1].items or #response.items[1].items == 0 then
					p.error("Failed to understand NuGet API response (root-level item for package '%s' contains no subitems)", id)
				end

				local subitems = response.items[1].items

				local versions = {}

				for _, item in ipairs(subitems) do
					if not item.catalogEntry then
						p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry)", id)
					end

					if not item.catalogEntry.version then
						p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry.version)", id)
					end

					if not item.catalogEntry["@id"] then
						p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry['@id'])", id)
					end

					-- Check this URL just in case. We don't want to be making
					-- requests to anywhere else.

					if item.catalogEntry["@id"]:find("https://api.nuget.org/") ~= 1 then
						p.error("Failed to understand NuGet API response (catalogEntry['@id'] was not a NuGet API URL)", id)
					end

					table.insert(versions, item.catalogEntry.version)
				end

				if not table.contains(versions, version) then
					local options = table.translate(versions, function(value) return "'" .. value .. "'" end)
					options = table.concat(options, ", ")

					p.error("'%s' is not a valid version for NuGet package '%s' (options are: %s)", version, id, options)
				end

				for _, item in ipairs(subitems) do
					if item.catalogEntry.version == version then
						local response, err, code = http.get(item.catalogEntry["@id"])

						if err ~= "OK" then
							if code == 404 then
								p.error("NuGet package '%s' version '%s' couldn't be found in the repository even though the API reported that it exists", id, prj.name)
							else
								p.error("NuGet API error (%d)\n%s", code, err)
							end
						end

						response, err = json.decode(response)

						if not response then
							p.error("Failed to decode NuGet API response (%s)", err)
						end

						if not response.verbatimVersion and not response.version then
							p.error("Failed to understand NuGet API response (package '%s' version '%s' has no verbatimVersion or version)", id, version)
						end

						packageAPIInfo.verbatimVersion = response.verbatimVersion
						packageAPIInfo.version = response.version

						-- C++ packages don't have this, but C# packages have a
						-- packageEntries field that lists all the files in the
						-- package. We need to look at this to figure out what
						-- DLLs to reference in the project file.

						if prj.language == "C#" and not response.packageEntries then
							p.error("NuGet package '%s' has no file listing (are you sure referenced a .NET package and not a native package?)", id)
						end

						if prj.language == "C#" then
							packageAPIInfo.packageEntries = {}

							for _, item in ipairs(response.packageEntries) do
								if not item.fullName then
									p.error("Failed to understand NuGet API response (package '%s' version '%s' packageEntry has no fullName)", id, version)
								end

								table.insert(packageAPIInfo.packageEntries, path.translate(item.fullName))
							end

							if #packageAPIInfo.packageEntries == 0 then
								p.error("NuGet package '%s' file listing is empty", id)
							end
						end

						break
					end
				end

				packageAPIInfos[package] = packageAPIInfo
			end
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

--
-- vs2010_nuget.lua
-- Generate a NuGet packages.config file.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.nuget2010 = {}

	local vstudio = p.vstudio
	local nuget2010 = p.vstudio.nuget2010
	local dn2005 = p.vstudio.dotnetbase

	local packageAPIInfos = {}
	local packageSourceInfos = {}

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
			local action = p.action.current()
			local framework = cfg.dotnetframework or action.vstudio.targetFramework
			return dn2005.formatNuGetFrameworkVersion(framework)
		else
			return "native"
		end
	end

	function nuget2010.supportsPackageReferences(prj)
		return _ACTION >= "vs2017" and p.project.isdotnet(prj)
	end


--
-- Given a package string, returns a table containing "verbatimVersion",
-- "version" and for C# packages, "packageEntries".
--

	function nuget2010.packageAPIInfo(prj, package)
		local id = nuget2010.packageId(package)
		local version = nuget2010.packageVersion(package)

		-- It's possible that NuGet already has this package in its cache. In
		-- that case we can examine the nuspec file and the file listing
		-- locally.

		local function examinePackageFromCache()
			-- It should be possible to implement this for platforms other than
			-- Windows, but we'll need to figure out where the NuGet cache is on
			-- these platforms (or if they even have one).

			if not os.ishost("windows") then
				return
			end

			local cachePath = path.translate(path.join(os.getenv("userprofile"), ".nuget/packages", id))

			if os.isdir(cachePath) then
				local packageAPIInfo = {}

				printf("Examining cached NuGet package '%s'...", id)
				io.flush()

				local versionPath = path.translate(path.join(cachePath, version))

				local nuspecPath = path.translate(path.join(versionPath, id .. ".nuspec"))

				if not os.isfile(nuspecPath) then
					return
				end

				local nuspec = io.readfile(nuspecPath)

				if not nuspec then
					return
				end

				packageAPIInfo.verbatimVersion = nuspec:match("<version>(.+)</version>")
				packageAPIInfo.version = version

				if not packageAPIInfo.verbatimVersion then
					return
				end

				-- Using the local file listing for "packageEntries" might
				-- not exactly match what we would get from the API but this
				-- doesn't matter. At the moment of writing, we're only
				-- interested in knowing what DLL files the package
				-- contains.

				packageAPIInfo.packageEntries = {}

				for _, file in ipairs(os.matchfiles(path.translate(path.join(versionPath, "**")))) do
					local extension = path.getextension(file)

					if extension ~= ".nupkg" and extension ~= ".sha512" then
						table.insert(packageAPIInfo.packageEntries, path.translate(path.getrelative(versionPath, file)))
					end
				end

				if #packageAPIInfo.packageEntries == 0 then
					return
				end

				if nuspec:match("<frameworkAssemblies>(.+)</frameworkAssemblies>") then
					p.warn("NuGet package '%s' may depend on .NET Framework assemblies - package dependencies are currently unimplemented", id)
				end


				if nuspec:match("<dependencies>(.+)</dependencies>") then
					p.warn("NuGet package '%s' may depend on other packages - package dependencies are currently unimplemented", id)
				end

				packageAPIInfos[package] = packageAPIInfo
			end
		end

		if not packageAPIInfos[package] then
			examinePackageFromCache()
		end

		-- If we didn't find the package from the cache, use the NuGet API
		-- instead.

		if not packageAPIInfos[package] then
			if not packageSourceInfos[prj.nugetsource] then
				local packageSourceInfo = {}

				printf("Examining NuGet package source '%s'...", prj.nugetsource)
				io.flush()

				local response, err, code = http.get(prj.nugetsource)

				if err ~= "OK" then
					p.error("NuGet API error (%d)\n%s", code, err)
				end

				response, err = json.decode(response)

				if not response then
					p.error("Failed to decode NuGet API response (%s)", err)
				end

				if not response.resources then
					p.error("Failed to understand NuGet API response (no resources in response)", id)
				end

				local packageDisplayMetadataUriTemplate, catalog

				for _, resource in ipairs(response.resources) do
					if not resource["@id"] then
						p.error("Failed to understand NuGet API response (no resource['@id'])")
					end

					if not resource["@type"] then
						p.error("Failed to understand NuGet API response (no resource['@type'])")
					end

					if resource["@type"]:find("PackageDisplayMetadataUriTemplate") == 1 then
						packageDisplayMetadataUriTemplate = resource
					end

					if resource["@type"]:find("Catalog") == 1 then
						catalog = resource
					end
				end

				if not packageDisplayMetadataUriTemplate then
					p.error("Failed to understand NuGet API response (no PackageDisplayMetadataUriTemplate resource)")
				end

				if not catalog then
					if prj.nugetsource == "https://api.nuget.org/v3/index.json" then
						p.error("Failed to understand NuGet API response (no Catalog resource)")
					else
						p.error("Package source is not a NuGet gallery - non-gallery sources are currently unsupported", prj.nugetsource, prj.name)
					end
				end

				packageSourceInfo.packageDisplayMetadataUriTemplate = packageDisplayMetadataUriTemplate
				packageSourceInfo.catalog = catalog

				packageSourceInfos[prj.nugetsource] = packageSourceInfo
			end

			local packageAPIInfo = {}

			printf("Examining NuGet package '%s'...", id)
			io.flush()

			local response, err, code = http.get(packageSourceInfos[prj.nugetsource].packageDisplayMetadataUriTemplate["@id"]:gsub("{id%-lower}", id:lower()))

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
				p.error("Failed to understand NuGet API response (no pages for package '%s')", id)
			end

			local items = {}

			for _, page in ipairs(response.items) do
				if not page.items or #page.items == 0 then
					p.error("Failed to understand NuGet API response (got a page with no items for package '%s')", id)
				end

				for _, item in ipairs(page.items) do
					table.insert(items, item)
				end
			end

			local versions = {}

			for _, item in ipairs(items) do
				if not item.catalogEntry then
					p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry)", id)
				end

				if not item.catalogEntry.version then
					p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry.version)", id)
				end

				if not item.catalogEntry["@id"] then
					p.error("Failed to understand NuGet API response (subitem of package '%s' has no catalogEntry['@id'])", id)
				end

				table.insert(versions, item.catalogEntry.version)
			end

			if not table.contains(versions, version) then
				local options = table.translate(versions, function(value) return "'" .. value .. "'" end)
				options = table.concat(options, ", ")

				p.error("'%s' is not a valid version for NuGet package '%s' (options are: %s)", version, id, options)
			end

			for _, item in ipairs(items) do
				if item.catalogEntry.version == version then
					local response, err, code = http.get(item.catalogEntry["@id"])

					if err ~= "OK" then
						if code == 404 then
							p.error("NuGet package '%s' version '%s' couldn't be found in the repository even though the API reported that it exists", id, version)
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

					-- packageEntries field that lists all the files in the
					-- package. We need to look at this to figure out what
					-- DLLs to reference in the project file.

					if not response.packageEntries then
						p.error("NuGet package '%s' version '%s' has no file listing. This package might be too old to be using this API or it might be a C++ package instead of a .NET Framework package.", id, response.version)
					end

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

					if response.frameworkAssemblyGroup then
						p.warn("NuGet package '%s' may depend on .NET Framework assemblies - package dependencies are currently unimplemented", id)
					end

					if response.dependencyGroups then
						p.warn("NuGet package '%s' may depend on other packages - package dependencies are currently unimplemented", id)
					end

					break
				end
			end

			packageAPIInfos[package] = packageAPIInfo
		end

		return packageAPIInfos[package]
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


--
-- Generates the NuGet.Config file.
--

	function nuget2010.generateNuGetConfig(prj)
		if #prj.nuget == 0 then
			return
		end

		if prj.nugetsource == "https://api.nuget.org/v3/index.json" then
			return
		end

		p.w('<?xml version="1.0" encoding="utf-8"?>')
		p.push('<configuration>')
		p.push('<packageSources>')

		-- By specifying "<clear />", we ensure that only the source that we
		-- define below is used. Otherwise it would just get added to the list
		-- of package sources.

		p.x('<clear />')

		p.x('<add key="%s" value="%s" />', prj.nugetsource, prj.nugetsource)
		p.pop('</packageSources>')
		p.pop('</configuration>')
	end


--
-- nuget workspace validation
--

	function nuget2010.uniqueProjectLocationsWithNuGet(wks)
		local locations = {}
		for prj in p.workspace.eachproject(wks) do
			if not nuget2010.supportsPackageReferences(prj) then
				local function fail()
					p.error("projects '%s' and '%s' cannot have the same location when using NuGet with different packages (packages.config conflict)", locations[prj.location].name, prj.name)
				end

				if locations[prj.location] and #locations[prj.location].nuget > 0 and #prj.nuget > 0 then
					if #locations[prj.location].nuget ~= #prj.nuget then
						fail()
					end

					for i, package in ipairs(locations[prj.location].nuget) do
						if prj.nuget[i] ~= package then
							fail()
						end
					end
				end
				locations[prj.location] = prj
			end
		end
	end

	p.override(p.validation.elements, "workspace", function (oldfn, wks)
		local t = oldfn(wks)
		table.insert(t, nuget2010.uniqueProjectLocationsWithNuGet)
		return t
	end)

--
-- nuget project validation
--

	function nuget2010.NuGetHasHTTP(prj)
		if not http and #prj.nuget > 0 and not nuget2010.supportsPackageReferences(prj) then
			p.error("Premake was compiled with --curl-src=none, but Curl is required for NuGet support (project '%s' is referencing NuGet packages)", prj.name)
		end
	end

	function nuget2010.NuGetPackageStrings(prj)
		for _, package in ipairs(prj.nuget) do
			local components = package:explode(":")

			if #components ~= 2 or #components[1] == 0 or #components[2] == 0 then
				p.error("NuGet package '%s' in project '%s' is invalid - please give packages in the format 'id:version', e.g. 'NUnit:3.6.1'", package, prj.name)
			end
		end
	end

	p.override(p.validation.elements, "project", function (oldfn, prj)
		local t = oldfn(prj)
		table.insert(t, nuget2010.NuGetHasHTTP)
		table.insert(t, nuget2010.NuGetPackageStrings)
		return t
	end)


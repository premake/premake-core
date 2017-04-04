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

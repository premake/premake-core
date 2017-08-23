--
-- moduledownloader.lua
-- Downloads a module from a package server
-- Copyright (c) 2002-2017 Jason Perkins and the Premake project
--

---
-- Downloads a module from a package server
--
-- @param modname
--    The name of the module to download.
-- @param versions
--    An optional version criteria string; see premake.checkVersion()
--    for more information on the format.
-- @return
--    If successful, the module was downloaded into the .modules folder.
---

	function premake.downloadModule(modname, versions)
		if http == nil then
			return false
		end

		-- get current user.
		local user = 'UNKNOWN'
		if os.ishost('windows') then
			user = os.getenv('USERNAME') or user
		else
			user = os.getenv('LOGNAME') or user
		end

		-- what server to ask?
		local server = package.server or 'http://packagesrv.com';

		-- get the link to the module?
		local url = 'api/v1/module/' .. http.escapeUrlParam(modname)
		if versions then
			url = url .. '/' .. http.escapeUrlParam(versions)
		end
		local content, result_str, response_code = http.get(server .. '/' .. url)
		if content then
			url = content
		else
			-- no content, module doesn't exist.
			return false
		end

		-- Download the module.
		local location = '.modules/' .. modname
		local destination = location .. '/temp.zip'

		os.mkdir(location)
		local result_str, response_code = http.download(url, destination, {
			headers  = {'X-Premake-User: ' .. user},
			progress = iif(_OPTIONS.verbose, http.reportProgress, nil)
		})

		if result_str ~= 'OK' then
			premake.error('Download of %s failed (%d)\n%s', url, response_code, result_str)
		end

		-- Unzip the module, and delete the temporary zip file.
		verbosef(' UNZIP   : %s', destination)
		zip.extract(destination, location)
		os.remove(destination)
		return true;
	end

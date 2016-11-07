--
-- moduledownloader.lua
-- Downloads a module from a package server
-- Copyright (c) 2002-2016 Jason Perkins and the Premake project
--


---
-- progress bar.
--
	local function _http_progress(total, current)
		local width = 78
		local progress = math.floor(current * width / total)

		if progress == width then
			io.write(string.rep(' ', width + 2) .. '\r')
		else
			io.write('[' .. string.rep('=', progress) .. string.rep(' ', width - progress) .. ']\r')
		end
	end

---
-- escape parameters in a url.
--
	local function escape_url_param(param)
		local url_encodings = {
			[' '] = '%%20',
			['!'] = '%%21',
			['"'] = '%%22',
			['#'] = '%%23',
			['$'] = '%%24',
			['&'] = '%%26',
			['\''] = '%%27',
			['('] = '%%28',
			[')'] = '%%29',
			['*'] = '%%2A',
			['+'] = '%%2B',
			['-'] = '%%2D',
			['.'] = '%%2E',
			['/'] = '%%2F',
			[':'] = '%%3A',
			[';'] = '%%3B',
			['<'] = '%%3C',
			['='] = '%%3D',
			['>'] = '%%3E',
			['?'] = '%%3F',
			['@'] = '%%40',
			['['] = '%%5B',
			['\\'] = '%%5C',
			[']'] = '%%5D',
			['^'] = '%%5E',
			['_'] = '%%5F',
			['`'] = '%%60'
		}

		param = param:gsub('%%', '%%25')
		for k,v in pairs(url_encodings) do
			param = param:gsub('%' .. k, v)
		end

		return param
	end


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
		if os.get() == 'windows' then
			user = os.getenv('USERNAME') or user
		else
			user = os.getenv('LOGNAME') or user
		end

		-- what server to ask?
		local server = package.server or 'http://packagesrv.com';

		-- get the link to the module?
		local url = 'api/v1/module/' .. escape_url_param(modname)
		if versions then
			url = url .. '/' .. escape_url_param(versions)
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
			progress = _http_progress
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

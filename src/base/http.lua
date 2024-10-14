--
-- http.lua
-- Additions to the http namespace.
-- Copyright (c) 2008-2014 Jess Perkins and the Premake project
--

	if http == nil then
		return
	end

---
-- Simple progress bar on stdout for curl downloads.
---

	function http.reportProgress(total, current)
		local width = 70
		local progress = math.floor(current * width / total)

		if progress == width then
			io.write(string.rep(' ', width + 2) .. '\r')
		else
			io.write('[' .. string.rep('=', progress) .. string.rep(' ', width - progress) .. ']\r')
		end
	end


---
-- Correctly escape parameters for use in a url.
---

	function http.escapeUrlParam(param)
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

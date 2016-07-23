---
-- autoconf.lua
-- Copyright (c) 2002-2016 Jason Perkins and the Premake project
---

local p = premake
p.autoconf = {}
p.autoconf.cache = {}


---
-- Check for a particular include file.
--
-- @cfg      : Current config.
-- @variable : The variable to store the result, such as 'HAVE_STDINT_H'.
-- @filename : The header file to check for.
---

	function check_include(cfg, variable, filename)
		local res = p.autoconf.cache_compile(cfg, variable, function ()
			p.outln('#include <' .. filename .. '>')
			p.outln('int main(void) { return 0; }')
		end)

		if res.succeeded then
			p.autoconf.set_value(cfg, variable, 1)
		end
	end



---
-- Check for size of a particular type.
--
-- @cfg      : Current config.
-- @variable : The variable to use, such as 'SIZEOF_SIZE_T', this method will also add "'HAVE_' .. variable".
-- @type     : The type to check.
-- @headers  : An optional array of header files to include.
---

	function check_type_size(cfg, variable, type, headers)
		check_include(cfg, 'HAVE_SYS_TYPES_H', 'sys/types.h')
		check_include(cfg, 'HAVE_STDINT_H', 'stdint.h')
		check_include(cfg, 'HAVE_STDDEF_H', 'stddef.h')

		local res = p.autoconf.cache_compile(cfg, variable .. cfg.architecture,
			function ()
				if cfg.autoconf['HAVE_SYS_TYPES_H'] then
					p.outln('#include <sys/types.h>')
				end

				if cfg.autoconf['HAVE_STDINT_H'] then
					p.outln('#include <stdint.h>')
				end

				if cfg.autoconf['HAVE_STDDEF_H'] then
					p.outln('#include <stddef.h>')
				end

				p.autoconf.include_headers(headers)
				p.outln("")
				p.outln("#define SIZE (sizeof(" .. type .. "))")
				p.outln("char info_size[] =  {'I', 'N', 'F', 'O', ':', 's','i','z','e','[',")
				p.outln("  ('0' + ((SIZE / 10000)%10)),")
				p.outln("  ('0' + ((SIZE / 1000)%10)),")
				p.outln("  ('0' + ((SIZE / 100)%10)),")
				p.outln("  ('0' + ((SIZE / 10)%10)),")
				p.outln("  ('0' +  (SIZE     %10)),")
				p.outln("  ']', '\\0'};")
				p.outln("")
				p.outln("int main(int argc, char *argv[]) {")
				p.outln("  int require = 0;")
				p.outln("  require += info_size[argc];")
				p.outln("  (void)argv;")
				p.outln("  return require;")
				p.outln("}")
			end,
			function (e, binary)
				-- if the compile step succeeded, we should have a binary with 'INFO:size[*****]'
				-- somewhere in there.
				local content = io.readfile(binary)
				if content then
					local size = string.find(content, 'INFO:size')
					if size then
						e.size = tonumber(string.sub(content, size+10, size+14))
					end
				end
			end
		)

		if res.size then
			p.autoconf.set_value(cfg, 'HAVE_' .. variable, 1)
			p.autoconf.set_value(cfg, variable, res.size)
		end
	end



---
-- Check if the given struct or class has the specified member variable
--
-- @cfg      : current config.
-- @variable : variable to store the result.
-- @type     : the name of the struct or class you are interested in
-- @member   : the member which existence you want to check
-- @headers  : an optional array of header files to include.
---

	function check_struct_has_member(cfg, variable, type, member, headers)
		local res = p.autoconf.cache_compile(cfg, variable, function ()
			p.autoconf.include_headers(headers)
			p.outln('int main(void) {')
			p.outln('  (void)sizeof(((' .. type .. '*)0)->' .. member ..');')
			p.outln('  return 0;')
			p.outln('}')
		end)

		if res.succeeded then
			p.autoconf.set_value(cfg, variable, 1)
		end
	end



---
-- Check if a symbol exists as a function, variable, or macro
--
-- @cfg      : current config.
-- @variable : variable to store the result.
-- @symbol   : The symbol to check for.
-- @headers  : an optional array of header files to include.
---

	function check_symbol_exists(cfg, variable, symbol, headers)
		local h = headers
		local res = p.autoconf.cache_compile(cfg, variable, function ()
			p.autoconf.include_headers(headers)
			p.outln('int main(int argc, char** argv) {')
			p.outln('  (void)argv;')
			p.outln('#ifndef ' .. symbol)
			p.outln('  return ((int*)(&' .. symbol .. '))[argc];')
			p.outln('#else')
			p.outln('  (void)argc;')
			p.outln('  return 0;')
			p.outln('#endif')
			p.outln('}')
		end)

		if res.succeeded then
			p.autoconf.set_value(cfg, variable, 1)
		end
	end


---
-- try compiling a piece of c/c++
---

	function p.autoconf.try_compile(cfg, cpp)
		local ts = p.autoconf.toolset(cfg)
		if ts then
			return ts.try_compile(cfg, cpp)
		else
			p.warnOnce('autoconf', 'no toolset found, autoconf always failing.')
		end
	end


---
-- cache the result of a compile.
---

	function p.autoconf.cache_compile(cfg, entry, func, post)
		if not p.autoconf.cache[entry] then
			local cpp = p.capture(func)
			local res = p.autoconf.try_compile(cfg, cpp)
			if res then
				local e = { succeeded = true }
				if post then
					post(e, res)
				end
				p.autoconf.cache[entry] = e
			else
				p.autoconf.cache[entry] = { }
			end
		end
		return p.autoconf.cache[entry]
	end



---
-- get the current configured toolset, or the default.
---

	function p.autoconf.toolset(cfg)
		local ts = p.config.toolset(cfg)
		if not ts then
			local tools = {
				['vs2010']   = p.tools.msc,
				['vs2012']   = p.tools.msc,
				['vs2013']   = p.tools.msc,
				['vs2015']   = p.tools.msc,
				['gmake']    = p.tools.gcc,
				['codelite'] = p.tools.gcc,
				['xcode']    = p.tools.clang,
			}
			ts = tools[_ACTION]
		end
		return ts
	end



---
-- store the value of the variable in the configuration
---

	function p.autoconf.set_value(cfg, variable, value)
		cfg.autoconf = cfg.autoconf or {}
		cfg.autoconf[variable] = value
	end



---
-- write the cfg.autoconf table to the file
---

	function p.autoconf.writefile(cfg, filename)
		if cfg.autoconf then
			local file = io.open(filename, "w+")
			for variable, value in pairs(cfg.autoconf) do
				file:write('#define ' .. variable .. ' ' .. tostring(value) .. (_eol or '\n'))
			end
			file:close()
		end
	end


---
-- Utility method to add a table of headers.
---

	function p.autoconf.include_headers(headers)
		if headers ~= nil then
			if type(headers) == "table" then
				for _, v in ipairs(headers) do
					p.outln('#include <' .. v .. '>')
				end
			else
				p.outln('#include <' .. headers .. '>')
			end
		end
	end


---
-- Utility method called by the action.call
---
	function p.autoconf.execute(prj, cfg)
		if cfg and cfg.autoconfigure then

			if not cfg.autoconfdir then
				cfg.autoconfdir = path.join(prj.location, "autoconf");
			end
			if not os.isdir(cfg.autoconfdir) then
				os.mkdir(cfg.autoconfdir);
			end

			verbosef('Running auto config steps for "%s/%s".', prj.name, cfg.name)
			for file, func in pairs(cfg.autoconfigure) do
				func(cfg)

				local name = p.detoken.expand(file, cfg.environ, field, cfg._basedir)
				local filename = path.join(cfg._basedir, name)
				p.autoconf.writefile(cfg, filename)
			end
		end
	end

--
-- tests/test_lua.lua
-- Automated test suite for Lua base functions.
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

if not _UTF8_ENABLED then -- disable if UTF-8 is not enabled
	return
end

	local suite = test.declare("lua_unicode")

    local real_io_open = io.open


--
-- Helpers
--

local tmpname = function()
    local p = os.tmpname()
    if p:startswith("\\") then
        p = "." .. p
    end
    os.remove(p) -- just needed on POSIX
    return p
end

--
-- loadfile with Unicode path
--

function suite.loadfile_UnicodeFilename()
	local p = tmpname()
	p = p .. "_café.lua"
	local f = assert(real_io_open(p, "w"))
	f:write("return 42\n")
	f:close()
	local fn = assert(loadfile(p))
	local ok, value = pcall(fn)
	os.remove(p)
	test.istrue(ok)
	test.isequal(42, value)
end


--
-- io.open with Unicode filenames
--

function suite.io_open_WriteReadUnicodeFilename()
	local p = tmpname()
	os.remove(p)
	p = p .. "_café"
	local f = assert(real_io_open(p, "w"))
	f:write("hello unicode")
	f:close()
	f = assert(real_io_open(p, "r"))
	local content = f:read("*a")
	f:close()
	os.remove(p)
	test.isequal("hello unicode", content)
end

function suite.io_open_AppendModeUnicodeFilename()
	local p = tmpname()
	p = p .. "_données"
	local f = assert(real_io_open(p, "w"))
	f:write("first")
	f:close()
	f = assert(real_io_open(p, "a"))
	f:write("second")
	f:close()
	f = assert(real_io_open(p, "r"))
	local content = f:read("*a")
	f:close()
	os.remove(p)
	test.isequal("firstsecond", content)
end

function suite.io_open_ReturnsNil_OnMissingUnicodeFile()
	local f, err = real_io_open(tmpname() .. "_noëxist", "r")
	test.isnil(f)
	test.isequal("string", type(err))
end


--
-- io.popen
--

function suite.io_popen_ReadsOutput()
	local f = io.popen("echo hello", "r")
	test.istrue(f ~= nil)
	if f then
		local content = f:read("*l")
		f:close()
		test.istrue(content ~= nil and content:find("hello") ~= nil)
	end
end


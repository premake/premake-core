---
-- tests/base/test_os_unicode.lua
-- Automated test suite for the new OS functions.
-- Copyright (c) 2026-2026 Jess Perkins and the Premake project
---

if not _UTF8_ENABLED then -- disable if UTF-8 is not enabled
	return
end

    local suite = test.declare("base_os_unicode")

	local cwd

	function suite.setup()
		cwd = os.getcwd()
		os.chdir(_TESTS_DIR)
	end

	function suite.teardown()
		os.chdir(cwd)
	end


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

local tmpfile = function()
    local p = tmpname()
    if os.ishost("windows") then
        os.execute("type nul >" .. p)
    else
        os.execute("touch " .. p)
    end
    return p
end


--
-- os.remove() Unicode tests.
--

	function suite.remove_ReturnsTrue_OnUnicodeFile()
		local p = tmpname() .. "_café"
		os.touchfile(p)
		local ok, err = os.remove(p)
		test.isequal(true, ok)
		test.isnil(err)
	end

	function suite.remove_ReturnsError_OnNonExistingUnicodePath()
		local p = tmpname() .. "_café"
		local ok, err, exitcode = os.remove(p)
		test.isnil(ok)
		test.isequal("string", type(err))
		test.isequal("number", type(exitcode))
		test.istrue(0 ~= exitcode)
		if os.ishost("windows") then
			test.istrue(err:find(p, 1, true) ~= nil)
		end
	end


--
-- os.rename() tests.
--

	function suite.rename_ReturnsTrue_OnValidRename()
		local src = tmpfile()
		local dst = tmpname()
		local ok, err = os.rename(src, dst)
		test.isequal(true, ok)
		test.isnil(err)
		os.remove(dst)
	end

	function suite.rename_ReturnsError_OnNonExistingSource()
		local src = tmpname() .. "_café"
		local ok, err = os.rename(src, tmpname())
		test.isnil(ok)
		test.isequal("string", type(err))
		if os.ishost("windows") then
			test.istrue(err:find(src, 1, true) ~= nil)
		end
	end

	function suite.rename_ReturnsTrue_OnUnicodeSrc()
		local src = tmpname() .. "_café"
		local dst = tmpname()
		os.touchfile(src)
		local ok, err = os.rename(src, dst)
		test.isequal(true, ok)
		test.isnil(err)
		os.remove(dst)
	end

	function suite.rename_ReturnsTrue_OnUnicodeDst()
		local src = tmpfile()
		local dst = tmpname() .. "_naïve"
		local ok, err = os.rename(src, dst)
		test.isequal(true, ok)
		test.isnil(err)
		os.remove(dst)
	end

	function suite.rename_ReturnsTrue_OnUnicodeSrcAndDst()
		local src = tmpname() .. "_café"
		local dst = tmpname() .. "_naïve"
		os.touchfile(src)
		local ok, err = os.rename(src, dst)
		test.isequal(true, ok)
		test.isnil(err)
		os.remove(dst)
	end


--
-- os.getenv() tests.
--

	function suite.getenv_ReturnsValue_ForExistingVar()
		local val = os.getenv("PATH")
		test.istrue(val ~= nil)
		test.isequal("string", type(val))
	end

	function suite.getenv_ReturnsNil_ForNonExistingVar()
		local val = os.getenv("PREMAKE_NONEXISTENT_VARIABLE_12345")
		test.isnil(val)
	end


--
-- os.tmpname() tests.
--

	function suite.tmpname_ReturnsString()
		local p = os.tmpname()
		test.isequal("string", type(p))
		test.istrue(#p > 0)
		os.remove(p)
	end

	function suite.tmpname_ReturnsUniquePaths()
		local a = os.tmpname()
		local b = os.tmpname()
		test.istrue(a ~= b)
		os.remove(a)
		os.remove(b)
	end


--
-- os.mkdir() Unicode tests.
--

	function suite.mkdir_CreatesUnicodeDir()
		local p = tmpname() .. "_café_dir"
		local ok = os.mkdir(p)
		test.istrue(ok)
		test.istrue(os.isdir(p))
		os.rmdir(p)
	end

	function suite.mkdir_CreatesNestedUnicodeDir()
		local base = tmpname() .. "_données"
		local nested = base .. "/inner"
		local ok = os.mkdir(nested)
		test.istrue(ok)
		test.istrue(os.isdir(nested))
		os.rmdir(nested)
		os.rmdir(base)
	end


--
-- os.rmdir() Unicode tests.
--

	function suite.rmdir_ReturnsTrue_OnUnicodeDirectory()
		local p = tmpname() .. "_café_dir"
		os.mkdir(p)
		local ok, err = os.rmdir(p)
		test.isequal(true, ok)
		test.isnil(err)
	end

	function suite.rmdir_ReturnsError_OnNonExistingUnicodePath()
		local ok, err = os.rmdir(tmpname() .. "_café_dir")
		test.isnil(ok)
		test.isequal("string", type(err))
	end


--
-- os.isdir() Unicode tests.
--

	function suite.isdir_ReturnsTrue_OnUnicodeDir()
		local p = tmpname() .. "_café_dir"
		os.mkdir(p)
		test.istrue(os.isdir(p))
		os.rmdir(p)
	end

	function suite.isdir_ReturnsFalse_OnNonExistingUnicodePath()
		test.isfalse(os.isdir(tmpname() .. "_café_dir"))
	end

	function suite.isdir_ReturnsFalse_OnUnicodeFile()
		local p = tmpname() .. "_café"
		os.touchfile(p)
		test.isfalse(os.isdir(p))
		os.remove(p)
	end


--
-- os.isfile() Unicode tests.
--

	function suite.isfile_ReturnsTrue_OnUnicodeFile()
		local p = tmpname() .. "_café"
		os.touchfile(p)
		test.istrue(os.isfile(p))
		os.remove(p)
	end

	function suite.isfile_ReturnsFalse_OnNonExistingUnicodeFile()
		test.isfalse(os.isfile(tmpname() .. "_café"))
	end

	function suite.isfile_ReturnsFalse_OnUnicodeDir()
		local p = tmpname() .. "_café_dir"
		os.mkdir(p)
		test.isfalse(os.isfile(p))
		os.rmdir(p)
	end


--
-- os.stat() Unicode tests.
--

	function suite.stat_ReturnsTable_OnUnicodeFile()
		local p = tmpname() .. "_café"
		os.touchfile(p)
		local info = os.stat(p)
		test.istrue(info ~= nil)
		test.isequal("number", type(info.mtime))
		test.isequal("number", type(info.size))
		os.remove(p)
	end

	function suite.stat_ReturnsNil_OnNonExistingUnicodePath()
		local info, err = os.stat(tmpname() .. "_café")
		test.isnil(info)
		test.isequal("string", type(err))
	end


--
-- os.touchfile() Unicode tests.
--

	function suite.touchfile_CreatesNewUnicodeFile()
		local p = tmpname() .. "_café"
		local result = os.touchfile(p)
		test.isequal(1, result)
		test.istrue(os.isfile(p))
		os.remove(p)
	end

	function suite.touchfile_UpdatesExistingUnicodeFile()
		local p = tmpname() .. "_café"
		os.touchfile(p)
		local result = os.touchfile(p)
		test.isequal(0, result)
		os.remove(p)
	end


--
-- os.copyfile() Unicode tests.
--

	function suite.copyfile_CopiesFromUnicodePath()
		local src = tmpname() .. "_café"
		local dst = tmpname()
		os.touchfile(src)
		local ok = os.copyfile(src, dst)
		test.istrue(ok)
		test.istrue(os.isfile(dst))
		os.remove(src)
		os.remove(dst)
	end

	function suite.copyfile_CopiesToUnicodePath()
		local src = tmpfile()
		local dst = tmpname() .. "_naïve"
		local ok = os.copyfile(src, dst)
		test.istrue(ok)
		test.istrue(os.isfile(dst))
		os.remove(src)
		os.remove(dst)
	end

	function suite.copyfile_CopiesBetweenUnicodePaths()
		local src = tmpname() .. "_café"
		local dst = tmpname() .. "_naïve"
		os.touchfile(src)
		local ok = os.copyfile(src, dst)
		test.istrue(ok)
		test.istrue(os.isfile(dst))
		os.remove(src)
		os.remove(dst)
	end

	function suite.copyfile_ReturnsError_OnNonExistingSource()
		local src = tmpname() .. "_café"
		local dst = tmpname() .. "_naïve"
		local ok, err = os.copyfile(src, dst)
		test.isnil(ok)
		test.isequal("string", type(err))
		if os.ishost("windows") then
			test.istrue(err:find(dst, 1, true) ~= nil)
		end
	end


--
-- os.comparefiles() Unicode tests.
--

	function suite.comparefiles_ReturnsTrue_OnIdenticalUnicodeFiles()
		local a = tmpname() .. "_café"
		local b = tmpname() .. "_naïve"
		os.touchfile(a)
		os.copyfile(a, b)
		local ok = os.comparefiles(a, b)
		test.istrue(ok)
		os.remove(a)
		os.remove(b)
	end

	function suite.comparefiles_ReturnsNil_OnMissingUnicodeFile()
		local a = tmpname() .. "_café"
		os.touchfile(a)
		local ok, err = os.comparefiles(a, tmpname() .. "_noëxist")
		test.isnil(ok)
		test.isequal("string", type(err))
		os.remove(a)
	end


--
-- os.chdir() / os.getcwd() Unicode tests.
--

	function suite.chdir_WorksWithUnicodePath()
		local dir = tmpname() .. "_café_dir"
		os.mkdir(dir)
		local saved = os.getcwd()
		local ok = os.chdir(dir)
		test.istrue(ok)
		os.chdir(saved)
		os.rmdir(dir)
	end

	function suite.getcwd_ReturnsUnicodePath()
		local dir = tmpname() .. "_café_dir"
		os.mkdir(dir)
		local saved = os.getcwd()
		os.chdir(dir)
		local result = os.getcwd()
		test.istrue(result ~= nil)
		test.istrue(result:find("café_dir") ~= nil)
		os.chdir(saved)
		os.rmdir(dir)
	end


--
-- os.matchfiles() / os.matchdirs() Unicode tests.
--

	function suite.matchfiles_FindsFilesInUnicodeDir()
		local dir = tmpname() .. "_café_dir"
		os.mkdir(dir)
		os.touchfile(dir .. "/testfile.txt")
		local result = os.matchfiles(dir .. "/*")
		test.istrue(#result > 0)
		os.remove(dir .. "/testfile.txt")
		os.rmdir(dir)
	end

	function suite.matchdirs_FindsUnicodeDir()
		local parent = tmpname() .. "_parent"
		local child = parent .. "/café_sub"
		os.mkdir(child)
		local result = os.matchdirs(parent .. "/*")
		test.istrue(#result > 0)
		os.rmdir(child)
		os.rmdir(parent)
	end

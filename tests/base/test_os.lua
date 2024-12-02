---
-- tests/base/test_os.lua
-- Automated test suite for the new OS functions.
-- Copyright (c) 2008-2017 Jess Perkins and the Premake project
---

	local suite = test.declare("base_os")

	local cwd

	function suite.setup()
		cwd = os.getcwd()
		os.chdir(_TESTS_DIR)
	end

	function suite.teardown()
		os.chdir(cwd)
	end


--
-- os.findlib() tests
--

	function suite.findlib_FindSystemLib()
		if os.istarget("macosx") then
			-- macOS no longer stores system libraries on filesystem; see
			-- https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-release-notes
		elseif os.istarget("windows") then
			test.istrue(os.findlib("user32"))
		elseif os.istarget("haiku") then
			test.istrue(os.findlib("root"))
		else
			test.istrue(os.findlib("m"))
		end
	end

	function suite.findlib_FailsOnBadLibName()
		test.isfalse(os.findlib("NoSuchLibraryAsThisOneHere"))
	end

	function suite.findheader_stdheaders()
		if not os.istarget("windows") and not os.istarget("macosx") then
			test.istrue(os.findheader("stdlib.h"))
		end
	end

	function suite.findheader_failure()
		test.isfalse(os.findheader("Knights/who/say/Ni.hpp"))
	end


--
-- os.isfile() tests
--

	function suite.isfile_ReturnsTrue_OnExistingFile()
		test.istrue(os.isfile("_tests.lua"))
	end

	function suite.isfile_ReturnsFalse_OnNonexistantFile()
		test.isfalse(os.isfile("no_such_file.lua"))
	end

--
-- os.linkdir() and os.linkfile() tests
--

	function suite.linkdir()
		test.istrue(os.linkdir("folder/subfolder", "folder/subfolder2"))
		test.istrue(os.islink("folder/subfolder2"))
		os.rmdir("folder/subfolder2")
	end

	function suite.linkfile()
		test.istrue(os.linkfile("folder/ok.lua", "folder/ok2.lua"))
		test.istrue(os.islink("folder/ok2.lua"))
		os.remove("folder/ok2.lua")
	end



--
-- os.matchdirs() tests
--

	function suite.matchdirs_skipsDottedDirs()
		local result = os.matchdirs("*")
		test.isfalse(table.contains(result, ".."))
	end



--
-- os.matchfiles() tests
--

	function suite.matchfiles_OnNonRecursive()
		local result = os.matchfiles("*.lua")
		test.istrue(table.contains(result, "_tests.lua"))
		test.isfalse(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_Recursive()
		local result = os.matchfiles("**.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_SkipsDotDirs_OnRecursive()
		local result = os.matchfiles("**.lua")
		test.isfalse(table.contains(result, ".svn/text-base/testfx.lua.svn-base"))
	end

	function suite.matchfiles_OnSubfolderMatch()
		local result = os.matchfiles("**/subfolder/*")
		test.istrue(table.contains(result, "folder/subfolder/hello.txt"))
		test.isfalse(table.contains(result, "premake4.lua"))
	end

	function suite.matchfiles_OnDotSlashPrefix()
		local result = os.matchfiles("./**.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_OnImplicitEndOfString()
		local result = os.matchfiles("folder/*.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
		test.isfalse(table.contains(result, "folder/ok.lua.2"))
	end

	function suite.matchfiles_OnLeadingDotSlashWithPath()
		local result = os.matchfiles("./folder/*.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_OnDottedFile()
		local result = os.matchfiles("base/.*")
		test.istrue(table.contains(result, "base/.testDotFile"))
	end

	function suite.matchfiles_onComboSearch()
		local result = os.matchfiles("folder/**/*.txt")
		test.istrue(table.contains(result, "folder/subfolder/hello.txt"))
	end

	function suite.matchfiles_onSymbolicLink()
		if os.istarget("macosx")
			or os.istarget("linux")
			or os.istarget("solaris")
			or os.istarget("bsd")
		then
			os.execute("cd folder && ln -s subfolder symlinkfolder && cd ..")
			local result = os.matchfiles("folder/**/*.txt")
			os.execute("rm folder/symlinkfolder")
			premake.modules.self_test.print(table.tostring(result))
			test.istrue(table.contains(result, "folder/symlinkfolder/hello.txt"))
		end
	end


--
-- os.pathsearch() tests
--

	function suite.pathsearch_ReturnsNil_OnNotFound()
		test.istrue(os.pathsearch("nosuchfile", "aaa;bbb;ccc") == nil)
	end

	function suite.pathsearch_ReturnsPath_OnFound()
		test.isequal(_TESTS_DIR, os.pathsearch("_tests.lua", _TESTS_DIR))
	end

	function suite.pathsearch_FindsFile_OnComplexPath()
		test.isequal(_TESTS_DIR, os.pathsearch("_tests.lua", "aaa;" .. _TESTS_DIR .. ";bbb"))
	end

	function suite.pathsearch_NilPathsAllowed()
		test.isequal(_TESTS_DIR, os.pathsearch("_tests.lua", nil, _TESTS_DIR, nil))
	end


--
-- os.outputof() tests
--

	-- Check if outputof returns the command exit code
	-- in addition of the command output
	function suite.outputof_commandExitCode()
		if os.istarget("macosx")
			or os.istarget("linux")
			or os.istarget("solaris")
			or os.istarget("bsd")
		then
			-- Assumes 'true' and 'false' commands exist
			-- which should be the case on all *nix platforms
			for cmd, exitcode in pairs ({
				["true"] = 0,
				["false"] = 1
			})
			do
				local o, e = os.outputof(cmd)
				test.isequal(e, exitcode)
			end
		end
	end

	-- Check outputof content
	function suite.outputof_streams_output()
		if (os.istarget("macosx")
			or os.istarget("linux")
			or os.istarget("solaris")
			or os.istarget("bsd"))
			and os.isdir (_TESTS_DIR)
		then
			local ob, e = os.outputof ("ls " .. _TESTS_DIR .. "/base")
			local oo, e = os.outputof ("ls " .. _TESTS_DIR .. "/base", "output")
			test.isequal (oo, ob)
			local s, e = string.find (oo, "test_os.lua")
			test.istrue(s ~= nil)

			local o, e = os.outputof ("ls " .. cwd .. "/base", "error")
			test.istrue(o == nil or #o == 0)
		end
	end

--
-- os.translateCommand() tests
--

	function suite.translateCommand_onNoToken()
		test.isequal("cp a b", os.translateCommands("cp a b"))
	end

	function suite.translateCommand_callsProcessor()
		os.commandTokens.test = {
			copy = function(value) return "test " .. value end
		}
		test.isequal("test a b", os.translateCommands("{COPY} a b", "test"))
	end

	function suite.translateCommand_callsProcessor_multipleTokens()
		os.commandTokens.test = {
			copy = function(value) return "test " .. value end
		}
		test.isequal("test a b; test c d; test e f;", os.translateCommands("{COPY} a b; {COPY} c d; {COPY} e f;", "test"))
	end

--
-- os.translateCommand() windows COPY tests
--

	function suite.translateCommand_windowsCopyNoDst()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a > nul) ELSE (xcopy /Q /Y /I a > nul)', os.translateCommands('{COPY} a', "windows"))
	end

	function suite.translateCommand_windowsCopyNoDst_ExtraSpace()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a > nul) ELSE (xcopy /Q /Y /I a > nul)', os.translateCommands('{COPY} a ', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotes()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a b > nul) ELSE (xcopy /Q /Y /I a b > nul)', os.translateCommands('{COPY} a b', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotes_ExtraSpace()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a b > nul) ELSE (xcopy /Q /Y /I a b > nul)', os.translateCommands('{COPY} a b ', "windows"))
	end

	function suite.translateCommand_windowsCopyQuotes()
		test.isequal('IF EXIST "a a"\\ (xcopy /Q /E /Y /I "a a" "b" > nul) ELSE (xcopy /Q /Y /I "a a" "b" > nul)', os.translateCommands('{COPY} "a a" "b"', "windows"))
	end

	function suite.translateCommand_windowsCopyQuotes_ExtraSpace()
		test.isequal('IF EXIST "a a"\\ (xcopy /Q /E /Y /I "a a" "b" > nul) ELSE (xcopy /Q /Y /I "a a" "b" > nul)', os.translateCommands('{COPY} "a a" "b" ', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotesDst()
		test.isequal('IF EXIST "a a"\\ (xcopy /Q /E /Y /I "a a" b > nul) ELSE (xcopy /Q /Y /I "a a" b > nul)', os.translateCommands('{COPY} "a a" b', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotesDst_ExtraSpace()
		test.isequal('IF EXIST "a a"\\ (xcopy /Q /E /Y /I "a a" b > nul) ELSE (xcopy /Q /Y /I "a a" b > nul)', os.translateCommands('{COPY} "a a" b ', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotesSrc()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a "b" > nul) ELSE (xcopy /Q /Y /I a "b" > nul)', os.translateCommands('{COPY} a "b"', "windows"))
	end

	function suite.translateCommand_windowsCopyNoQuotesSrc_ExtraSpace()
		test.isequal('IF EXIST a\\ (xcopy /Q /E /Y /I a "b" > nul) ELSE (xcopy /Q /Y /I a "b" > nul)', os.translateCommands('{COPY} a "b" ', "windows"))
	end

--
-- os.translateCommand() LINKDIR/LINKFILE tests
--
	function suite.translateCommand_windowsLinkDir()
		test.isequal('mklink /d a b', os.translateCommands('{LINKDIR} a b', "windows"))
	end

	function suite.translateCommand_windowsLinkFile()
		test.isequal('mklink a b', os.translateCommands('{LINKFILE} a b', "windows"))
	end

	function suite.translateCommand_posixLinkDir()
		test.isequal('ln -s a b', os.translateCommands('{LINKDIR} a b', "posix"))
	end

	function suite.translateCommand_posixLinkFile()
		test.isequal('ln -s a b', os.translateCommands('{LINKFILE} a b', "posix"))
	end
--
-- os.getWindowsRegistry windows tests
--
	function suite.getreg_nonExistentValue()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKCU:Should\\Not\\Exist\\At\\All")
			test.isequal(nil, x)
		end
	end

	function suite.getreg_nonExistentDefaultValue()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKCU:Should\\Not\\Exist\\At\\All\\")
			test.isequal(nil, x)
		end
	end

	function suite.getreg_noSeparators()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKCU:ShouldNotExistAtAll")
			test.isequal(nil, x)
		end
	end

	function suite.getreg_namedValue()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKCU:Environment\\TEMP")
			test.istrue(x ~= nil)
		end
	end

	function suite.getreg_namedValueOptSeparator()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKCU:\\Environment\\TEMP")
			test.istrue(x ~= nil)
		end
	end

	function suite.getreg_defaultValue()
		if os.ishost("windows") then
			local x = os.getWindowsRegistry("HKLM:SYSTEM\\CurrentControlSet\\Control\\SafeBoot\\Minimal\\AppInfo\\")
			test.isequal("Service", x)
		end
	end


--
-- os.listWindowsRegistry windows tests
--
	function suite.listreg_nonExistentKey()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:Should\\Not\\Exist\\At\\All")
			test.isequal(nil, x)
		end
	end

	function suite.listreg_nonExistentKeyTrailingBackslash()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:Should\\Not\\Exist\\At\\All\\")
			test.isequal(nil, x)
		end
	end

	function suite.listreg_noSeparators()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:ShouldNotExistAtAll")
			test.isequal(nil, x)
		end
	end

	function suite.listreg_noSeparatorExistingPath()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:Environment")
			test.istrue(x ~= nil and x["TEMP"] ~= nil)
		end
	end

	function suite.listreg_optSeparators()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:\\Environment\\")
			test.istrue(x ~= nil and x["TEMP"] ~= nil)
		end
	end

	function suite.listreg_keyDefaultValueAndStringValueFormat()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKLM:SYSTEM\\CurrentControlSet\\Control\\SafeBoot\\Minimal\\AppInfo")
			test.isequal(x[""]["value"], "Service")
			test.isequal(x[""]["type"], "REG_SZ")
		end
	end

	function suite.listreg_numericValueFormat()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKCU:Console")
			test.isequal(type(x["FullScreen"]["value"]), "number")
			test.isequal(x["FullScreen"]["type"], "REG_DWORD")
		end
	end

	function suite.listreg_subkeyFormat()
		if os.ishost("windows") then
			local x = os.listWindowsRegistry("HKLM:")
			test.isequal(type(x["SOFTWARE"]), "table")
			test.isequal(next(x["SOFTWARE"]), nil)
		end
	end

--
-- os.getversion tests.
--

	function suite.getversion()
		local version = os.getversion();
		test.istrue(version ~= nil)
	end



--
-- os.translateCommandsAndPaths.
--

	function suite.translateCommandsAndPaths()
		test.isequal('cmdtool "../foo/path1"', os.translateCommandsAndPaths("cmdtool %[path1]", '../foo', '.', 'osx'))
	end

	function suite.translateCommandsAndPaths_PreserveSlash()
		test.isequal('cmdtool "../foo/path1/"', os.translateCommandsAndPaths("cmdtool %[path1/]", '../foo', '.', 'osx'))
	end

	function suite.translateCommandsAndPaths_MultipleTokens()
		test.isequal('cmdtool "../foo/path1" "../foo/path2/"', os.translateCommandsAndPaths("cmdtool %[path1] %[path2/]", '../foo', '.', 'osx'))
	end

	function suite.translateCommandsAndPaths_RelativePath()
		test.isequal('cmdtool "path1" "../bar/path2/"', os.translateCommandsAndPaths("cmdtool %[../foo/path1] %[path2/]", './bar', './foo', 'osx'))
	end

--
-- Helpers
--

	local tmpname = function()
		local p = os.tmpname()
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

	local tmpdir = function()
		local p = tmpname()
		os.mkdir(p)
		return p
	end


--
-- os.remove() tests.
--

	function suite.remove_ReturnsError_OnNonExistingPath()
		local ok, err, exitcode = os.remove(tmpname())
		test.isnil(ok)
		test.isequal("string", type(err))
		test.isequal("number", type(exitcode))
		test.istrue(0 ~= exitcode)
	end

	function suite.remove_ReturnsError_OnDirectory()
		local ok, err, exitcode = os.remove(tmpdir())
		test.isnil(ok)
		test.isequal("string", type(err))
		test.isequal("number", type(exitcode))
		test.istrue(0 ~= exitcode)
	end

	function suite.remove_ReturnsTrue_OnFile()
		local ok, err, exitcode = os.remove(tmpfile())
		test.isequal(true, ok)
		test.isnil(err)
		test.isnil(exitcode)
	end


--
-- os.rmdir() tests.
--

	function suite.rmdir_ReturnsError_OnNonExistingPath()
		local ok, err = os.rmdir(tmpname())
		test.isnil(ok)
		test.isequal("string", type(err))
	end

	function suite.rmdir_ReturnsError_OnFile()
		local ok, err = os.rmdir(tmpfile())
		test.isnil(ok)
		test.isequal("string", type(err))
	end

	function suite.rmdir_ReturnsTrue_OnDirectory()
		local ok, err = os.rmdir(tmpdir())
		test.isequal(true, ok)
		test.isnil(err)
	end


--
-- os.getnumcpus() tests.
--

	function suite.numcpus()
		local numcpus = os.getnumcpus()
		test.istrue(numcpus > 0)
	end


--
-- os.host() tests.
--

function suite.host()
	local host = os.host()
	test.istrue(string.len(host) > 0)

	if _COSMOPOLITAN then
		test.istrue(host ~= "cosmopolitan")
	end
end


--
-- os.hostarch() tests.
--

	function suite.hostarch()
		local arch = os.hostarch()
		test.istrue(string.len(arch) > 0)
	end


--
-- os.targetarch() tests.
--

function suite.targetarch()
	-- nil by default for backwards compatibility
	test.isequal(nil, os.targetarch())

	_TARGET_ARCH = "x64"
	test.isequal(_TARGET_ARCH, os.targetarch())

	-- --arch has priority over _TARGET_ARCH
	_OPTIONS["arch"] = "arm64"
	test.isequal(_OPTIONS["arch"], os.targetarch())
end

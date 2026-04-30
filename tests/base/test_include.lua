--
-- tests/base/test_include.lua
-- Test the include() function, for including external scripts
-- Copyright (c) 2011-2014 Jess Perkins and the Premake project
--


	local p = premake
	local suite = test.declare("include")


--
-- Setup and teardown
--

	function suite.teardown()
		-- clear the list of included files after each run
		io._includedFiles = { }
	end


--
-- Tests
--

	function suite.include_findsPremakeFile_onFolderNameOnly()
		include (_TESTS_DIR .. "/folder")
		test.isequal("ok", p.captured())
	end


	function suite.include_onExactFilename()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", p.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludes()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		include (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", p.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludesWithDifferentPaths()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		include (_TESTS_DIR .. "/../tests/folder/premake5.lua")
		test.isequal("ok", p.captured())
	end

	function suite.includeexternal_runs()
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", p.captured())
	end

	function suite.includeexternal_runsAfterInclude()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("okok", p.captured())
	end

	function suite.includeexternal_runsTwiceAfterInclude()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("okokok", p.captured())
	end


--
-- Tests for local-first search priority (fix for issue #1783):
-- Local files must be found before identically-named files in premake.path.
--

	-- Helper: run fn with CWD and premake.path temporarily overridden.
	local function withLocalPriority(cwd, searchPath, fn)
		local savedPath = premake.path
		local savedCwd  = os.getcwd()
		premake.path = searchPath
		os.chdir(cwd)
		local ok, err = pcall(fn)
		os.chdir(savedCwd)
		premake.path = savedPath
		if not ok then error(err, 2) end
	end

	-- A local "name/premake5.lua" must be preferred over a plain file named
	-- "name" that lives only in a premake.path search directory.
	function suite.findProjectScript_prefersLocalSubdir_overPathDecoy()
		local folder = _TESTS_DIR .. "/folder"
		withLocalPriority(folder, folder .. "/subfolder", function()
			local res, _ = premake.findProjectScript("shadowlib")
			test.isequal(
				path.normalize(folder .. "/shadowlib/premake5.lua"),
				path.normalize(res))
		end)
	end

	-- A local "name.lua" must be preferred over a plain file named "name"
	-- (no extension) that lives only in a premake.path search directory.
	function suite.findProjectScript_prefersLocalLuaFile_overPathDecoy()
		local folder = _TESTS_DIR .. "/folder"
		withLocalPriority(folder, folder .. "/subfolder", function()
			local res, _ = premake.findProjectScript("ok")
			test.isequal(
				path.normalize(folder .. "/ok.lua"),
				path.normalize(res))
		end)
	end

	-- Verify the full include() call for the subdir-priority scenario.
	function suite.include_prefersLocalSubdir_overPathDecoy()
		local folder = _TESTS_DIR .. "/folder"
		withLocalPriority(folder, folder .. "/subfolder", function()
			include("shadowlib")
		end)
		test.isequal("shadowlocal", p.captured())
	end

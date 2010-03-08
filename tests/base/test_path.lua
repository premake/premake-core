--
-- tests/base/test_path.lua
-- Automated test suite for the action list.
-- Copyright (c) 2008-2010 Jason Perkins and the Premake project
--

	T.path = { }
	local suite = T.path


--
-- path.getabsolute() tests
--

	function suite.getabsolute_ReturnsCorrectPath_OnMissingSubdir()
		local expected = path.translate(os.getcwd(), "/") .. "/a/b/c"
		test.isequal(expected, path.getabsolute("a/b/c"))
	end

	function suite.getabsolute_RemovesDotDots_OnWindowsAbsolute()
		test.isequal("c:/ProjectB/bin", path.getabsolute("c:/ProjectA/../ProjectB/bin"))
	end

	function suite.getabsolute_RemovesDotDots_OnPosixAbsolute()
		test.isequal("/ProjectB/bin", path.getabsolute("/ProjectA/../ProjectB/bin"))
	end
	
	function suite.getabsolute_OnTrailingSlash()
		local expected = path.translate(os.getcwd(), "/") .. "/a/b/c"
		test.isequal(expected, path.getabsolute("a/b/c/"))
	end
	
	
--
-- path.getbasename() tests
--

	function suite.getbasename_ReturnsCorrectName_OnDirAndExtension()
		test.isequal("filename", path.getbasename("folder/filename.ext"))
	end


--
-- path.getdirectory() tests
--

	function suite.getdirectory_ReturnsEmptyString_OnNoDirectory()
		test.isequal(".", path.getdirectory("filename.ext"))
	end
	
	function suite.getdirectory_ReturnsDirectory_OnSingleLevelPath()
		test.isequal("dir0", path.getdirectory("dir0/filename.ext"))
	end
	
	function suite.getdirectory_ReturnsDirectory_OnMultiLeveLPath()
		test.isequal("dir0/dir1/dir2", path.getdirectory("dir0/dir1/dir2/filename.ext"))
	end

	function suite.getdirectory_ReturnsRootPath_OnRootPathOnly()
		test.isequal("/", path.getdirectory("/filename.ext"))
	end
		


--
-- path.getdrive() tests
--

	function suite.getdrive_ReturnsNil_OnNotWindows()
		test.isnil(path.getdrive("/hello"))
	end
	
	function suite.getdrive_ReturnsLetter_OnWindowsAbsolute()
		test.isequal("x", path.getdrive("x:/hello"))
	end
	
	
	
--
-- path.getextension() tests
--

	function suite.getextension_ReturnsEmptyString_OnNoExtension()
		test.isequal("", path.getextension("filename"))
	end

	function suite.getextension_ReturnsExtension()
		test.isequal(".txt", path.getextension("filename.txt"))
	end
	
	function suite.getextension_OnMultipleDots()
		test.isequal(".txt", path.getextension("filename.mod.txt"))
	end


--
-- path.getrelative() tests
--

	function suite.getrelative_ReturnsDot_OnMatchingPaths()
		test.isequal(".", path.getrelative("/a/b/c", "/a/b/c"))
	end

	function suite.getrelative_ReturnsDoubleDot_OnChildToParent()
		test.isequal("..", path.getrelative("/a/b/c", "/a/b"))
	end
	
	function suite.getrelative_ReturnsDoubleDot_OnSiblingToSibling()
		test.isequal("../d", path.getrelative("/a/b/c", "/a/b/d"))
	end

	function suite.getrelative_ReturnsChildPath_OnParentToChild()
		test.isequal("d", path.getrelative("/a/b/c", "/a/b/c/d"))
	end

	function suite.getrelative_ReturnsChildPath_OnWindowsAbsolute()
		test.isequal("obj/debug", path.getrelative("C:/Code/Premake4", "C:/Code/Premake4/obj/debug"))
	end
	
	function suite.getrelative_ReturnsAbsPath_OnDifferentDriveLetters()
		test.isequal("D:/Files", path.getrelative("C:/Code/Premake4", "D:/Files"))
	end
	
	function suite.getrelative_ReturnsAbsPath_OnDollarMacro()
		test.isequal("$(SDK_HOME)/include", path.getrelative("C:/Code/Premake4", "$(SDK_HOME)/include"))
	end
	
	function suite.getrelative_ReturnsAbsPath_OnRootedPath()
		test.isequal("/opt/include", path.getrelative("/home/me/src/project", "/opt/include"))
	end
	

--
-- path.isabsolute() tests
--

	function suite.isabsolute_ReturnsTrue_OnAbsolutePosixPath()
		test.istrue(path.isabsolute("/a/b/c"))
	end

	function suite.isabsolute_ReturnsTrue_OnAbsoluteWindowsPathWithDrive()
		test.istrue(path.isabsolute("C:/a/b/c"))
	end

	function suite.isabsolute_ReturnsFalse_OnRelativePath()
		test.isfalse(path.isabsolute("a/b/c"))
	end
	
	function suite.isabsolute_ReturnsTrue_OnDollarSign()
		test.istrue(path.isabsolute("$(SDK_HOME)/include"))
	end


--
-- path.join() tests
--

	function suite.join_OnValidParts()
		test.isequal("leading/trailing", path.join("leading", "trailing"))
	end
	
	function suite.join_OnAbsoluteUnixPath()
		test.isequal("/trailing", path.join("leading", "/trailing"))
	end
	
	function suite.join_OnAbsoluteWindowsPath()
		test.isequal("C:/trailing", path.join("leading", "C:/trailing"))
	end

	function suite.join_OnCurrentDirectory()
		test.isequal("trailing", path.join(".", "trailing"))
	end
	

--
-- path.rebase() tests
--

	function suite.rebase_WithEndingSlashOnPath()
		local cwd = os.getcwd()
		test.isequal("src", path.rebase("../src/", cwd, path.getdirectory(cwd)))
	end


--
-- path.translate() tests
--

	function suite.translate_ReturnsTranslatedPath_OnValidPath()
		test.isequal("dir/dir/file", path.translate("dir\\dir\\file", "/"))
	end

	function suite.translate_ReturnsCorrectSeparator_OnMixedPath()
		local actual = path.translate("dir\\dir/file")
		if (os.is("windows")) then
			test.isequal("dir\\dir\\file", actual)
		else
			test.isequal("dir/dir/file", actual)
		end
	end


--
-- path.wildcards tests
--

	function suite.wildcards_MatchesTrailingStar()
		local p = path.wildcards("**/xcode/*")
		test.isequal(".*/xcode/[^/]*", p)
	end

	function suite.wildcards_MatchPlusSign()
		local patt = path.wildcards("file+name.*")
		local name = "file+name.c"
		test.isequal(name, name:match(patt))
	end

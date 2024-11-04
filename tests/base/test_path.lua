--
-- tests/base/test_path.lua
-- Automated test suite for the action list.
-- Copyright (c) 2008-2013 Jess Perkins and the Premake project
--

	local suite = test.declare("path")


--
-- path.getabsolute() tests
--

	function suite.getabsolute_worksWithMissingSubdirs()
		local expected = os.getcwd() .. "/a/b/c"
		test.isequal(expected, path.getabsolute("a/b/c"))
	end

	function suite.getabsolute_removesDotDots_onWindows()
		test.isequal("c:/ProjectB/bin", path.getabsolute("c:/ProjectA/../ProjectB/bin"))
	end

	function suite.getabsolute_removesDotDots_OnPosix()
		test.isequal("/ProjectB/bin", path.getabsolute("/ProjectA/../ProjectB/bin"))
	end

	function suite.getabsolute_limitsDotDots_onWindows()
		test.isequal("c:/ProjectB/bin", path.getabsolute("c:/ProjectA/../../ProjectB/bin"))
	end

	function suite.getabsolute_limitsDotDots_OnPosix()
		test.isequal("/ProjectB/bin", path.getabsolute("/ProjectA/../../ProjectB/bin"))
	end

	function suite.getabsolute_removesDot()
		test.isequal("/ProjectA/ProjectB/bin", path.getabsolute("/ProjectA/./ProjectB/bin"))
	end

	function suite.getabsolute_removesTrailingSlash()
		test.isequal("/a/b/c", path.getabsolute("/a/b/c/"))
	end

	function suite.getabsolute_onLeadingEnvVar()
		test.isequal("$(HOME)/user", path.getabsolute("$(HOME)/user"))
	end

	function suite.getabsolute_onLeadingEnvVar_dosStyle()
		test.isequal("%HOME%/user", path.getabsolute("%HOME%/user"))
	end

	function suite.getabsolute_onServerPath()
		test.isequal("//Server/Volume", path.getabsolute("//Server/Volume"))
	end

	function suite.getabsolute_onMultipleEnvVar()
		test.isequal("$(HOME)/$(USER)", path.getabsolute("$(HOME)/$(USER)"))
	end

	function suite.getabsolute_onTrailingEnvVar()
		test.isequal("/home/$(USER)", path.getabsolute("/home/$(USER)"))
	end

	function suite.getabsolute_onLeadingEnvVarQuoted()
		test.isequal('"$(HOME)/user"', path.getabsolute('"$(HOME)/user"'))
	end

	function suite.getabsolute_normalizesPaths()
		test.isequal("c:/ProjectB/bin", path.getabsolute("c:\\ProjectB\\bin"))
	end

	function suite.getabsolute_acceptsTables()
		test.isequal({ "/a/b", "/c/d" }, path.getabsolute({ "/a/b", "/c/d" }))
	end

	function suite.getabsolute_withRelativeTo()
		local relto = path.getdirectory(os.getcwd())
		local expected = relto .. "/a/b/c"
		test.isequal(expected, path.getabsolute("a/b/c", relto))
	end

	function suite.getabsolute_withRelativeTo_withTrailingSlashes()
		local relto = path.getdirectory(os.getcwd())
		local expected = relto .. "/a/b/c"
		test.isequal(expected, path.getabsolute("a/b/c", relto .. "/"))
	end

	function suite.getabsolute_acceptsTables_withRelativeTo()
		local relto = path.getdirectory(os.getcwd())
		test.isequal({ relto .. "/a/b", relto .. "/c/d" }, path.getabsolute({ "a/b", "c/d" }, relto))
	end

	function suite.getabsolute_leavesDotDot_onShellVar()
		test.isequal("$ORIGIN/../libs", path.getabsolute("$ORIGIN/../libs"))
	end

	function suite.getabsolute_leavesDotDot2_onShellVar()
		test.isequal("$ORIGIN/../../libs", path.getabsolute("$ORIGIN/../../libs"))
	end

--
-- path.deferred_join() tests
--
	function suite.deferred_join_OnMaybeAbsolutePath()
		test.isequal("p1\a%{foo}", path.deferredjoin("p1", "%{foo}"))
	end

	function suite.deferred_join_OnValidParts()
		test.isequal("p1/p2", path.deferredjoin("p1", "p2"))
	end

	function suite.deferred_join_OnAbsoluteath()
		test.isequal("/p2", path.deferredjoin("p1", "/p2"))
	end

--
-- path.has_deferred_join() tests
--

	function suite.has_deferred_join_true()
		test.istrue(path.hasdeferredjoin("p1\a%{foo}"))
	end

	function suite.has_deferred_join_false()
		test.isfalse(path.hasdeferredjoin("p1/p2"))
	end

	function suite.has_deferred_join_true_OnPipe()
		test.istrue(path.hasdeferredjoin("c1 p1\a%{foo} | c2"))
	end

	function suite.has_deferred_join_false_OnPipe()
		test.isfalse(path.hasdeferredjoin("c1 p1/p2 | c2"))
	end

	function suite.has_deferred_join_true_OnOr()
		test.istrue(path.hasdeferredjoin("c1 p1\a%{foo} || c2"))
	end

	function suite.has_deferred_join_false_OnOr()
		test.isfalse(path.hasdeferredjoin("c1 p1/p2 || c2"))
	end

--
-- path.resolvedeferredjoin() tests
--

	function suite.resolve_deferred_join_OnNoDelimiter()
		test.isequal("p1", path.resolvedeferredjoin("p1"))
	end

	function suite.resolve_deferred_join_OnValidParts()
		test.isequal("p1/p2", path.resolvedeferredjoin("p1\ap2"))
	end

	function suite.resolve_deferred_join_OnAbsoluteWindowsPath()
		test.isequal("C:/p2", path.resolvedeferredjoin("p1\aC:/p2"))
	end

	function suite.resolve_deferred_join_OnCurrentDirectory()
		test.isequal("p2", path.resolvedeferredjoin(".\ap2"))
	end

	function suite.resolve_deferred_join_OnBackToBasePath()
		test.isequal("", path.resolvedeferredjoin("p1/p2/\a../../"))
	end

	function suite.resolve_deferred_join_OnBackToBasePathWithoutFinalSlash()
		test.isequal("", path.resolvedeferredjoin("p1/p2/\a../.."))
	end

	function suite.resolve_deferred_join_OnBothUpTwoFolders()
		test.isequal("../../../../foo", path.resolvedeferredjoin("../../\a../../foo"))
	end

	function suite.resolve_deferred_join_OnUptwoFolders()
		test.isequal("p1/foo", path.resolvedeferredjoin("p1/p2/p3\a../../foo"))
	end

	function suite.resolve_deferred_join_OnUptoBase()
		test.isequal("foo", path.resolvedeferredjoin("p1/p2/p3\a../../../foo"))
	end

	function suite.resolve_deferred_join_ignoreLeadingDots()
		test.isequal("p1/p2/foo", path.resolvedeferredjoin("p1/p2\a././foo"))
	end

	function suite.resolve_deferred_join_OnUptoParentOfBase()
		test.isequal("../../p1", path.resolvedeferredjoin("p1/p2/p3/p4/p5/p6/p7/\a../../../../../../../../../p1"))
	end

	function suite.resolve_deferred_join_onMoreThanTwoParts()
		test.isequal("p1/p2/p3", path.resolvedeferredjoin("p1\ap2\ap3"))
	end

	function suite.resolve_deferred_join_removesExtraInternalSlashes()
		test.isequal("p1/p2", path.resolvedeferredjoin("p1/\ap2"))
	end

	function suite.resolve_deferred_join_removesTrailingSlash()
		test.isequal("p1/p2", path.resolvedeferredjoin("p1\ap2/"))
	end

	function suite.resolve_deferred_join_ignoresEmptyParts()
		test.isequal("p2", path.resolvedeferredjoin("\ap2\a"))
	end

	function suite.resolve_deferred_join_canJoinBareSlash()
		test.isequal("/Users", path.resolvedeferredjoin("/\aUsers"))
	end

	function suite.resolve_deferred_join_keepsLeadingEnvVar()
		test.isequal("$(ProjectDir)/../../Bin", path.resolvedeferredjoin("$(ProjectDir)\a../../Bin"))
	end

	function suite.resolve_deferred_join_keepsInternalEnvVar()
		test.isequal("$(ProjectDir)/$(TargetName)/../../Bin", path.resolvedeferredjoin("$(ProjectDir)/$(TargetName)\a../../Bin"))
	end

	function suite.resolve_deferred_join_keepsComplexInternalEnvVar()
		test.isequal("$(ProjectDir)/myobj_$(Arch)/../../Bin", path.resolvedeferredjoin("$(ProjectDir)/myobj_$(Arch)\a../../Bin"))
	end

	function suite.resolve_deferred_join_keepsRecursivePattern()
		test.isequal("p1/**.lproj/../p2", path.resolvedeferredjoin("p1/**.lproj\a../p2"))
	end

	function suite.resolve_deferred_join_keepsVSMacros()
		test.isequal("p1/%(Filename).ext", path.resolvedeferredjoin("p1\a%(Filename).ext"))
	end

	function suite.resolve_deferred_join_noCombineSingleDot()
		test.isequal("p1/./../p2", path.resolvedeferredjoin("p1/.\a../p2"))
	end

	function suite.resolve_deferred_join_absolute_second_part()
		test.isequal("$ORIGIN", path.resolvedeferredjoin("foo/bar\a$ORIGIN"))
	end

	function suite.resolve_deferred_join_absolute_second_part1()
		test.isequal("$(FOO)/bar", path.resolvedeferredjoin("foo/bar\a$(FOO)/bar"))
	end

	function suite.resolve_deferred_join_absolute_second_part2()
		test.isequal("%ROOT%/foo", path.resolvedeferredjoin("foo/bar\a%ROOT%/foo"))
	end

	function suite.resolve_deferred_join_token_in_second_part()
		test.isequal("foo/bar/%{test}/foo", path.resolvedeferredjoin("foo/bar\a%{test}/foo"))
	end

	function suite.resolve_deferred_join_ignoresPipe()
		test.isequal("c1 p1/p2 | c2", path.resolvedeferredjoin("c1 p1/p2 | c2"))
	end

	function suite.resolve_deferred_join_OnPipe()
		test.isequal("c1 p1/p2 | c2", path.resolvedeferredjoin("c1 p1\ap2 | c2"))
	end

	function suite.resolve_deferred_join_ignoresOr()
		test.isequal("c1 p1/p2 || c2", path.resolvedeferredjoin("c1 p1/p2 || c2"))
	end

	function suite.resolve_deferred_join_OnOr()
		test.isequal("c1 p1/p2 || c2", path.resolvedeferredjoin("c1 p1\ap2 || c2"))
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

	function suite.getextension_ReturnsEmptyString_OnPathWithDotAndNoExtension()
		test.isequal("", path.getextension("/.premake/premake"))
	end

	function suite.getextension_ReturnsExtension()
		test.isequal(".txt", path.getextension("filename.txt"))
	end

	function suite.getextension_ReturnsExtension_OnPathWithDot()
		test.isequal(".lua", path.getextension("/.premake/premake.lua"))
	end

	function suite.getextension_OnMultipleDots()
		test.isequal(".txt", path.getextension("filename.mod.txt"))
	end

	function suite.getextension_OnLeadingNumeric()
		test.isequal(".7z", path.getextension("filename.7z"))
	end

	function suite.getextension_OnUnderscore()
		test.isequal(".a_c", path.getextension("filename.a_c"))
	end

	function suite.getextension_OnHyphen()
		test.isequal(".a-c", path.getextension("filename.a-c"))
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

	function suite.getrelative_ReturnsChildPath_OnServerPath()
		test.isequal("../Volume", path.getrelative("//Server/Shared", "//Server/Volume"))
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

	function suite.getrelative_ReturnsAbsPath_OnServerPath()
		test.isequal("//Server/Volume", path.getrelative("C:/Files", "//Server/Volume"))
	end

	function suite.getrelative_ReturnsAbsPath_OnDifferentServers()
		test.isequal("//Server/Volume", path.getrelative("//Computer/Users", "//Server/Volume"))
	end

	function suite.getrelative_ignoresExtraSlashes2()
		test.isequal("..", path.getrelative("/a//b/c","/a/b"))
	end

	function suite.getrelative_ignoresExtraSlashes3()
		test.isequal("..", path.getrelative("/a///b/c","/a/b"))
	end

	function suite.getrelative_ignoresTrailingSlashes()
		test.isequal("c", path.getrelative("/a/b/","/a/b/c"))
	end

	function suite.getrelative_returnsAbsPath_onContactWithFileSysRoot()
		test.isequal("C:/Boost/Include", path.getrelative("C:/Code/MyApp", "C:/Boost/Include"))
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

	function suite.isabsolute_ReturnsTrue_OnDollarToken()
		test.istrue(path.isabsolute("$(SDK_HOME)/include"))
	end

	function suite.isabsolute_ReturnsTrue_OnDotInDollarToken()
		test.istrue(path.isabsolute("$(configuration.libs)/include"))
	end

	function suite.isabsolute_ReturnsTrue_OnJustADollarSign()
		test.istrue(path.isabsolute("$foo/include"))
	end

	function suite.isabsolute_ReturnsFalse_OnIncompleteDollarToken()
		test.isfalse(path.isabsolute("$(foo/include"))
	end

	function suite.isabsolute_ReturnsTrue_OnEnvVar()
		test.istrue(path.isabsolute("%FOO%/include"))
	end

	function suite.isabsolute_ReturnsFalse_OnEmptyEnvVar()
		test.isfalse(path.isabsolute("%%/include"))
	end

	function suite.isabsolute_ReturnsFalse_OnToken()
		test.isfalse(path.isabsolute("%{foo}/include"))
	end


--
-- path.join() tests
--

	function suite.join_OnValidParts()
		test.isequal("p1/p2", path.join("p1", "p2"))
	end

	function suite.join_OnAbsoluteUnixPath()
		test.isequal("/p2", path.join("p1", "/p2"))
	end

	function suite.join_OnAbsoluteWindowsPath()
		test.isequal("C:/p2", path.join("p1", "C:/p2"))
	end

	function suite.join_OnCurrentDirectory()
		test.isequal("p2", path.join(".", "p2"))
	end

	function suite.join_OnBackToBasePath()
		test.isequal("", path.join("p1/p2/", "../../"))
	end

	function suite.join_OnBackToBasePathWithoutFinalSlash()
		test.isequal("", path.join("p1/p2/", "../.."))
	end

	function suite.join_OnBothUpTwoFolders()
		test.isequal("../../../../foo", path.join("../../", "../../foo"))
	end

	function suite.join_OnUptwoFolders()
		test.isequal("p1/foo", path.join("p1/p2/p3", "../../foo"))
	end

	function suite.join_OnUptoBase()
		test.isequal("foo", path.join("p1/p2/p3", "../../../foo"))
	end

	function suite.join_ignoreLeadingDots()
		test.isequal("p1/p2/foo", path.join("p1/p2", "././foo"))
	end

	function suite.join_OnUptoParentOfBase()
		test.isequal("../../p1", path.join("p1/p2/p3/p4/p5/p6/p7/", "../../../../../../../../../p1"))
	end

	function suite.join_OnNilSecondPart()
		test.isequal("p1", path.join("p1", nil))
	end

	function suite.join_onMoreThanTwoParts()
		test.isequal("p1/p2/p3", path.join("p1", "p2", "p3"))
	end

	function suite.join_removesExtraInternalSlashes()
		test.isequal("p1/p2", path.join("p1/", "p2"))
	end

	function suite.join_removesTrailingSlash()
		test.isequal("p1/p2", path.join("p1", "p2/"))
	end

	function suite.join_ignoresNilParts()
		test.isequal("p2", path.join(nil, "p2", nil))
	end

	function suite.join_ignoresEmptyParts()
		test.isequal("p2", path.join("", "p2", ""))
	end

	function suite.join_canJoinBareSlash()
		test.isequal("/Users", path.join("/", "Users"))
	end

	function suite.join_keepsLeadingEnvVar()
		test.isequal("$(ProjectDir)/../../Bin", path.join("$(ProjectDir)", "../../Bin"))
	end

	function suite.join_keepsInternalEnvVar()
		test.isequal("$(ProjectDir)/$(TargetName)/../../Bin", path.join("$(ProjectDir)/$(TargetName)", "../../Bin"))
	end

	function suite.join_keepsComplexInternalEnvVar()
		test.isequal("$(ProjectDir)/myobj_$(Arch)/../../Bin", path.join("$(ProjectDir)/myobj_$(Arch)", "../../Bin"))
	end

	function suite.join_keepsRecursivePattern()
		test.isequal("p1/**.lproj/../p2", path.join("p1/**.lproj", "../p2"))
	end

	function suite.join_noCombineSingleDot()
		test.isequal("p1/./../p2", path.join("p1/.", "../p2"))
	end

	function suite.join_absolute_second_part()
		test.isequal("$ORIGIN", path.join("foo/bar", "$ORIGIN"))
	end

	function suite.join_absolute_second_part1()
		test.isequal("$(FOO)/bar", path.join("foo/bar", "$(FOO)/bar"))
	end

	function suite.join_absolute_second_part2()
		test.isequal("%ROOT%/foo", path.join("foo/bar", "%ROOT%/foo"))
	end

	function suite.join_token_in_second_part()
		test.isequal("foo/bar/%{test}/foo", path.join("foo/bar", "%{test}/foo"))
	end

--
-- path.rebase() tests
--

	function suite.rebase_WithEndingSlashOnPath()
		local cwd = os.getcwd()
		test.isequal("src", path.rebase("../src/", cwd, path.getdirectory(cwd)))
	end


--
-- path.replaceextension() tests
--

	function suite.getabsolute_replaceExtension()
		test.isequal("/AB.foo", path.replaceextension("/AB.exe","foo"))
	end

	function suite.getabsolute_replaceExtensionWithDot()
		test.isequal("/AB.foo", path.replaceextension("/AB.exe",".foo"))
	end

	function suite.getabsolute_replaceExtensionWithDotMultipleDots()
		test.isequal("/nunit.framework.foo", path.replaceextension("/nunit.framework.dll",".foo"))
	end

	function suite.getabsolute_replaceExtensionCompletePath()
		test.isequal("/nunit/framework/main.foo", path.replaceextension("/nunit/framework/main.cpp",".foo"))
	end

	function suite.getabsolute_replaceExtensionWithoutExtension()
		test.isequal("/nunit/framework/main.foo", path.replaceextension("/nunit/framework/main",".foo"))
	end

	function suite.getabsolute_replaceExtensionWithEmptyString()
		test.isequal("foo", path.replaceextension("foo.lua",""))
	end



--
-- path.translate() tests
--

	function suite.translate_ReturnsTranslatedPath_OnValidPath()
		test.isequal("dir/dir/file", path.translate("dir\\dir\\file", "/"))
	end

	function suite.translate_returnsCorrectSeparator_onMixedPath()
		local actual = path.translate("dir\\dir/file", "/")
		test.isequal("dir/dir/file", actual)
	end

	function suite.translate_ReturnsTargetOSSeparator_Windows()
		_OPTIONS["os"] = "windows"
		test.isequal("dir\\dir\\file", path.translate("dir/dir\\file"))
	end

	function suite.translate_ReturnsTargetOSSeparator_Linux()
		_OPTIONS["os"] = "linux"
		test.isequal("dir/dir/file", path.translate("dir/dir\\file"))
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

	function suite.wildcards_escapeSpecialChars()
		test.isequal("%.%-", path.wildcards(".-"))
	end

	function suite.wildcards_escapeStar()
		test.isequal("vs[^/]*", path.wildcards("vs*"))
	end

	function suite.wildcards_escapeStarStar()
		test.isequal("Images/.*%.bmp", path.wildcards("Images/**.bmp"))
	end



--
-- path.normalize tests
--
	function suite.normalize_Test1()
		local p = path.normalize("d:/game/../test")
		test.isequal("d:/test", p)
	end

	function suite.normalize_Test2()
		local p = path.normalize("d:/game/../../test")
		test.isequal("d:/../test", p)
	end

	function suite.normalize_Test3()
		local p = path.normalize("../../test")
		test.isequal("../../test", p)
	end

	function suite.normalize_Test4()
		local p = path.normalize("../../../test/*.h")
		test.isequal("../../../test/*.h", p)
	end

	function suite.normalize_Test5()
		test.isequal("test", path.normalize("./test"))
		test.isequal("d:/", path.normalize("d:/"))
		test.isequal("d:/", path.normalize("d:/./"))
		local p = path.normalize("d:/game/..")
		test.isequal("d:/", p)
	end

	function suite.normalize_trailingDots1()
		local p = path.normalize("../game/test/..")
		test.isequal("../game", p)
	end

	function suite.normalize_trailingDots2()
		local p = path.normalize("../game/..")
		test.isequal("..", p)
	end

	function suite.normalize_singleDot()
		local p = path.normalize("../../p1/p2/p3/p4/./a.pb.cc")
		test.isequal("../../p1/p2/p3/p4/a.pb.cc", p)
	end

	function suite.normalize_trailingSingleDot()
		local p = path.normalize("../../p1/p2/p3/p4/./.")
		test.isequal("../../p1/p2/p3/p4", p)
	end

	function suite.normalize()
		test.isequal("d:/ProjectB/bin", path.normalize("d:/ProjectA/../ProjectB/bin"))
		test.isequal("/ProjectB/bin", path.normalize("/ProjectA/../ProjectB/bin"))
	end

	function suite.normalize_leadingWhitespaces()
		test.isequal("d:/game", path.normalize("\t\n d:/game"))
	end

	function suite.normalize_multPath()
		test.isequal("../a/b ../c/d", path.normalize("../a/b ../c/d"))
		test.isequal("d:/test ../a/b", path.normalize("d:/game/../test ../a/b"))
		test.isequal("d:/game/test ../a/b", path.normalize("d:/game/./test ../a/b"))
		test.isequal("d:/test ../a/b", path.normalize(" d:/game/../test ../a/b"))
		test.isequal("d:/game ../a/b", path.normalize(" d:/game ../a/./b"))
		test.isequal("d:/game ../a/b", path.normalize("d:/game/ ../a/b"))
		test.isequal("d:/game", path.normalize("d:/game/ "))
	end

	function suite.normalize_legitimateDots()
		test.isequal("d:/test/test..test", path.normalize("d:/test/test..test"))
		test.isequal("d:/test..test/test", path.normalize("d:/test..test/test"))
		test.isequal("d:/test/.test", path.normalize("d:/test/.test"))
		test.isequal("d:/.test", path.normalize("d:/test/../.test"))
		test.isequal("d:/test", path.normalize("d:/test/.test/.."))
		test.isequal("d:/test/..test", path.normalize("d:/test/..test"))
		test.isequal("d:/..test", path.normalize("d:/test/../..test"))
		test.isequal("d:/test", path.normalize("d:/test/..test/.."))
		test.isequal("d:/test/.test", path.normalize("d:/test/..test/../.test"))
		test.isequal("d:/test/..test/.test", path.normalize("d:/test/..test/test/../.test"))
		test.isequal("d:/test", path.normalize("d:/test/..test/../.test/.."))
	end

	function suite.normalize_serverpath()
		test.isequal("//myawesomeserver/test", path.normalize("//myawesomeserver/test/"))
		test.isequal("//myawesomeserver/test", path.normalize("///myawesomeserver/test/"))
	end

	function suite.normalize_quotedpath()
		test.isequal("\"../../test/test/\"", path.normalize("\"../../test/test/\""))
		test.isequal("\"../../test/\"", path.normalize("\"../../test/../test/\""))
	end

	function suite.normalize_withTokens()
		-- Premake tokens
		test.isequal("%{wks.location}../../test", path.normalize("%{wks.location}../../test"))
		-- Visual Studio var
		test.isequal("$(SolutionDir)../../test", path.normalize("$(SolutionDir)../../test"))
		-- Windows env var
		test.isequal("%APPDATA%../../test", path.normalize("%APPDATA%../../test"))
		-- Unix env var
		test.isequal("${HOME}../../test", path.normalize("${HOME}../../test"))

		-- Middle
		test.isequal("../../${MYVAR}/../test", path.normalize("../../${MYVAR}/../test"))
		-- End
		test.isequal("../../test/${MYVAR}", path.normalize("../../test/${MYVAR}"))
	end

	function suite.normalize_quotedpath_withTokens()
		-- Premake tokens
		test.isequal("\"%{wks.location}../../test\"", path.normalize("\"%{wks.location}../../test\""))
		-- Visual Studio var
		test.isequal("\"$(SolutionDir)../../test\"", path.normalize("\"$(SolutionDir)../../test\""))
		-- Windows env var
		test.isequal("\"%APPDATA%../../test\"", path.normalize("\"%APPDATA%../../test\""))
		-- Unix env var
		test.isequal("\"${HOME}../../test\"", path.normalize("\"${HOME}../../test\""))

		-- Middle
		test.isequal("\"../../${MYVAR}/../test\"", path.normalize("\"../../${MYVAR}/../test\""))
		-- End
		test.isequal("\"../../test/${MYVAR}\"", path.normalize("\"../../test/${MYVAR}\""))
	end

--
-- tests/base/test_detoken.lua
-- Test suite for the token expansion API.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("detoken")

	local detoken = premake.detoken


--
-- Setup
--

	local x, action
	local environ = {}

	function suite.setup()
		action = premake.action.get("test")
	end

	function suite.teardown()
		action.pathVars = nil
	end



--
-- The contents of the token should be executed and the results returned.
--

	function suite.executesTokenContents()
		x = detoken.expand("MyProject%{1+1}", environ)
		test.isequal("MyProject2", x)
	end


--
-- If the value contains more than one token, then should all be expanded.
--

	function suite.expandsMultipleTokens()
		x = detoken.expand("MyProject%{'X'}and%{'Y'}and%{'Z'}", environ)
		test.isequal("MyProjectXandYandZ", x)
	end


--
-- If the token replacement values contain tokens themselves, those
-- should also get expanded.
--

	function suite.expandsNestedTokens()
		environ.wks = { name="MyWorkspace%{'X'}" }
		x = detoken.expand("%{wks.name}", environ)
		test.isequal("MyWorkspaceX", x)
	end


--
-- Verify that the global namespace is still accessible.
--

	function suite.canUseGlobalFunctions()
		x = detoken.expand("%{iif(true, 'a', 'b')}", environ)
		test.isequal("a", x)
	end


--
-- If a path field contains a token, and if that token expands to an
-- absolute path itself, that should be returned as the new value.
--

	function suite.canExpandToAbsPath()
		environ.cfg = { basedir = os.getcwd() }
		x = detoken.expand("bin/debug/%{cfg.basedir}", environ, {paths=true})
		test.isequal(os.getcwd(), x)
	end


--
-- If a non-path field contains a token that expands to a path, that
-- path should be converted to a relative value.
--

	function suite.canExpandToRelPath()
		local cwd = os.getcwd()
		environ.cfg = { basedir = path.getdirectory(cwd) }
		x = detoken.expand("cd %{cfg.basedir}", environ,  {}, cwd)
		test.isequal("cd ..", x)
	end


--
-- If the value being expanded is a table, iterate over all of its values.
--

	function suite.expandsAllItemsInList()
		x = detoken.expand({ "A%{1}", "B%{2}", "C%{3}" }, environ)
		test.isequal({ "A1", "B2", "C3" }, x)
	end


--
-- If the field being expanded supports path variable mapping, and the
-- action provides a map, replace tokens with the mapped values.
--

	function suite.replacesToken_onSupportedAndMapped()
		action.pathVars = { ["cfg.objdir"] = { absolute = true,  token = "$(IntDir)" }, }
		x = detoken.expand("cmd %{cfg.objdir}/file", environ, {pathVars=true})
		test.isequal("cmd $(IntDir)/file", x)
	end

	function suite.replacesToken_onSupportedAndMapped_inAbsPath()
		action.pathVars = { ["cfg.objdir"] = { absolute = true,  token = "$(IntDir)" }, }
		x = detoken.expand(os.getcwd() .. "/%{cfg.objdir}/file", environ, {paths=true,pathVars=true})
		test.isequal("$(IntDir)/file", x)
	end

	function suite.replacesToken_onSupportedAndMapped_inRelPath()
		action.pathVars = { ["cfg.objdir"] = { absolute = false,  token = "$(IntDir)" }, }
		x = detoken.expand(os.getcwd() .. "/%{cfg.objdir}/file", environ, {paths=true,pathVars=true})
		test.isequal(os.getcwd() .. "/$(IntDir)/file", x)
	end

--
-- Escapes backslashes correctly.
--

	function suite.escapesBackslashes()
		environ.foo = "some/path"
		x = detoken.expand("%{foo:gsub('/', '\\')}", environ)
		test.isequal("some\\path", x)
	end

--
-- Escapes backslashes correctly, but not outside tokens.
--

	function suite.escapesBackslashes2()
		environ.foo = "some/path"
		x = detoken.expand("%{foo:gsub('/', '\\')}\\already\\escaped", environ)
		test.isequal("some\\path\\already\\escaped", x)
	end

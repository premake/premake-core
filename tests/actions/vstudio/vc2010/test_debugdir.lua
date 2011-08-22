--
-- tests/actions/vstudio/vc2010/test_debugdir.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_debugdir = { }
	local suite = T.vstudio_vs2010_debugdir
	local vc2010 = premake.vstudio.vc2010


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		premake.bake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		vc2010.debugdir(prj)
	end


--
-- Tests
--

	function suite.PrintsNothing_OnDebugDirSet()
		prepare()
		test.capture [[
		]]
	end

	function suite.IsFormattedCorrectly_OnRelativePath()
		debugdir "bin/debug"
		prepare()
		test.capture [[
    <LocalDebuggerWorkingDirectory>bin\debug</LocalDebuggerWorkingDirectory>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
		]]
	end

	function suite.Arguments()
		debugargs { "arg1", "arg2" }
		prepare()
		test.capture [[
    <LocalDebuggerCommandArguments>arg1 arg2</LocalDebuggerCommandArguments>
		]]
	end



	T.vs2010_env_args = { }
	local vs10_env_args = T.vs2010_env_args
	local env_args = premake.vstudio.vc2010.environmentargs

	function vs10_env_args.environmentArgs_notSet_bufferDoesNotContainLocalDebuggerEnvironment()
		env_args( {flags={}} )
		test.string_does_not_contain(io.endcapture(),'<LocalDebuggerEnvironment>')
	end

	function vs10_env_args.environmentArgs_set_bufferContainsLocalDebuggerEnvironment()
		env_args({flags={},environmentargs ={'key=value'}} )
		test.string_contains(io.endcapture(),'<LocalDebuggerEnvironment>')
	end

	function vs10_env_args.environmentArgs_oneArgformat_openTagKeyValuePairCloseTag()
		env_args({flags={},environmentargs ={'key=value'}} )
		test.string_contains(io.endcapture(),'<LocalDebuggerEnvironment>key=value</LocalDebuggerEnvironment>')
	end
	
	function vs10_env_args.environmentArgs_twoArgformat_openTagKeyValueNewLineSecondPairCloseTag()
		env_args({flags={},environmentargs ={'key=value','foo=bar'}} )
		test.string_contains(io.endcapture(),'<LocalDebuggerEnvironment>key=value\nfoo=bar</LocalDebuggerEnvironment>')
	end

	function vs10_env_args.environmentArgs_withOutFlagEnvironmentArgsInherit_doesNotContainLocalDebuggerEnvironmentArg()
		env_args({flags={},environmentargs ={'key=value'}} )
		test.string_does_not_contain(io.endcapture(),'%$%(LocalDebuggerEnvironment%)')
	end

	function vs10_env_args.environmentArgs_withFlagEnvironmentArgsInherit_endsWithNewLineLocalDebuggerEnvironmentFollowedByClosedTag()
		env_args({flags={EnvironmentArgsInherit=1},environmentargs ={'key=value'}} )
		test.string_contains(io.endcapture(),'\n%$%(LocalDebuggerEnvironment%)</LocalDebuggerEnvironment>')
	end
	
	function vs10_env_args.environmentArgs_withEnvironmentArgsDontMerge_localDebuggerMergeEnvironmentSetToFalse()
		env_args({flags={EnvironmentArgsDontMerge=1},environmentargs ={'key=value'}} )
		test.string_contains(io.endcapture(),'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
	end

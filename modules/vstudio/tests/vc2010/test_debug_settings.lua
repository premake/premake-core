--
-- tests/actions/vstudio/vc2010/test_debug_settings.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_debug_settings")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.debugSettings(cfg)
	end


--
-- If no debug directory is set, nothing should be output.
--

	function suite.noOutput_onNoDebugDir()
		prepare()
		test.isemptycapture()
	end

--
-- The debug command should specified relative to the project location.
--

	function suite.debugCommand_isProjectRelative()
		debugcommand "bin/emulator.exe"
		prepare()

		expectedPath = path.translate(path.getabsolute(os.getcwd())) .. "\\bin\\emulator.exe"
		expected = "<LocalDebuggerCommand>" .. expectedPath .. "</LocalDebuggerCommand>"
		expected = expected .. "\n<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>"
		test.capture (expected)
	end


--
-- The debug directory should specified relative to the project location.
--

	function suite.debugDirectory_isProjectRelative()
		debugdir "bin/debug"
		prepare()
		test.capture [[
<LocalDebuggerWorkingDirectory>bin\debug</LocalDebuggerWorkingDirectory>
<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
		]]
	end

--
-- Verify handling of debug arguments.
--

	function suite.debuggerCommandArgs_onDebugArgs()
		debugargs { "arg1", "arg2", "arg1" }
		prepare()
		test.capture [[
<LocalDebuggerCommandArguments>arg1 arg2 arg1</LocalDebuggerCommandArguments>
		]]
	end

--
-- Check the handling of debug environment variables.
--

	function suite.localDebuggerEnv_onDebugEnv()
		debugenvs { "key=value" }
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value</LocalDebuggerEnvironment>
		]]
	end

--
-- Multiple environment variables should be separated by a "\n" sequence.
--

	function suite.localDebuggerEnv_onMultipleDebugEnv()
		debugenvs { "key=value", "foo=bar" }
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value
foo=bar</LocalDebuggerEnvironment>
		]]
	end

--
-- Test debugger flavors
--

	function suite.debugger_OnWindowsDefault()
		debugger "Default"
		prepare()
		test.capture [[

		]]
	end

	function suite.debugger_OnWindowsUnavailable()
		debugger "GDB"
		prepare()
		test.capture [[

		]]
	end

	function suite.debugger_OnWindowsLocal()
		debugger "VisualStudioLocal"
		prepare()
		test.capture [[
<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
		]]
	end

	function suite.debuggerFlavor_OnWindowsRemote()
		debugger "VisualStudioRemote"
		prepare()
		test.capture [[
<DebuggerFlavor>WindowsRemoteDebugger</DebuggerFlavor>
		]]
	end

	function suite.debuggerFlavor_OnDebugDirAndDebugger()
		debugdir "bin/debug"
		debugger "VisualStudioRemote"
		prepare()
		test.capture [[
<LocalDebuggerWorkingDirectory>bin\debug</LocalDebuggerWorkingDirectory>
<DebuggerFlavor>WindowsRemoteDebugger</DebuggerFlavor>
		]]
	end

--
-- Check the handling of debugenvsinherit.
--

	function suite.localDebuggerEnv_onDebugEnvsInherit()
		debugenvs { "key=value" }
		debugenvsinherit "On"
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value
$(LocalDebuggerEnvironment)</LocalDebuggerEnvironment>
		]]
	end

	function suite.localDebuggerEnv_onDeprecatedDebugEnvsInherit()
		debugenvs { "key=value" }
		flags { "DebugEnvsInherit" }
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value
$(LocalDebuggerEnvironment)</LocalDebuggerEnvironment>
		]]
	end

--
-- Check the handling of debugenvsmerge.
--

	function suite.localDebuggerEnv_onDebugEnvsMergeFalse()
		debugenvs { "key=value" }
		debugenvsmerge "Off"
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value</LocalDebuggerEnvironment>
<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>
		]]
	end

	function suite.localDebuggerEnv_onDeprecatedDebugEnvsDontMerge()
		debugenvs { "key=value" }
		flags { "DebugEnvsDontMerge" }
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value</LocalDebuggerEnvironment>
<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>
		]]
	end

	function suite.localDebuggerEnv_onDebugEnvsBothFlags()
		debugenvs { "key=value" }
		debugenvsinherit "On"
		debugenvsmerge "Off"
		prepare()
		test.capture [[
<LocalDebuggerEnvironment>key=value
$(LocalDebuggerEnvironment)</LocalDebuggerEnvironment>
<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>
		]]
	end

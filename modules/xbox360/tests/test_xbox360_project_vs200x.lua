	local p = premake
	local suite = test.declare("test_xbox360_project_vs200x")
	local vc2010 = p.vstudio.vc2010
	local vc200x = p.vstudio.vc200x
	local config = p.config

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks, prj = test.createWorkspace()
		configurations { "Xbox 360" }
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCCLCompilerTool(cfg)
	end
	
--
-- Xbox 360 uses the same structure, but changes the element name.
--

	function suite.looksGood_onXbox360()
		system "Xbox360"
		prepare()
		test.capture [[
<Tool
	Name="VCCLX360CompilerTool"
	Optimization="0"
	BasicRuntimeChecks="3"
	RuntimeLibrary="2"
	EnableFunctionLevelLinking="true"
	UsePrecompiledHeader="0"
	WarningLevel="3"
	DebugInformationFormat="0"
/>
		]]
	end
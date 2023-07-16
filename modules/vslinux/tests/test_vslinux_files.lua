local p = premake
local suite = test.declare("test_vslinux_files")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2022")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		system "linux"
		vc2010.files(prj)
	end

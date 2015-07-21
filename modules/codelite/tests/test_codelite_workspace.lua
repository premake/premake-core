---
-- codelite/tests/test_codelite_workspace.lua
-- Validate generation for CodeLite workspaces.
-- Author Manu Evans
-- Copyright (c) 2015 Manu Evans and the Premake project
---

	local suite = test.declare("codelite_workspace")
	local codelite = premake.modules.codelite


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "codelite"
		premake.indent("  ")
		sln = test.createsolution()
	end

	local function prepare()
		sln = test.getsolution(sln)
		codelite.solution.generate(sln)
	end


--
-- Check the basic structure of a workspace.
--

	function suite.onEmptySolution()
		sln.projects = {}
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MySolution" Database="" SWTLW="No">
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="yes">
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

	function suite.onDefaultSolution()
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MySolution" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="yes">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

	function suite.onMultipleProjects()
		test.createproject(sln)
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MySolution" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project"/>
  <Project Name="MyProject2" Path="MyProject2.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
      <Project Name="MyProject2" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="yes">
      <Project Name="MyProject" ConfigName="Release"/>
      <Project Name="MyProject2" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end


--
-- Projects should include relative path from workspace.
--

	function suite.onNestedProjectPath()
		location "MyProject"
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MySolution" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject\MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="yes">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

	function suite.onExternalProjectPath()
		location "../MyProject"
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MySolution" Database="" SWTLW="No">
  <Project Name="MyProject" Path="..\MyProject\MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="yes">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

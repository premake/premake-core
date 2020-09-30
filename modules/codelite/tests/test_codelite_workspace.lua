---
-- codelite/tests/test_codelite_workspace.lua
-- Validate generation for CodeLite workspaces.
-- Author Manu Evans
-- Copyright (c) 2015 Manu Evans and the Premake project
---

	local suite = test.declare("codelite_workspace")
	local p = premake
	local codelite = p.modules.codelite


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("codelite")
		p.escaper(codelite.esc)
		p.indent("  ")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = test.getWorkspace(wks)
		codelite.workspace.generate(wks)
	end


--
-- Check the basic structure of a workspace.
--

	function suite.onEmptyWorkspace()
		wks.projects = {}
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

	function suite.onDefaultWorkspace()
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

	function suite.onMultipleProjects()
		test.createproject(wks)
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project"/>
  <Project Name="MyProject2" Path="MyProject2.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
      <Project Name="MyProject2" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
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
		test.capture([[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject/MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]])
	end

	function suite.onExternalProjectPath()
		location "../MyProject"
		prepare()
		test.capture([[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="../MyProject/MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]])
	end


	function suite.onActiveProject()
		workspace("MyWorkspace")
		startproject "MyProject"
		prepare()
		test.capture([[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project" Active="Yes"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
      <Project Name="MyProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]])
	end


  function suite.onGroupedProjects()
    wks.projects = {}
    project "MyGrouplessProject"
    group "MyGroup"
    project "MyGroupedProject"
    group "My/Nested/Group"
    project "MyNestedGroupedProject"
    prepare()
    test.capture([[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <VirtualDirectory Name="My">
    <VirtualDirectory Name="Nested">
      <VirtualDirectory Name="Group">
        <Project Name="MyNestedGroupedProject" Path="MyNestedGroupedProject.project"/>
      </VirtualDirectory>
    </VirtualDirectory>
  </VirtualDirectory>
  <VirtualDirectory Name="MyGroup">
    <Project Name="MyGroupedProject" Path="MyGroupedProject.project"/>
  </VirtualDirectory>
  <Project Name="MyGrouplessProject" Path="MyGrouplessProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="Debug" Selected="yes">
      <Project Name="MyNestedGroupedProject" ConfigName="Debug"/>
      <Project Name="MyGroupedProject" ConfigName="Debug"/>
      <Project Name="MyGrouplessProject" ConfigName="Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="Release" Selected="no">
      <Project Name="MyNestedGroupedProject" ConfigName="Release"/>
      <Project Name="MyGroupedProject" ConfigName="Release"/>
      <Project Name="MyGrouplessProject" ConfigName="Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
    ]])
  end

---
-- Test handling of platforms
---

	function suite.onPlatforms()
		workspace "MyWorkspace"
		platforms { "x86_64", "x86" }

		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Workspace Name="MyWorkspace" Database="" SWTLW="No">
  <Project Name="MyProject" Path="MyProject.project"/>
  <BuildMatrix>
    <WorkspaceConfiguration Name="x86_64-Debug" Selected="yes">
      <Project Name="MyProject" ConfigName="x86_64-Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="x86-Debug" Selected="no">
      <Project Name="MyProject" ConfigName="x86-Debug"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="x86_64-Release" Selected="no">
      <Project Name="MyProject" ConfigName="x86_64-Release"/>
    </WorkspaceConfiguration>
    <WorkspaceConfiguration Name="x86-Release" Selected="no">
      <Project Name="MyProject" ConfigName="x86-Release"/>
    </WorkspaceConfiguration>
  </BuildMatrix>
</CodeLite_Workspace>
		]]
	end

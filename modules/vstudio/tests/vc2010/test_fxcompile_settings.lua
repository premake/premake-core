--
-- tests/actions/vstudio/vc2010/test_fxcompile_settings.lua
-- Validate FxCompile settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_fxcompile_settings")
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

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.fxCompile(cfg)
	end


---
-- Check the basic element structure with default settings.
-- Project should not generate this block if no hlsl files or no shader settings sets.
---

	function suite.empty()
		prepare()
		test.capture [[

		]]
	end


	function suite.defaultSettings()
		files { "shader.hlsl" }
		prepare()
		test.capture [[

		]]
	end

---
-- Test FxCompilePreprocessorDefinition
---

	function suite.onFxCompilePreprocessorDefinition()
		files { "shader.hlsl" }
		shaderdefines { "DEFINED_VALUE" }

		prepare()
		test.capture [[
<FxCompile>
	<PreprocessorDefinitions>DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
</FxCompile>
		]]
	end


	function suite.onFxCompilePreprocessorDefinition_multipleDefines()
		files { "shader.hlsl" }
		shaderdefines { "DEFINED_VALUE", "OTHER_DEFINED_VALUE" }

		prepare()
		test.capture [[
<FxCompile>
	<PreprocessorDefinitions>DEFINED_VALUE;OTHER_DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
</FxCompile>
		]]
	end

---
-- Test FxCompileAdditionalIncludeDirectories
---

	function suite.onFxCompileAdditionalIncludeDirectories()
		files { "shader.hlsl" }
		shaderincludedirs { "../includes" }

		prepare()
		test.capture [[
<FxCompile>
	<AdditionalIncludeDirectories>..\includes;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
</FxCompile>
		]]
	end


	function suite.onFxCompileAdditionalIncludeDirectories_multipleDefines()
		files { "shader.hlsl" }
		shaderincludedirs { "../includes", "otherpath/embedded" }

		prepare()
		test.capture [[
<FxCompile>
	<AdditionalIncludeDirectories>..\includes;otherpath\embedded;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
</FxCompile>
		]]
	end

---
-- Test FxCompileShaderType
---

	function suite.onFxCompileShaderType()
		files { "shader.hlsl" }
		shadertype "Effect"

		prepare()
		test.capture [[
<FxCompile>
	<ShaderType>Effect</ShaderType>
</FxCompile>
		]]
	end

---
-- Test FxCompileShaderModel
---

	function suite.onFxCompileShaderModel()
		files { "shader.hlsl" }
		shadermodel "5.0"

		prepare()
		test.capture [[
<FxCompile>
	<ShaderModel>5.0</ShaderModel>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderEntry
---

	function suite.onFxCompileShaderEntry()
		files { "shader.hlsl" }
		shaderentry "NewEntry"

		prepare()
		test.capture [[
<FxCompile>
	<EntryPointName>NewEntry</EntryPointName>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderVariableName
---

	function suite.onFxCompileShaderVariableName()
		files { "shader.hlsl" }
		shadervariablename "ShaderVar"

		prepare()
		test.capture [[
<FxCompile>
	<VariableName>ShaderVar</VariableName>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderHeaderOutput
---

	function suite.onFxCompileShaderHeaderOutput()
		files { "shader.hlsl" }
		shaderheaderfileoutput "%%(filename).hlsl.h"

		prepare()
		test.capture [[
<FxCompile>
	<HeaderFileOutput>%(filename).hlsl.h</HeaderFileOutput>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderObjectOutput
---

	function suite.onFxCompileShaderObjectOutput()
		files { "shader.hlsl" }
		shaderobjectfileoutput "%%(filename).hlsl.o"

		prepare()
		test.capture [[
<FxCompile>
	<ObjectFileOutput>%(filename).hlsl.o</ObjectFileOutput>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderAssembler
---

	function suite.onFxCompileShaderAssembler()
		files { "shader.hlsl" }
		shaderassembler "AssemblyCode"

		prepare()
		test.capture [[
<FxCompile>
	<AssemblerOutput>AssemblyCode</AssemblerOutput>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderAssemblerOutput
---

	function suite.onFxCompileShaderAssemblerOutput()
		files { "shader.hlsl" }
		shaderassembleroutput "%%(filename).hlsl.asm.o"

		prepare()
		test.capture [[
<FxCompile>
	<AssemblerOutputFile>%(filename).hlsl.asm.o</AssemblerOutputFile>
</FxCompile>
		]]
	end


---
-- Test FxCompileShaderAdditionalOptions
---

	function suite.onFxCompileShaderAdditionalOptions()
		files { "shader.hlsl" }
		shaderoptions "-opt"

		prepare()
		test.capture [[
<FxCompile>
	<AdditionalOptions>-opt %(AdditionalOptions)</AdditionalOptions>
</FxCompile>
		]]
	end

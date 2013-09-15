--
-- tests/actions/vstudio/cs2005/test_files.lua
-- Validate generation of <Files/> block in Visual Studio 2005 .csproj
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_files = { }
	local suite = T.vstudio_cs2005_files
	local cs2005 = premake.vstudio.cs2005


--
-- Setup
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
		cs2005.files(prj)
	end


--
-- Test grouping and nesting
--

	function suite.SimpleSourceFile()
		files { "Hello.cs" }
		prepare()
		test.capture [[
		<Compile Include="Hello.cs" />
		]]
	end

	function suite.NestedSourceFile()
		files { "Src/Hello.cs" }
		prepare()
		test.capture [[
		<Compile Include="Src\Hello.cs" />
		]]
	end


--
-- Test file dependencies
--

	function suite.SimpleResourceDependency()
		files { "Resources.resx", "Resources.Designer.cs" }
		prepare()
		test.capture [[
		<Compile Include="Resources.Designer.cs">
			<AutoGen>True</AutoGen>
			<DependentUpon>Resources.resx</DependentUpon>
		</Compile>
		<EmbeddedResource Include="Resources.resx">
			<SubType>Designer</SubType>
			<Generator>ResXFileCodeGenerator</Generator>
			<LastGenOutput>Resources.Designer.cs</LastGenOutput>
		</EmbeddedResource>
		]]
	end


--
-- Test build actions.
--

	function suite.copyAction()
		files { "Hello.txt" }
		configuration "**.txt"
		buildaction "Copy"
		prepare()
		test.capture [[
		<Content Include="Hello.txt">
			<CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
		</Content>
		]]
	end

	function suite.componentAction()
		files { "Hello.cs" }
		configuration "Hello.cs"
		buildaction "Component"
		prepare()
		test.capture [[
		<Compile Include="Hello.cs">
			<SubType>Component</SubType>
		</Compile>
		]]
	end

	function suite.formAction()
		files { "HelloForm.cs" }
		configuration "HelloForm.cs"
		buildaction "Form"
		prepare()
		test.capture [[
		<Compile Include="HelloForm.cs">
			<SubType>Form</SubType>
		</Compile>
		]]
	end

	function suite.userControlAction()
		files { "Hello.cs" }
		configuration "Hello.cs"
		buildaction "UserControl"
		prepare()
		test.capture [[
		<Compile Include="Hello.cs">
			<SubType>UserControl</SubType>
		</Compile>
		]]
	end


--
-- If a resource file has a matching .Designer.cs, the designer
-- file should be marked as auto-generated.
--

	function suite.autogenDesignerFromResource()
		files { "Hello.Designer.cs", "Hello.resx"}
		prepare()
		test.capture [[
		<Compile Include="Hello.Designer.cs">
			<AutoGen>True</AutoGen>
			<DependentUpon>Hello.resx</DependentUpon>
		</Compile>
		]]
	end

	-- test Component
	-- test UserControl


--
-- Files that exist outside the project folder should be added as
-- links, with a relative path. Weird but true.
--

	function suite.usesLink_onExternalSourceCode()
		files { "../Hello.cs" }
		prepare()
		test.capture [[
		<Compile Include="..\Hello.cs">
			<Link>Hello.cs</Link>
		</Compile>
		]]
	end

	function suite.usesLinkInFolder_onExternalSourceCode()
		files { "../Src/Hello.cs" }
		prepare()
		test.capture [[
		<Compile Include="..\Src\Hello.cs">
			<Link>Src\Hello.cs</Link>
		</Compile>
		]]
	end

	function suite.usesLinkInFolder_onExternalContent()
		files { "../Resources/Hello.txt" }
		configuration "**.txt"
		buildaction "Copy"
		prepare()
		test.capture [[
		<Content Include="..\Resources\Hello.txt">
			<Link>Resources\Hello.txt</Link>
			<CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
		</Content>
		]]
	end

	function suite.usesLinkInFolder_onExternalReference()
		files { "../Resources/Hello.txt" }
		prepare()
		test.capture [[
		<None Include="..\Resources\Hello.txt">
			<Link>Resources\Hello.txt</Link>
		</None>
		]]
	end


--
-- Files that exist outside the project's folder are allowed to be
-- placed into a folder using a virtual path, which is better than
-- dropping them at the root. Files within the project folder cannot
-- use virtual paths, because Visual Studio won't allow it.
--

	function suite.usesLinks_onVpath_onLocalSourceFile()
		files { "Hello.cs" }
		vpaths { ["Sources"] = "**.cs" }
		prepare()
		test.capture [[
		<Compile Include="Hello.cs" />
		]]
	end

	function suite.usesLinks_onVpath_onExternalSourceFile()
		files { "../Src/Hello.cs" }
		vpaths { ["Sources"] = "../**.cs" }
		prepare()
		test.capture [[
		<Compile Include="..\Src\Hello.cs">
			<Link>Sources\Hello.cs</Link>
		</Compile>
		]]
	end

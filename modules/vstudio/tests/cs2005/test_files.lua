--
-- tests/actions/vstudio/cs2005/test_files.lua
-- Validate generation of <Files/> block in Visual Studio 2005 .csproj
-- Copyright (c) 2009-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_files")
	local dn2005 = p.vstudio.dotnetbase


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		dn2005.files(prj)
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


	function suite.PerConfigFile()
		files { "Hello.cs" }
		filter { 'configurations:debug' }
			files { "HelloTwo.cs" }
		prepare()
		test.capture [[
		<Compile Include="Hello.cs" />
		<Compile Condition=" '$(Configuration)|$(Platform)' == 'Debug|x86' " Include="HelloTwo.cs" />
		]]
	end


--
-- Test file dependencies
--

	function suite.resourceDesignerDependency()
		files { "Resources.resx", "Resources.Designer.cs" }
		prepare()
		test.capture [[
		<Compile Include="Resources.Designer.cs">
			<AutoGen>True</AutoGen>
			<DependentUpon>Resources.resx</DependentUpon>
		</Compile>
		<EmbeddedResource Include="Resources.resx">
			<Generator>ResXFileCodeGenerator</Generator>
			<LastGenOutput>Resources.Designer.cs</LastGenOutput>
			<SubType>Designer</SubType>
		</EmbeddedResource>
		]]
	end


	function suite.publicResourceDesignerDependency()
		files { "Resources.resx", "Resources.Designer.cs" }
		resourcegenerator 'public'

		prepare()
		test.capture [[
		<Compile Include="Resources.Designer.cs">
			<AutoGen>True</AutoGen>
			<DependentUpon>Resources.resx</DependentUpon>
		</Compile>
		<EmbeddedResource Include="Resources.resx">
			<Generator>PublicResXFileCodeGenerator</Generator>
			<LastGenOutput>Resources.Designer.cs</LastGenOutput>
			<SubType>Designer</SubType>
		</EmbeddedResource>
		]]
	end


	function suite.settingsDesignerDependency()
		files { "Properties/Settings.settings", "Properties/Settings.Designer.cs" }
		prepare()
		test.capture [[
		<Compile Include="Properties\Settings.Designer.cs">
			<AutoGen>True</AutoGen>
			<DependentUpon>Settings.settings</DependentUpon>
			<DesignTimeSharedInput>True</DesignTimeSharedInput>
		</Compile>
		<None Include="Properties\Settings.settings">
			<Generator>SettingsSingleFileGenerator</Generator>
			<LastGenOutput>Settings.Designer.cs</LastGenOutput>
		</None>
		]]
	end

	function suite.datasetDesignerDependency()
		files { "DataSet.xsd", "DataSet.Designer.cs" }
		prepare()
		test.capture [[
		<Compile Include="DataSet.Designer.cs">
			<AutoGen>True</AutoGen>
			<DesignTime>True</DesignTime>
			<DependentUpon>DataSet.xsd</DependentUpon>
		</Compile>
		<None Include="DataSet.xsd">
			<Generator>MSDataSetGenerator</Generator>
			<LastGenOutput>DataSet.Designer.cs</LastGenOutput>
			<SubType>Designer</SubType>
		</None>
		]]
	end

	function suite.datasetDependencies()
		files { "DataSet.xsd", "DataSet.xsc", "DataSet.xss" }
		prepare()
		test.capture [[
		<None Include="DataSet.xsc">
			<DependentUpon>DataSet.xsd</DependentUpon>
		</None>
		<None Include="DataSet.xsd" />
		<None Include="DataSet.xss">
			<DependentUpon>DataSet.xsd</DependentUpon>
		</None>
		]]
	end

	function suite.textTemplatingDependency()
		files { "foobar.tt", "foobar.cs" }
		prepare()
		test.capture [[
		<Compile Include="foobar.cs">
			<AutoGen>True</AutoGen>
			<DesignTime>True</DesignTime>
			<DependentUpon>foobar.tt</DependentUpon>
		</Compile>
		<Content Include="foobar.tt">
			<Generator>TextTemplatingFileGenerator</Generator>
			<LastGenOutput>foobar.cs</LastGenOutput>
		</Content>
		]]
	end

--
-- File associations should always be made relative to the file
-- which is doing the associating.
--

	function suite.resourceDependency_inSubfolder()
		files { "Forms/TreeListView.resx", "Forms/TreeListView.cs" }
		prepare()
		test.capture [[
		<Compile Include="Forms\TreeListView.cs" />
		<EmbeddedResource Include="Forms\TreeListView.resx">
			<DependentUpon>TreeListView.cs</DependentUpon>
		</EmbeddedResource>
		]]
	end

	function suite.datasetDependency_inSubfolder()
		files { "DataSets/DataSet.xsd", "DataSets/DataSet.Designer.cs" }
		prepare()
		test.capture [[
		<Compile Include="DataSets\DataSet.Designer.cs">
			<AutoGen>True</AutoGen>
			<DesignTime>True</DesignTime>
			<DependentUpon>DataSet.xsd</DependentUpon>
		</Compile>
		<None Include="DataSets\DataSet.xsd">
			<Generator>MSDataSetGenerator</Generator>
			<LastGenOutput>DataSet.Designer.cs</LastGenOutput>
			<SubType>Designer</SubType>
		</None>
		]]
	end


--
-- Test build actions.
--

	function suite.copyAction()
		files { "Hello.txt" }
		filter "files:**.txt"
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
		filter "files:Hello.cs"
		buildaction "Component"
		prepare()
		test.capture [[
		<Compile Include="Hello.cs">
			<SubType>Component</SubType>
		</Compile>
		]]
	end

	function suite.embeddedResourceAction()
		files { "Hello.ico" }
		filter "files:*.ico"
		buildaction "Embed"
		prepare()
		test.capture [[
		<EmbeddedResource Include="Hello.ico" />
		]]
	end

	function suite.formAction()
		files { "HelloForm.cs" }
		filter "files:HelloForm.cs"
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
		filter "files:Hello.cs"
		buildaction "UserControl"
		prepare()
		test.capture [[
		<Compile Include="Hello.cs">
			<SubType>UserControl</SubType>
		</Compile>
		]]
	end

	function suite.resourceAction()
		files { "Hello.ico" }
		filter "files:*.ico"
		buildaction "Resource"
		prepare()
		test.capture [[
		<Resource Include="Hello.ico" />
		]]
	end


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
		filter "files:**.txt"
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


--
-- Check WPF XAML handling.
--

	function suite.associatesFiles_onXamlForm()
		files { "MainWindow.xaml", "MainWindow.xaml.cs" }
		prepare()
		test.capture [[
		<Page Include="MainWindow.xaml">
			<Generator>MSBuild:Compile</Generator>
			<SubType>Designer</SubType>
		</Page>
		<Compile Include="MainWindow.xaml.cs">
			<DependentUpon>MainWindow.xaml</DependentUpon>
			<SubType>Code</SubType>
		</Compile>
		]]
	end


	function suite.xamlApp_onAppXaml()
		files { "App.xaml", "App.xaml.cs" }
		prepare()
		test.capture [[
		<ApplicationDefinition Include="App.xaml">
			<Generator>MSBuild:Compile</Generator>
			<SubType>Designer</SubType>
		</ApplicationDefinition>
		<Compile Include="App.xaml.cs">
			<DependentUpon>App.xaml</DependentUpon>
			<SubType>Code</SubType>
		</Compile>
		]]
	end


	function suite.xamlApp_onBuildAction()
		files { "MyApp.xaml", "MyApp.xaml.cs" }
		filter "files:MyApp.xaml"
		buildaction "Application"
		prepare()
		test.capture [[
		<ApplicationDefinition Include="MyApp.xaml">
			<Generator>MSBuild:Compile</Generator>
			<SubType>Designer</SubType>
		</ApplicationDefinition>
		<Compile Include="MyApp.xaml.cs">
			<DependentUpon>MyApp.xaml</DependentUpon>
			<SubType>Code</SubType>
		</Compile>
		]]
	end


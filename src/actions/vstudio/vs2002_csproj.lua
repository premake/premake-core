--
-- vs2002_csproj.lua
-- Generate a Visual Studio 2002/2003 C# project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	--
	-- Figure out what elements a particular file need in its item block,
	-- based on its build action and any related files in the project.
	-- 
	local function getelements(prj, action, fname)
	
		if action == "Compile" and fname:endswith(".cs") then
			return "SubTypeCode"
		end

		if action == "EmbeddedResource" and fname:endswith(".resx") then
			-- is there a matching *.cs file?
			local basename = fname:sub(1, -6)
			local testname = path.getname(basename .. ".cs")
			if premake.findfile(prj, testname) then
				return "Dependency", testname
			end
		end
		
		return "None"
	end



	function premake.vs2002_csproj(prj)
		io.eol = "\r\n"
		_p('<VisualStudioProject>')

		_p('\t<CSHARP')
		_p('\t\tProjectType = "Local"')
		_p('\t\tProductVersion = "%s"', iif(_ACTION == "vs2002", "7.0.9254", "7.10.3077"))
		_p('\t\tSchemaVersion = "%s"', iif(_ACTION == "vs2002", "1.0", "2.0"))
		_p('\t\tProjectGuid = "{%s}"', prj.uuid)
		_p('\t>')

		_p('\t\t<Build>')
		
		-- Write out project-wide settings
		_p('\t\t\t<Settings')
		_p('\t\t\t\tApplicationIcon = ""')
		_p('\t\t\t\tAssemblyKeyContainerName = ""')
		_p('\t\t\t\tAssemblyName = "%s"', prj.buildtarget.basename)
		_p('\t\t\t\tAssemblyOriginatorKeyFile = ""')
		_p('\t\t\t\tDefaultClientScript = "JScript"')
		_p('\t\t\t\tDefaultHTMLPageLayout = "Grid"')
		_p('\t\t\t\tDefaultTargetSchema = "IE50"')
		_p('\t\t\t\tDelaySign = "false"')
		if _ACTION == "vs2002" then
			_p('\t\t\t\tNoStandardLibraries = "false"')
		end
		_p('\t\t\t\tOutputType = "%s"', premake.dotnet.getkind(prj))
		if _ACTION == "vs2003" then
			_p('\t\t\t\tPreBuildEvent = ""')
			_p('\t\t\t\tPostBuildEvent = ""')
		end
		_p('\t\t\t\tRootNamespace = "%s"', prj.buildtarget.basename)
		if _ACTION == "vs2003" then
			_p('\t\t\t\tRunPostBuildEvent = "OnBuildSuccess"')
		end
		_p('\t\t\t\tStartupObject = ""')
		_p('\t\t\t>')

		-- Write out configuration blocks		
		for cfg in premake.eachconfig(prj) do
			_p('\t\t\t\t<Config')
			_p('\t\t\t\t\tName = "%s"', premake.esc(cfg.name))
			_p('\t\t\t\t\tAllowUnsafeBlocks = "%s"', iif(cfg.flags.Unsafe, "true", "false"))
			_p('\t\t\t\t\tBaseAddress = "285212672"')
			_p('\t\t\t\t\tCheckForOverflowUnderflow = "false"')
			_p('\t\t\t\t\tConfigurationOverrideFile = ""')
			_p('\t\t\t\t\tDefineConstants = "%s"', premake.esc(table.concat(cfg.defines, ";")))
			_p('\t\t\t\t\tDocumentationFile = ""')
			_p('\t\t\t\t\tDebugSymbols = "%s"', iif(cfg.flags.Symbols, "true", "false"))
			_p('\t\t\t\t\tFileAlignment = "4096"')
			_p('\t\t\t\t\tIncrementalBuild = "false"')
			if _ACTION == "vs2003" then
				_p('\t\t\t\t\tNoStdLib = "false"')
				_p('\t\t\t\t\tNoWarn = ""')
			end
			_p('\t\t\t\t\tOptimize = "%s"', iif(cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed, "true", "false"))
			_p('\t\t\t\t\tOutputPath = "%s"', premake.esc(cfg.buildtarget.directory))
			_p('\t\t\t\t\tRegisterForComInterop = "false"')
			_p('\t\t\t\t\tRemoveIntegerChecks = "false"')
			_p('\t\t\t\t\tTreatWarningsAsErrors = "%s"', iif(cfg.flags.FatalWarnings, "true", "false"))
			_p('\t\t\t\t\tWarningLevel = "4"')
			_p('\t\t\t\t/>')
		end
		_p('\t\t\t</Settings>')

		-- List assembly references
		_p('\t\t\t<References>')
		for _, ref in ipairs(premake.getlinks(prj, "siblings", "object")) do
			_p('\t\t\t\t<Reference')
			_p('\t\t\t\t\tName = "%s"', ref.buildtarget.basename)
			_p('\t\t\t\t\tProject = "{%s}"', ref.uuid)
			_p('\t\t\t\t\tPackage = "{%s}"', _VS.tool(ref))
			_p('\t\t\t\t/>')
		end
		for _, linkname in ipairs(premake.getlinks(prj, "system", "fullpath")) do
			_p('\t\t\t\t<Reference')
			_p('\t\t\t\t\tName = "%s"', path.getbasename(linkname))
			_p('\t\t\t\t\tAssemblyName = "%s"', path.getname(linkname))
			if path.getdirectory(linkname) ~= "." then
				_p('\t\t\t\t\tHintPath = "%s"', path.translate(linkname, "\\"))
			end
			_p('\t\t\t\t/>')
		end
		_p('\t\t\t</References>')
		
		_p('\t\t</Build>')

		-- List source files
		_p('\t\t<Files>')
		_p('\t\t\t<Include>')
		for fcfg in premake.eachfile(prj) do
			local action = premake.dotnet.getbuildaction(fcfg)
			local fname  = path.translate(premake.esc(fcfg.name), "\\")
			local elements, dependency = getelements(prj, action, fcfg.name)
			
			_p('\t\t\t\t<File')
			_p('\t\t\t\t\tRelPath = "%s"', premake.esc(fname))
			_p('\t\t\t\t\tBuildAction = "%s"', action)
			if dependency then
				_p('\t\t\t\t\tDependentUpon = "%s"', premake.esc(path.translate(dependency, "\\")))
			end
			if elements == "SubTypeCode" then
				_p('\t\t\t\t\tSubType = "Code"')
			end
			_p('\t\t\t\t/>')
		end
		_p('\t\t\t</Include>')
		_p('\t\t</Files>')
		
		_p('\t</CSHARP>')
		_p('</VisualStudioProject>')

	end

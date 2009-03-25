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
		io.printf('<VisualStudioProject>')

		io.printf('\t<CSHARP')
		io.printf('\t\tProjectType = "Local"')
		io.printf('\t\tProductVersion = "%s"', iif(_ACTION == "vs2002", "7.0.9254", "7.10.3077"))
		io.printf('\t\tSchemaVersion = "%s"', iif(_ACTION == "vs2002", "1.0", "2.0"))
		io.printf('\t\tProjectGuid = "{%s}"', prj.uuid)
		io.printf('\t>')

		io.printf('\t\t<Build>')
		
		-- Write out project-wide settings
		io.printf('\t\t\t<Settings')
		io.printf('\t\t\t\tApplicationIcon = ""')
		io.printf('\t\t\t\tAssemblyKeyContainerName = ""')
		io.printf('\t\t\t\tAssemblyName = "%s"', prj.buildtarget.basename)
		io.printf('\t\t\t\tAssemblyOriginatorKeyFile = ""')
		io.printf('\t\t\t\tDefaultClientScript = "JScript"')
		io.printf('\t\t\t\tDefaultHTMLPageLayout = "Grid"')
		io.printf('\t\t\t\tDefaultTargetSchema = "IE50"')
		io.printf('\t\t\t\tDelaySign = "false"')
		if _ACTION == "vs2002" then
			io.printf('\t\t\t\tNoStandardLibraries = "false"')
		end
		io.printf('\t\t\t\tOutputType = "%s"', premake.csc.getkind(prj))
		if _ACTION == "vs2003" then
			io.printf('\t\t\t\tPreBuildEvent = ""')
			io.printf('\t\t\t\tPostBuildEvent = ""')
		end
		io.printf('\t\t\t\tRootNamespace = "%s"', prj.buildtarget.basename)
		if _ACTION == "vs2003" then
			io.printf('\t\t\t\tRunPostBuildEvent = "OnBuildSuccess"')
		end
		io.printf('\t\t\t\tStartupObject = ""')
		io.printf('\t\t\t>')

		-- Write out configuration blocks		
		for cfg in premake.eachconfig(prj) do
			io.printf('\t\t\t\t<Config')
			io.printf('\t\t\t\t\tName = "%s"', premake.esc(cfg.name))
			io.printf('\t\t\t\t\tAllowUnsafeBlocks = "%s"', iif(cfg.flags.Unsafe, "true", "false"))
			io.printf('\t\t\t\t\tBaseAddress = "285212672"')
			io.printf('\t\t\t\t\tCheckForOverflowUnderflow = "false"')
			io.printf('\t\t\t\t\tConfigurationOverrideFile = ""')
			io.printf('\t\t\t\t\tDefineConstants = "%s"', premake.esc(table.concat(cfg.defines, ";")))
			io.printf('\t\t\t\t\tDocumentationFile = ""')
			io.printf('\t\t\t\t\tDebugSymbols = "%s"', iif(cfg.flags.Symbols, "true", "false"))
			io.printf('\t\t\t\t\tFileAlignment = "4096"')
			io.printf('\t\t\t\t\tIncrementalBuild = "false"')
			if _ACTION == "vs2003" then
				io.printf('\t\t\t\t\tNoStdLib = "false"')
				io.printf('\t\t\t\t\tNoWarn = ""')
			end
			io.printf('\t\t\t\t\tOptimize = "%s"', iif(cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed, "true", "false"))
			io.printf('\t\t\t\t\tOutputPath = "%s"', premake.esc(cfg.buildtarget.directory))
			io.printf('\t\t\t\t\tRegisterForComInterop = "false"')
			io.printf('\t\t\t\t\tRemoveIntegerChecks = "false"')
			io.printf('\t\t\t\t\tTreatWarningsAsErrors = "%s"', iif(cfg.flags.FatalWarnings, "true", "false"))
			io.printf('\t\t\t\t\tWarningLevel = "4"')
			io.printf('\t\t\t\t/>')
		end
		io.printf('\t\t\t</Settings>')

		-- List assembly references
		io.printf('\t\t\t<References>')
		for _, ref in ipairs(premake.getlinks(prj, "siblings", "object")) do
			io.printf('\t\t\t\t<Reference')
			io.printf('\t\t\t\t\tName = "%s"', ref.buildtarget.basename)
			io.printf('\t\t\t\t\tProject = "{%s}"', ref.uuid)
			io.printf('\t\t\t\t\tPackage = "{%s}"', _VS.tool(ref))
			io.printf('\t\t\t\t/>')
		end
		for _, linkname in ipairs(premake.getlinks(prj, "system", "fullpath")) do
			io.printf('\t\t\t\t<Reference')
			io.printf('\t\t\t\t\tName = "%s"', path.getbasename(linkname))
			io.printf('\t\t\t\t\tAssemblyName = "%s"', path.getname(linkname))
			if path.getdirectory(linkname) ~= "." then
				io.printf('\t\t\t\t\tHintPath = "%s"', path.translate(linkname, "\\"))
			end
			io.printf('\t\t\t\t/>')
		end
		io.printf('\t\t\t</References>')
		
		io.printf('\t\t</Build>')

		-- List source files
		io.printf('\t\t<Files>')
		io.printf('\t\t\t<Include>')
		for fcfg in premake.eachfile(prj) do
			local action = premake.csc.getbuildaction(fcfg)
			local fname  = path.translate(premake.esc(fcfg.name), "\\")
			local elements, dependency = getelements(prj, action, fcfg.name)
			
			io.printf('\t\t\t\t<File')
			io.printf('\t\t\t\t\tRelPath = "%s"', premake.esc(fname))
			io.printf('\t\t\t\t\tBuildAction = "%s"', action)
			if dependency then
				io.printf('\t\t\t\t\tDependentUpon = "%s"', premake.esc(path.translate(dependency, "\\")))
			end
			if elements == "SubTypeCode" then
				io.printf('\t\t\t\t\tSubType = "Code"')
			end
			io.printf('\t\t\t\t/>')
		end
		io.printf('\t\t\t</Include>')
		io.printf('\t\t</Files>')
		
		io.printf('\t</CSHARP>')
		io.printf('</VisualStudioProject>')

	end

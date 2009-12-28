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

		_p(1,'<CSHARP')
		_p(2,'ProjectType = "Local"')
		_p(2,'ProductVersion = "%s"', iif(_ACTION == "vs2002", "7.0.9254", "7.10.3077"))
		_p(2,'SchemaVersion = "%s"', iif(_ACTION == "vs2002", "1.0", "2.0"))
		_p(2,'ProjectGuid = "{%s}"', prj.uuid)
		_p(1,'>')

		_p(2,'<Build>')
		
		-- Write out project-wide settings
		_p(3,'<Settings')
		_p(4,'ApplicationIcon = ""')
		_p(4,'AssemblyKeyContainerName = ""')
		_p(4,'AssemblyName = "%s"', prj.buildtarget.basename)
		_p(4,'AssemblyOriginatorKeyFile = ""')
		_p(4,'DefaultClientScript = "JScript"')
		_p(4,'DefaultHTMLPageLayout = "Grid"')
		_p(4,'DefaultTargetSchema = "IE50"')
		_p(4,'DelaySign = "false"')
		if _ACTION == "vs2002" then
			_p(4,'NoStandardLibraries = "false"')
		end
		_p(4,'OutputType = "%s"', premake.dotnet.getkind(prj))
		if _ACTION == "vs2003" then
			_p(4,'PreBuildEvent = ""')
			_p(4,'PostBuildEvent = ""')
		end
		_p(4,'RootNamespace = "%s"', prj.buildtarget.basename)
		if _ACTION == "vs2003" then
			_p(4,'RunPostBuildEvent = "OnBuildSuccess"')
		end
		_p(4,'StartupObject = ""')
		_p(3,'>')

		-- Write out configuration blocks		
		for cfg in premake.eachconfig(prj) do
			_p(4,'<Config')
			_p(5,'Name = "%s"', premake.esc(cfg.name))
			_p(5,'AllowUnsafeBlocks = "%s"', iif(cfg.flags.Unsafe, "true", "false"))
			_p(5,'BaseAddress = "285212672"')
			_p(5,'CheckForOverflowUnderflow = "false"')
			_p(5,'ConfigurationOverrideFile = ""')
			_p(5,'DefineConstants = "%s"', premake.esc(table.concat(cfg.defines, ";")))
			_p(5,'DocumentationFile = ""')
			_p(5,'DebugSymbols = "%s"', iif(cfg.flags.Symbols, "true", "false"))
			_p(5,'FileAlignment = "4096"')
			_p(5,'IncrementalBuild = "false"')
			if _ACTION == "vs2003" then
				_p(5,'NoStdLib = "false"')
				_p(5,'NoWarn = ""')
			end
			_p(5,'Optimize = "%s"', iif(cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed, "true", "false"))
			_p(5,'OutputPath = "%s"', premake.esc(cfg.buildtarget.directory))
			_p(5,'RegisterForComInterop = "false"')
			_p(5,'RemoveIntegerChecks = "false"')
			_p(5,'TreatWarningsAsErrors = "%s"', iif(cfg.flags.FatalWarnings, "true", "false"))
			_p(5,'WarningLevel = "4"')
			_p(4,'/>')
		end
		_p(3,'</Settings>')

		-- List assembly references
		_p(3,'<References>')
		for _, ref in ipairs(premake.getlinks(prj, "siblings", "object")) do
			_p(4,'<Reference')
			_p(5,'Name = "%s"', ref.buildtarget.basename)
			_p(5,'Project = "{%s}"', ref.uuid)
			_p(5,'Package = "{%s}"', _VS.tool(ref))
			_p(4,'/>')
		end
		for _, linkname in ipairs(premake.getlinks(prj, "system", "fullpath")) do
			_p(4,'<Reference')
			_p(5,'Name = "%s"', path.getbasename(linkname))
			_p(5,'AssemblyName = "%s"', path.getname(linkname))
			if path.getdirectory(linkname) ~= "." then
				_p(5,'HintPath = "%s"', path.translate(linkname, "\\"))
			end
			_p(4,'/>')
		end
		_p(3,'</References>')
		
		_p(2,'</Build>')

		-- List source files
		_p(2,'<Files>')
		_p(3,'<Include>')
		for fcfg in premake.eachfile(prj) do
			local action = premake.dotnet.getbuildaction(fcfg)
			local fname  = path.translate(premake.esc(fcfg.name), "\\")
			local elements, dependency = getelements(prj, action, fcfg.name)
			
			_p(4,'<File')
			_p(5,'RelPath = "%s"', premake.esc(fname))
			_p(5,'BuildAction = "%s"', action)
			if dependency then
				_p(5,'DependentUpon = "%s"', premake.esc(path.translate(dependency, "\\")))
			end
			if elements == "SubTypeCode" then
				_p(5,'SubType = "Code"')
			end
			_p(4,'/>')
		end
		_p(3,'</Include>')
		_p(2,'</Files>')
		
		_p(1,'</CSHARP>')
		_p('</VisualStudioProject>')

	end

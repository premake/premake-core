--
-- dotnet.lua
-- Interface for the C# compilers, all of which are flag compatible.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--


	local p = premake
	p.tools.dotnet = {}
	local dotnet = p.tools.dotnet
	local project = p.project
	local config = p.config


--
-- Examine the file and project configurations to glean additional
-- information about a source code in a C# project.
--
-- @param fcfg
--    The file configuration to consider.
-- @return
--    A table containing the following keys:
--
--      action:     the build action for the file; one of "Compile", "Copy",
--                  "EmbeddedResource", or "None".
--      subtype:    an additional categorization of the file type, or nil if
--                  no subtype is required.
--      dependency: a related file name, (i.e. *.Designer.cs) if appropriate
--                  for the file action and subtype.
--

	function dotnet.fileinfo(fcfg)
		local info = {}
		if (fcfg == nil) then
			return info
		end

		local fname = fcfg.abspath
		local ext = path.getextension(fname):lower()

		-- Determine the build action for the file, falling back to the file
		-- extension if no explicit action is available.

		if fcfg.buildaction == "Compile" or ext == ".cs" then
			info.action = "Compile"
		elseif fcfg.buildaction == "Embed" or ext == ".resx" then
			info.action = "EmbeddedResource"
		elseif fcfg.buildaction == "Copy" or ext == ".asax" or ext == ".aspx" or ext == ".dll" then
			info.action = "Content"
		elseif fcfg.buildaction == "Resource" then
			info.action = "Resource"
		elseif ext == ".xaml" then
			if fcfg.buildaction == "Application" or path.getbasename(fname) == "App" then
				if fcfg.project.kind == p.SHAREDLIB then
					info.action = "None"
				else
					info.action = "ApplicationDefinition"
				end
			else
				info.action = "Page"
			end
		else
			info.action = "None"
		end

		-- Try to work out any subtypes, based on the files in the project

		if info.action == "Compile" and fname:endswith(".cs") then

			if fname:endswith(".Designer.cs") then
				local basename = fname:sub(1, -13)

				-- Look for associated files: .resx, .settings, .cs, .xsd
				local testname = basename .. ".resx"
				if project.hasfile(fcfg.project, testname) then
					info.AutoGen = "True"
					info.DependentUpon = testname
				end

				testname = basename .. ".settings"
				if project.hasfile(fcfg.project, testname) then
					info.AutoGen = "True"
					info.DependentUpon = testname
					info.DesignTimeSharedInput = "True"
				end

				testname = basename .. ".cs"
				if project.hasfile(fcfg.project, testname) then
					info.AutoGen = nil
					info.SubType = "Dependency"
					info.DependentUpon = testname
				end

				testname = basename .. ".xsd"
				if project.hasfile(fcfg.project, testname) then
					info.AutoGen = "True"
					info.DesignTime = "True"
					info.DependentUpon = testname
				end

			elseif fname:endswith(".xaml.cs") then
				info.SubType = "Code"
				info.DependentUpon = fname:sub(1, -4)

			else
				local basename = fname:sub(1, -4)

				-- Is there a matching *.xsd?
				testname = basename .. ".xsd"
				if project.hasfile(fcfg.project, testname) then
					info.DependentUpon = testname
				end

				-- Is there a matching *.Designer.cs?
				testname = basename .. ".Designer.cs"
				if project.hasfile(fcfg.project, testname) then
					info.SubType = "Form"
				end

			end

			-- Allow C# object type build actions to override the default
			if fcfg.buildaction == "Component" or
			   fcfg.buildaction == "Form" or
			   fcfg.buildaction == "UserControl"
			then
				info.SubType = fcfg.buildaction
			end

			-- This flag is deprecated, will remove eventually
			if fcfg.flags and fcfg.flags.Component then
				info.SubType = "Component"
			end

		end

		if info.action == "Content" then
			info.CopyToOutputDirectory = "PreserveNewest"
		end

		if info.action == "EmbeddedResource" and fname:endswith(".resx") then
			local basename = fname:sub(1, -6)

			-- Is there a matching *.cs file?
			local testname = basename .. ".cs"
			if project.hasfile(fcfg.project, testname) then
				info.DependentUpon = testname
				if project.hasfile(fcfg.project, basename .. ".Designer.cs") then
					info.SubType = "DesignerType"
				end
			else
				-- Is there a matching *.Designer.cs?
				testname = basename .. ".Designer.cs"
				if project.hasfile(fcfg.project, testname) then
					info.SubType = "Designer"
					info.Generator = "ResXFileCodeGenerator"
					info.LastGenOutput = path.getname(testname)
				end
			end

		end

		if info.action == "None" and fname:endswith(".settings") then
			local testname = fname:sub(1, -10) .. ".Designer.cs"
			if project.hasfile(fcfg.project, testname) then
				info.Generator = "SettingsSingleFileGenerator"
				info.LastGenOutput = path.getname(testname)
			end
		end

		if info.action == "None" and fname:endswith(".xsd") then
			local testname = fname:sub(1, -5) .. ".Designer.cs"
			if project.hasfile(fcfg.project, testname) then
				info.SubType = "Designer"
				info.Generator = "MSDataSetGenerator"
				info.LastGenOutput = path.getname(testname)
			end
		end

		if info.action == "None" and (fname:endswith(".xsc") or fname:endswith(".xss")) then
			local testname = fname:sub(1, -5) .. ".xsd"
			if project.hasfile(fcfg.project, testname) then
				info.DependentUpon = testname
			end
		end

		if fname:endswith(".xaml") then
			local testname = fname .. ".cs"
			if project.hasfile(fcfg.project, testname) then
				info.SubType = "Designer"
				info.Generator = "MSBuild:Compile"
			end
		end

		if info.DependentUpon then
			info.DependentUpon = path.getname(info.DependentUpon)
		end

		return info
	end



--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "csc" for the C# compiler, or
--    "resgen" for the resource compiler.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

	function dotnet.gettoolname(cfg, tool)
		local compilers = {
			msnet = "csc",
			mono = "mcs",
			pnet = "cscc",
		}

		if tool == "csc" then
			local toolset = _OPTIONS.dotnet or iif(os.istarget("windows"), "msnet", "mono")
			return compilers[toolset]
		else
			return "resgen"
		end
	end



--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	dotnet.flags = {
		clr = {
			Unsafe = "/unsafe",
		},
		flags = {
			FatalWarning = "/warnaserror",
		},
		optimize = {
			On = "/optimize",
			Size = "/optimize",
			Speed = "/optimize",
		},
		symbols = {
			On = "/debug",
		}
	}

	function dotnet.getflags(cfg)
		local flags = config.mapFlags(cfg, dotnet.flags)

		-- Tells the compiler not to include the csc.rsp response file which
		-- it does by default and references all the assemblies shipped with
		-- the .NET Framework. VS sets this flag by default for C# projects.
		table.insert(flags, '/noconfig')

		if cfg.project.icon then
			local fn = project.getrelative(cfg.project, cfg.project.icon)
			table.insert(flags, string.format('/win32icon:"%s"', fn))
		end

		if #cfg.defines > 0 then
			table.insert(flags, table.implode(cfg.defines, "/d:", "", " "))
		end

		return table.join(flags, cfg.buildoptions)
	end



--
-- Translates the Premake kind into the CSC kind string.
--

	function dotnet.getkind(cfg)
		if (cfg.kind == "ConsoleApp") then
			return "Exe"
		elseif (cfg.kind == "WindowedApp") then
			return "WinExe"
		elseif (cfg.kind == "SharedLib") then
			return "Library"
		else
			error("invalid dotnet kind " .. cfg.kind .. ". Valid kinds are ConsoleApp, WindowsApp, SharedLib")
		end
	end


--
-- Returns makefile-specific configuration rules.
--

	function dotnet.getmakesettings(cfg)
		return nil
	end

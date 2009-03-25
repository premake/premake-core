--
-- vs2002_csproj_user.lua
-- Generate a Visual Studio 2002/2003 C# .user file.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.vs2002_csproj_user(prj)
		io.eol = "\r\n"

		io.printf('<VisualStudioProject>')
		io.printf('\t<CSHARP>')
		io.printf('\t\t<Build>')
		
		-- Visual Studio wants absolute paths
		local refpaths = table.translate(prj.libdirs, function(v) return path.getabsolute(prj.location .. "/" .. v) end)
		io.printf('\t\t\t<Settings ReferencePath = "%s">', path.translate(table.concat(refpaths, ";"), "\\"))
		
		for cfg in premake.eachconfig(prj) do
			io.printf('\t\t\t\t<Config')
			io.printf('\t\t\t\t\tName = "%s"', premake.esc(cfg.name))
			io.printf('\t\t\t\t\tEnableASPDebugging = "false"')
			io.printf('\t\t\t\t\tEnableASPXDebugging = "false"')
			io.printf('\t\t\t\t\tEnableUnmanagedDebugging = "false"')
			io.printf('\t\t\t\t\tEnableSQLServerDebugging = "false"')
			io.printf('\t\t\t\t\tRemoteDebugEnabled = "false"')
			io.printf('\t\t\t\t\tRemoteDebugMachine = ""')
			io.printf('\t\t\t\t\tStartAction = "Project"')
			io.printf('\t\t\t\t\tStartArguments = ""')
			io.printf('\t\t\t\t\tStartPage = ""')
			io.printf('\t\t\t\t\tStartProgram = ""')
			io.printf('\t\t\t\t\tStartURL = ""')
			io.printf('\t\t\t\t\tStartWorkingDirectory = ""')
			io.printf('\t\t\t\t\tStartWithIE = "false"')
			io.printf('\t\t\t\t/>')
		end
		
		io.printf('\t\t\t</Settings>')
		io.printf('\t\t</Build>')
		io.printf('\t\t<OtherProjectSettings')
		io.printf('\t\t\tCopyProjectDestinationFolder = ""')
		io.printf('\t\t\tCopyProjectUncPath = ""')
		io.printf('\t\t\tCopyProjectOption = "0"')
		io.printf('\t\t\tProjectView = "ProjectFiles"')
		io.printf('\t\t\tProjectTrust = "0"')
		io.printf('\t\t/>')
		
		io.printf('\t</CSHARP>')
		io.printf('</VisualStudioProject>')
		
	end

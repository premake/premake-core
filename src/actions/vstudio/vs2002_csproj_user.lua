--
-- vs2002_csproj_user.lua
-- Generate a Visual Studio 2002/2003 C# .user file.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.vs2002_csproj_user(prj)
		io.eol = "\r\n"

		_p('<VisualStudioProject>')
		_p('\t<CSHARP>')
		_p('\t\t<Build>')
		
		-- Visual Studio wants absolute paths
		local refpaths = table.translate(prj.libdirs, function(v) return path.getabsolute(prj.location .. "/" .. v) end)
		_p('\t\t\t<Settings ReferencePath = "%s">', path.translate(table.concat(refpaths, ";"), "\\"))
		
		for cfg in premake.eachconfig(prj) do
			_p('\t\t\t\t<Config')
			_p('\t\t\t\t\tName = "%s"', premake.esc(cfg.name))
			_p('\t\t\t\t\tEnableASPDebugging = "false"')
			_p('\t\t\t\t\tEnableASPXDebugging = "false"')
			_p('\t\t\t\t\tEnableUnmanagedDebugging = "false"')
			_p('\t\t\t\t\tEnableSQLServerDebugging = "false"')
			_p('\t\t\t\t\tRemoteDebugEnabled = "false"')
			_p('\t\t\t\t\tRemoteDebugMachine = ""')
			_p('\t\t\t\t\tStartAction = "Project"')
			_p('\t\t\t\t\tStartArguments = ""')
			_p('\t\t\t\t\tStartPage = ""')
			_p('\t\t\t\t\tStartProgram = ""')
			_p('\t\t\t\t\tStartURL = ""')
			_p('\t\t\t\t\tStartWorkingDirectory = ""')
			_p('\t\t\t\t\tStartWithIE = "false"')
			_p('\t\t\t\t/>')
		end
		
		_p('\t\t\t</Settings>')
		_p('\t\t</Build>')
		_p('\t\t<OtherProjectSettings')
		_p('\t\t\tCopyProjectDestinationFolder = ""')
		_p('\t\t\tCopyProjectUncPath = ""')
		_p('\t\t\tCopyProjectOption = "0"')
		_p('\t\t\tProjectView = "ProjectFiles"')
		_p('\t\t\tProjectTrust = "0"')
		_p('\t\t/>')
		
		_p('\t</CSHARP>')
		_p('</VisualStudioProject>')
		
	end

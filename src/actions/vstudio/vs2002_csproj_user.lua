--
-- vs2002_csproj_user.lua
-- Generate a Visual Studio 2002/2003 C# .user file.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.vs2002_csproj_user(prj)
		io.eol = "\r\n"

		_p('<VisualStudioProject>')
		_p(1,'<CSHARP>')
		_p(2,'<Build>')
		
		-- Visual Studio wants absolute paths
		local refpaths = table.translate(prj.libdirs, function(v) return path.getabsolute(prj.location .. "/" .. v) end)
		_p(3,'<Settings ReferencePath = "%s">', path.translate(table.concat(refpaths, ";"), "\\"))
		
		for cfg in premake.eachconfig(prj) do
			_p(4,'<Config')
			_p(5,'Name = "%s"', premake.esc(cfg.name))
			_p(5,'EnableASPDebugging = "false"')
			_p(5,'EnableASPXDebugging = "false"')
			_p(5,'EnableUnmanagedDebugging = "false"')
			_p(5,'EnableSQLServerDebugging = "false"')
			_p(5,'RemoteDebugEnabled = "false"')
			_p(5,'RemoteDebugMachine = ""')
			_p(5,'StartAction = "Project"')
			_p(5,'StartArguments = ""')
			_p(5,'StartPage = ""')
			_p(5,'StartProgram = ""')
			_p(5,'StartURL = ""')
			_p(5,'StartWorkingDirectory = ""')
			_p(5,'StartWithIE = "false"')
			_p(4,'/>')
		end
		
		_p(3,'</Settings>')
		_p(2,'</Build>')
		_p(2,'<OtherProjectSettings')
		_p(3,'CopyProjectDestinationFolder = ""')
		_p(3,'CopyProjectUncPath = ""')
		_p(3,'CopyProjectOption = "0"')
		_p(3,'ProjectView = "ProjectFiles"')
		_p(3,'ProjectTrust = "0"')
		_p(2,'/>')
		
		_p(1,'</CSHARP>')
		_p('</VisualStudioProject>')
		
	end

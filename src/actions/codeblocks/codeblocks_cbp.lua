--
-- codeblocks_cbp.lua
-- Generate a Code::Blocks C/C++ project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.codeblocks_cbp(prj)
		-- alias the C/C++ compiler interface
		local cc = premake.gettool(prj)
		
		_p('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>')
		_p('<CodeBlocks_project_file>')
		_p('\t<FileVersion major="1" minor="6" />')
		
		-- write project block header
		_p('\t<Project>')
		_p('\t\t<Option title="%s" />', premake.esc(prj.name))
		_p('\t\t<Option pch_mode="2" />')
		_p('\t\t<Option compiler="%s" />', _OPTIONS.cc)

		-- build a list of supported target platforms; I don't support cross-compiling yet
		local platforms = premake.filterplatforms(prj.solution, cc.platforms, "Native")
		for i = #platforms, 1, -1 do
			if premake.platforms[platforms[i]].iscrosscompiler then
				table.remove(platforms, i)
			end
		end 
		
		-- write configuration blocks
		_p('\t\t<Build>')
		for _, platform in ipairs(platforms) do		
			for cfg in premake.eachconfig(prj, platform) do
				_p('\t\t\t<Target title="%s">', premake.esc(cfg.longname))
				
				_p('\t\t\t\t<Option output="%s" prefix_auto="0" extension_auto="0" />', premake.esc(cfg.buildtarget.fullpath))
				_p('\t\t\t\t<Option object_output="%s" />', premake.esc(cfg.objectsdir))

				-- identify the type of binary
				local types = { WindowedApp = 0, ConsoleApp = 1, StaticLib = 2, SharedLib = 3 }
				_p('\t\t\t\t<Option type="%d" />', types[cfg.kind])

				_p('\t\t\t\t<Option compiler="%s" />', _OPTIONS.cc)
				
				if (cfg.kind == "SharedLib") then
					_p('\t\t\t\t<Option createDefFile="0" />')
					_p('\t\t\t\t<Option createStaticLib="%s" />', iif(cfg.flags.NoImportLib, 0, 1))
				end

				-- begin compiler block --
				_p('\t\t\t\t<Compiler>')
				for _,flag in ipairs(table.join(cc.getcflags(cfg), cc.getcxxflags(cfg), cc.getdefines(cfg.defines), cfg.buildoptions)) do
					_p('\t\t\t\t\t<Add option="%s" />', premake.esc(flag))
				end
				if not cfg.flags.NoPCH and cfg.pchheader then
					_p('\t\t\t\t\t<Add option="-Winvalid-pch" />')
					_p('\t\t\t\t\t<Add option="-include &quot;%s&quot;" />', premake.esc(cfg.pchheader))
				end
				for _,v in ipairs(cfg.includedirs) do
					_p('\t\t\t\t\t<Add directory="%s" />', premake.esc(v))
				end
				_p('\t\t\t\t</Compiler>')
				-- end compiler block --
				
				-- begin linker block --
				_p('\t\t\t\t<Linker>')
				for _,flag in ipairs(table.join(cc.getldflags(cfg), cfg.linkoptions)) do
					_p('\t\t\t\t\t<Add option="%s" />', premake.esc(flag))
				end
				for _,v in ipairs(premake.getlinks(cfg, "all", "directory")) do
					_p('\t\t\t\t\t<Add directory="%s" />', premake.esc(v))
				end
				for _,v in ipairs(premake.getlinks(cfg, "all", "basename")) do
					_p('\t\t\t\t\t<Add library="%s" />', premake.esc(v))
				end
				_p('\t\t\t\t</Linker>')
				-- end linker block --
				
				-- begin resource compiler block --
				if premake.findfile(cfg, ".rc") then
					_p('\t\t\t\t<ResourceCompiler>')
					for _,v in ipairs(cfg.includedirs) do
						_p('\t\t\t\t\t<Add directory="%s" />', premake.esc(v))
					end
					for _,v in ipairs(cfg.resincludedirs) do
						_p('\t\t\t\t\t<Add directory="%s" />', premake.esc(v))
					end
					_p('\t\t\t\t</ResourceCompiler>')
				end
				-- end resource compiler block --
				
				-- begin build steps --
				if #cfg.prebuildcommands > 0 or #cfg.postbuildcommands > 0 then
					_p('\t\t\t\t<ExtraCommands>')
					for _,v in ipairs(cfg.prebuildcommands) do
						_p('\t\t\t\t\t<Add before="%s" />', premake.esc(v))
					end
					for _,v in ipairs(cfg.postbuildcommands) do
						_p('\t\t\t\t\t<Add after="%s" />', premake.esc(v))
					end

					_p('\t\t\t\t</ExtraCommands>')
				end
				-- end build steps --
				
				_p('\t\t\t</Target>')
			end
		end
		_p('\t\t</Build>')
		
		-- begin files block --
		for _,fname in ipairs(prj.files) do
			_p('\t\t<Unit filename="%s">', premake.esc(fname))
			if path.getextension(fname) == ".rc" then
				_p('\t\t\t<Option compilerVar="WINDRES" />')
			elseif path.iscppfile(fname) then
				_p('\t\t\t<Option compilerVar="%s" />', iif(prj.language == "C", "CC", "CPP"))
				if (not prj.flags.NoPCH and fname == prj.pchheader) then
					_p('\t\t\t<Option compile="1" />')
					_p('\t\t\t<Option weight="0" />')
				end
			end
			_p('\t\t</Unit>')
		end
		-- end files block --
		
		_p('\t\t<Extensions />')
		_p('\t</Project>')
		_p('</CodeBlocks_project_file>')
		_p('')
		
	end

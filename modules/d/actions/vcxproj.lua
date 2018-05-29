--
-- d/actions/vcxproj.lua
-- Generate a VisualD .visualdproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	require ("vstudio")

	p.modules.d.vc2010 = {}

	local vc2010 = p.vstudio.vc2010
	local m = p.modules.d.vc2010

	m.elements = {}

	local vstudio = p.vstudio
	local vc2010 = p.vstudio.vc2010
	local config = p.config

--
-- Patch the dCompile step into the project items
--
	p.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local items = oldfn(cfg)
		if cfg.kind ~= p.UTILITY then
			table.insertafter(items, vc2010.clCompile, m.dCompile)
		end
		return items
	end)

--
-- Write the <DCompile> settings block.
--

	m.elements.dCompile = function(cfg)
		return {
			m.dOptimization,
			m.dImportPaths,
			m.dStringImportPaths,
			m.dVersionConstants,
			m.dDebugConstants,
			m.dCompilationModel,
			m.dRuntime,
			m.dCodeGeneration,
			m.dMessages,
			m.dDocumentation,
		}
	end

	function m.dCompile(cfg)
		if config.hasFile(cfg, path.isdfile) then
			p.push('<DCompile>')
			p.callArray(m.elements.dCompile, cfg)
			p.pop('</DCompile>')
		end
	end

---
-- DCompile group
---
	vc2010.categories.DCompile = {
		name       = "DCompile",
		extensions = { ".d" },
		priority   = 3,

		emitFiles = function(prj, group)
			local fileCfgFunc = function(fcfg, condition)
				if fcfg then
					return {
						vc2010.excludedFromBuild,
						m.dOptimization,
						m.dImportPaths,
						m.dStringImportPaths,
						m.dVersionConstants,
						m.dDebugConstants,
						m.dCompilationModel,
						m.dRuntime,
						m.dCodeGeneration,
						m.dMessages,
						m.dDocumentation,
					}
				else
					return {
						vc2010.excludedFromBuild
					}
				end
			end

			vc2010.emitFiles(prj, group, "DCompile", {m.generatedFile}, fileCfgFunc)
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "DCompile")
		end
	}

	function m.dOptimization(cfg, condition)
		local map = { Off="false", On="true", Debug="true", Full="true", Size="true", Speed="true" }
		if cfg.optimize then
			vc2010.element('Optimizer', condition, map[cfg.optimize] or "false")
		end
	end


	function m.dImportPaths(cfg, condition)
		if cfg.importdirs and #cfg.importdirs > 0 then
			local dirs = vstudio.path(cfg, cfg.importdirs)
			if #dirs > 0 then
				vc2010.element("ImportPaths", condition, "%s;%%(ImportPaths)", table.concat(dirs, ";"))
			end
		end
	end


	function m.dStringImportPaths(cfg, condition)
		if cfg.stringimportdirs and #cfg.stringimportdirs > 0 then
			local dirs = vstudio.path(cfg, cfg.stringimportdirs)
			if #dirs > 0 then
				vc2010.element("StringImportPaths", condition, "%s;%%(StringImportPaths)", table.concat(dirs, ";"))
			end
		end
	end


	function m.dVersionConstants(cfg, condition)
		if cfg.versionconstants and #cfg.versionconstants > 0 then
			local versionconstants = table.concat(cfg.versionconstants, ";")
			vc2010.element("VersionIdentifiers", condition, versionconstants)
		end
	end


	function m.dDebugConstants(cfg, condition)
		if cfg.debugconstants and #cfg.debugconstants > 0 then
			local debugconstants = table.concat(cfg.debugconstants, ";")
			vc2010.element("DebugIdentifiers", condition, debugconstants)
		end
	end


	function m.dCompilationModel(cfg, condition)
		if cfg.compilationmodel and cfg.compilationmodel ~= "Default" then
			vc2010.element("CompilationModel", condition, cfg.compilationmodel)
		end
	end


	function m.dRuntime(cfg, condition)
		if cfg.flags.OmitDefaultLibrary then
			vc2010.element("CRuntimeLibrary", condition, "None")
		else
			local releaseruntime = not config.isDebugBuild(cfg)
			local staticruntime = true
			if cfg.staticruntime == "Off" then
				staticruntime = false
			end
			if cfg.runtime == "Debug" then
				releaseruntime = false
			elseif cfg.runtime == "Release" then
				releaseruntime = true
			end
			if (cfg.staticruntime and cfg.staticruntime ~= "Default") or (cfg.runtime and cfg.runtime ~= "Default") then
				if staticruntime == true and releaseruntime == true then
					vc2010.element("CRuntimeLibrary", condition, "MultiThreaded")
				elseif staticruntime == true and releaseruntime == false then
					vc2010.element("CRuntimeLibrary", condition, "MultiThreadedDebug")
				elseif staticruntime == false and releaseruntime == true then
					vc2010.element("CRuntimeLibrary", condition, "MultiThreadedDll")
				elseif staticruntime == false and releaseruntime == false then
					vc2010.element("CRuntimeLibrary", condition, "MultiThreadedDebugDll")
				end
			end
		end
	end


	function m.dCodeGeneration(cfg, condition)
		if cfg.buildtarget then
			local ObjectFileName = ""
			if cfg.buildtarget.basename then
				if cfg.buildtarget.prefix then
					ObjectFileName = cfg.buildtarget.prefix
				end
				ObjectFileName = ObjectFileName .. cfg.buildtarget.basename .. ".obj"
			end
			if cfg.buildtarget.directory then
				local outdir = vstudio.path(cfg, cfg.buildtarget.directory)
				ObjectFileName = path.join(outdir, ObjectFileName)
			end
			vc2010.element("ObjectFileName", condition, ObjectFileName)
		end

		if cfg.optimize then
			if config.isOptimizedBuild(cfg) then
				vc2010.element("Optimizer", condition, "true")
			end
		end
		if cfg.flags.Profile then
			vc2010.element("Profile", condition, "true")
		end
		if cfg.flags.CodeCoverage then
			vc2010.element("Coverage", condition, "true")
		end
		if cfg.flags.UnitTest then
			vc2010.element("Unittest", condition, "true")
		end
		if cfg.inlining then
			local types = {
				Default = "true",
				Disabled = "false",
				Explicit = "true",
				Auto = "true",
			}
			vc2010.element("Inliner", condition, types[cfg.inlining])
		end
		if cfg.boundscheck and cfg.boundscheck ~= "Default" then
			local types = {
				Off = "Off",
				SafeOnly = "SafeOnly",
				On = "On",
			}
			vc2010.element("BoundsCheck", condition, types[cfg.boundscheck])
		end
--		if cfg.debugcode then
--			local types = {
--				DebugFull = "Debug",
--				DebugLight = "Default",
--				Release = "Release",
--			}
--			vc2010.element("DebugCode", condition, types[cfg.debugcode])
--		end
		if cfg.symbols then
			if cfg.symbols == p.Off then
				vc2010.element("DebugInfo", condition, "None")
			elseif cfg.symbols ~= "Default" then
				vc2010.element("DebugInfo", condition, iif(cfg.flags.SymbolsLikeC, "VS", "Mago"))
			end
		end
		if cfg.flags.ProfileGC then
			vc2010.element("ProfileGC", condition, "true")
		end
		if cfg.flags.StackFrame then
			vc2010.element("StackFrame", condition, "true")
		end
		if cfg.flags.StackStomp then
			vc2010.element("StackStomp", condition, "true")
		end
		if cfg.flags.AllTemplateInst then
			vc2010.element("AllInst", condition, "true")
		end
		if cfg.flags.BetterC then
			vc2010.element("BetterC", condition, "true")
		end
		if cfg.flags.Main then
			vc2010.element("Main", condition, "true")
		end
		if cfg.flags.PerformSyntaxCheckOnly then
			vc2010.element("PerformSyntaxCheckOnly", condition, "true")
		end
	end


	function m.dMessages(cfg, condition)
		if cfg.warnings == p.OFF then
			vc2010.element("Warnings", condition, "None")
		elseif cfg.warnings and cfg.warnings ~= "Default" then
			vc2010.element("Warnings", condition, iif(cfg.flags.FatalCompileWarnings, "Error", "Info"))
		end
		if cfg.deprecatedfeatures and cfg.deprecatedfeatures ~= "Default" then
			local types = {
				Error = "Error",
				Warn = "Info",
				Allow = "Allow",
			}
			vc2010.element("Deprecations", condition, types[cfg.deprecatedfeatures])
		end
		if cfg.flags.ShowCommandLine then
			vc2010.element("ShowCommandLine", condition, "true")
		end
		if cfg.flags.Verbose then
			vc2010.element("Verbose", condition, "true")
		end
		if cfg.flags.ShowTLS then
			vc2010.element("ShowTLS", condition, "true")
		end
		if cfg.flags.ShowGC then
			vc2010.element("ShowGC", condition, "true")
		end
		if cfg.flags.IgnorePragma then
			vc2010.element("IgnorePragma", condition, "true")
		end
		if cfg.flags.ShowDependencies then
			vc2010.element("ShowDependencies", condition, "true")
		end
	end


	function m.dDocumentation(cfg, condition)
		if cfg.docdir then
			vc2010.element("DocDir", condition, cfg.docdir)
		end
		if cfg.docname then
			vc2010.element("DocFile", condition, cfg.docname)
		end
		if cfg.dependenciesfile then
			vc2010.element("DepFile", condition, cfg.dependenciesfile)
		end
		if cfg.headerdir then
			vc2010.element("HeaderDir", condition, cfg.headerdir)
		end
		if cfg.headername then
			vc2010.element("HeaderFile", condition, cfg.headername)
		end
		if cfg.jsonfile then
			vc2010.element("JSONFile", condition, cfg.jsonfile)
		end
	end

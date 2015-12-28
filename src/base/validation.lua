---
-- base/validation.lua
--
-- Verify the contents of the project object before handing them off to
-- the action/exporter.
--
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	premake.validation = {}
	local m = premake.validation

	local p = premake

	m.elements = {}


---
-- Validate the global container and all of its contents.
---

	m.elements.global = function(glb)
		return {
		}
	end

	function p.global.validate(self)
		p.callArray(m.elements.global, self)
		p.container.validateChildren(self)
	end



---
-- Validate a workspace and its projects.
---

	m.elements.workspace = function(wks)
		return {
			m.workspaceHasConfigs,
			m.uniqueProjectIds,
		}
	end

	function p.workspace.validate(self)
		p.callArray(m.elements.workspace, self)
		p.container.validateChildren(self)
	end



---
-- Validate a project and its configurations.
---

	m.elements.project = function(prj)
		return {
			m.projectHasLanguage,
			m.actionSupportsLanguage,
			m.actionSupportsKind,
			m.projectRulesExist,
			m.projectValuesInScope,
		}
	end

	function p.project.validate(self)
		p.callArray(m.elements.project, self)
		for cfg in p.project.eachconfig(self) do
			p.config.validate(cfg)
		end
	end



---
-- Validate a project configuration.
---

	m.elements.config = function(cfg)
		return {
			m.configHasKind,
			m.configSupportsKind,
			m.configValuesInScope,
		}
	end

	function p.config.validate(self)
		p.callArray(m.elements.config, self)

	end



---
-- Validate a rule.
---

	m.elements.rule = function(rule)
		return {
			-- TODO: fill this in
		}
	end

	function p.rule.validate(self)
		p.callArray(m.elements.rule, self)
	end



---
-- Check the values stored in a configuration for values that might have
-- been set out of scope.
--
-- @param container
--    The container being validated; will only check fields which are
--    scoped to this container's class hierarchy.
-- @param expectedScope
--    The expected scope of values in this object, i.e. "project", "config".
--    Values that appear unexpectedly get checked to be sure they match up
--    with the values in the expected scope, and an error is raised if they
--    are not the same.
---

	function p.config.validateScopes(self, container, expected)
		for f in p.field.each() do
			-- If this field scoped to the target container class? If not
			-- I can skip over it (config scope applies to everything).
			local scope
			for i = 1, #f.scopes do
				if f.scopes[i] == "config" or p.container.classIsA(container.class, f.scopes[i]) then
					scope = f.scopes[i]
					break
				end
			end

			local okay = (not scope or scope == "config")

			-- Skip over fields that are at or below my expected scope.
			okay = okay or scope == expected

			-- Skip over fields that bubble up to their parent containers anyway;
			-- these can't be out of scope for that reason
			okay = okay or p.oven.bubbledFields[f.name]

			-- this one needs to checked
			okay = okay or p.field.compare(f, self[scope][f.name], self[f.name])

			-- found a problem?
			if not okay then
				local key = "validate." .. f.name
				p.warnOnce(key, "'%s' on %s '%s' differs from %s '%s'; may be set out of scope", f.name, expected, self.name, scope, self[scope].name)
			end
		end
	end



---------------------------------------------------------------------------
--
-- Handlers for individual checks
--
---------------------------------------------------------------------------

	function m.actionSupportsKind(prj)
		if not p.action.supports(prj.kind) then
			p.warn("unsupported kind '%s' used for project '%s'", prj.kind, prj.name)
		end
	end


	function m.actionSupportsLanguage(prj)
		if not p.action.supports(prj.language) then
			p.warn("unsupported language '%s' used for project '%s'", prj.language, prj.name)
		end
	end


	function m.configHasKind(cfg)
		if not cfg.kind then
			p.error("project '%s' needs a kind in configuration '%s'", cfg.project.name, cfg.name)
		end
	end


	function m.configSupportsKind(cfg)
		-- makefile configuration can only appear in C++ projects; this is the
		-- default now, so should only be a problem if overridden.
		if (cfg.kind == p.MAKEFILE or cfg.kind == p.NONE) and not p.project.iscpp(cfg.project) then
			p.error("project '%s' uses %s kind in configuration '%s'; language must be C++", cfg.project.name, cfg.kind, cfg.name)
		end
	end


	function m.configValuesInScope(cfg)
		p.config.validateScopes(cfg, cfg.project, "config")
	end


	function m.projectHasLanguage(prj)
		if not prj.language then
			p.error("project '%s' does not have a language", prj.name)
		end
	end


	function m.projectRulesExist(prj)
		for i = 1, #prj.rules do
			local rule = prj.rules[i]
			if not p.global.getRule(rule) then
				p.error("project '%s' uses missing rule '%s'", prj.name, rule)
			end
		end
	end


	function m.projectValuesInScope(prj)
		p.config.validateScopes(prj, prj, "project")
	end


	function m.uniqueProjectIds(wks)
		local uuids = {}
		for prj in p.workspace.eachproject(wks) do
			if uuids[prj.uuid] then
				p.error("projects '%s' and '%s' have the same UUID", uuids[prj.uuid], prj.name)
			end
			uuids[prj.uuid] = prj.name
		end
	end


	function m.workspaceHasConfigs(wks)
		if not wks.configurations or #wks.configurations == 0 then
			p.error("workspace '%s' does not contain any configurations", wks.name)
		end
	end

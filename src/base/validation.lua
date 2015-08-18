---
-- base/validation.lua
--
-- Verify the contents of the project object before handing them off to
-- the action/exporter.
--
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
---

	local p = premake



---
-- Validate the global container and all of its contents.
---

	function p.global.validate(self)
		p.container.validateChildren(self)
	end



---
-- Validate a workspace and its projects.
---

	function p.workspace.validate(self)
		-- there must be at least one build configuration
		if not self.configurations or #self.configurations == 0 then
			p.error("workspace '%s' does not contain any configurations", self.name)
		end

		-- all project UUIDs must be unique
		local uuids = {}
		for prj in p.workspace.eachproject(self) do
			if uuids[prj.uuid] then
				p.error("projects '%s' and '%s' have the same UUID", uuids[prj.uuid], prj.name)
			end
			uuids[prj.uuid] = prj.name
		end

		p.container.validateChildren(self)
	end



---
-- Validate a project and its configurations.
---

	function p.project.validate(self)
		-- must have a language
		if not self.language then
			p.error("project '%s' does not have a language", self.name)
		end

		if not p.action.supports(self.language) then
			p.warn("unsupported language '%s' used for project '%s'", self.language, self.name)
		end

		if not p.action.supports(self.kind) then
			p.warn("unsupported kind '%s' used for project '%s'", self.kind, self.name)
		end

		-- all rules must exist
		for i = 1, #self.rules do
			local rule = self.rules[i]
			if not p.global.getRule(rule) then
				p.error("project '%s' uses missing rule '%s'", self.name, rule)
			end
		end

		-- check for out of scope fields
		p.config.validateScopes(self, self, "project")

		for cfg in p.project.eachconfig(self) do
			p.config.validate(cfg)
		end
	end



---
-- Validate a project configuration.
---

	function p.config.validate(self)
		-- must have a kind
		if not self.kind then
			p.error("project '%s' needs a kind in configuration '%s'", self.project.name, self.name)
		end

		-- makefile configuration can only appear in C++ projects; this is the
		-- default now, so should only be a problem if overridden.
		if (self.kind == p.MAKEFILE or self.kind == p.NONE) and not p.project.iscpp(self.project) then
			p.error("project '%s' uses %s kind in configuration '%s'; language must be C++", self.project.name, self.kind, self.name)
		end

		-- check for out of scope fields
		p.config.validateScopes(self, self.project, "config")
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



---
-- Validate a rule.
---

	function p.rule.validate(self)
		-- TODO: fill this in
	end


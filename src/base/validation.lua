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
-- Validate a solution and its projects.
---

	function p.solution.validate(self)
		-- there must be at least one build configuration
		if not self.configurations or #self.configurations == 0 then
			p.error("solution '%s' does not contain any configurations", self.name)
		end

		-- all project UUIDs must be unique
		local uuids = {}
		for prj in p.solution.eachproject(self) do
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

		-- all rules must exist
		for i = 1, #self.rules do
			local rule = self.rules[i]
			if not p.global.getRule(rule) then
				p.error("project '%s' uses missing rule '%s'", self.name, rule)
			end
		end

		-- check for out of scope fields
		p.config.validateScopes(self, "project")

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
		p.config.validateScopes(self, "config")
	end



---
-- Check the values stored in a configuration for values that might have
-- been set out of scope.
--
-- @param expected
--    The expected scope of values in this object; one of "project" or "config".
---

	function p.config.validateScopes(self, expected)
		for f in p.field.each() do
			-- Get the field's scope
			-- TODO: This whole scope validation needs to be generalized
			-- now that containers are in place. For now, ignore rule
			-- containers until I can make things work properly.
			local scope
			if f.scopes[1] ~= "rule" then
				scope = f.scopes[1]
			end

			-- Skip fields that are at or below the expected scope. Config-
			-- level fields are the most general (can be applied to projects
			-- or solutions) and so can never be out of scope.
			local okay = (not scope or scope == "config" or scope == expected or p.oven.bubbledFields[f.name])

			-- this one needs to checked
			if not okay then
				okay = p.field.compare(f, self[scope][f.name], self[f.name])
			end

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


---
-- base/rule.lua
-- Defines rule sets for generated custom rule files.
-- Copyright (c) 2014 Jess Perkins and the Premake project
---

	local p = premake
	p.rule = p.api.container("rule", p.global)

	local rule = p.rule



---
-- Create a new rule container instance.
---

	function rule.new(name)
		local self = p.container.new(rule, name)

		-- create a variable setting function. Do a version with lowercased
		-- first letter(s) to match Premake's naming style for other calls

		_G[name .. "Vars"] = function(vars)
			rule.setVars(self, vars)
		end

		local lowerName =  name:gsub("^%u+", string.lower)
		_G[lowerName .. "Vars"] = _G[name .. "Vars"]

		return self
	end



---
-- Enumerate the property definitions for a rule.
---

	function rule.eachProperty(self)
		local props = self.propertydefinition
		local i = 0
		return function ()
			i = i + 1
			if i <= #props then
				return props[i]
			end
		end
	end



---
-- Find a property definition by its name.
--
-- @param name
--    The property name.
-- @returns
--    The property definition if found, nil otherwise.
---

	function rule.getProperty(self, name)
		local props = self.propertydefinition
		for i = 1, #props do
			local prop = props[i]
			if prop.name == name then
				return prop
			end
		end
	end



---
-- Find the field definition for one this rule's properties. This field
-- can then be used with the api.* functions to manipulate the property's
-- values in the current configuration scope.
--
-- @param prop
--    The property definition.
-- @return
--    The field definition for the property; this will be created if it
--    does not already exist.
---

	function rule.getPropertyField(self, prop)
		if prop._field then
			return prop._field
		end

		local kind = prop.kind or "string"
		if kind == "list" then
			kind = "list:string"
		end

		local fld = p.field.new {
			name = "_rule_" .. self.name .. "_" .. prop.name,
			scope = "config",
			kind = kind,
			tokens = true,
		}

		prop._field = fld
		return fld
	end



---
-- Set one or more rule variables in the current configuration scope.
--
-- @param vars
--    A key-value list of variables to set and their corresponding values.
---

	function rule.setVars(self, vars)
		for key, value in pairs(vars) do
			local prop = rule.getProperty(self, key)
			if not prop then
				error (string.format("rule '%s' does not have property '%s'", self.name, key))
			end

			local fld = rule.getPropertyField(self, prop)
			p.api.storeField(fld, value)
		end
	end



---
-- prepare an environment with the rule properties as global tokens,
-- according to the format specified.
--
-- @param environ
--    The environment table to fill up
-- @param format
--    The formatting to be used, ie "[%s]".
---
	function rule.createEnvironment(self, format)
		local environ = {}
		for _, def in ipairs(self.propertydefinition) do
			environ[def.name] = string.format(format, def.name)
		end
		return environ
	end

---
-- prepare an table of pathVars with the rule properties as global tokens,
-- according to the format specified.
--
-- @param pathVars
--    The pathVars table to fill up
-- @param format
--    The formatting to be used, ie "%%(%s)".
---

	function rule.preparePathVars(self, pathVars, format)
		for _, def in ipairs(self.propertydefinition) do
			pathVars[def.name] = { absolute = true,  token = string.format(format, def.name) }
		end
	end

	function rule.createPathVars(self, format)
		local pathVars = {}
		rule.preparePathVars(self, pathVars, format)
		return pathVars
	end

	function rule.prepareEnvironment(self, environ, cfg)
		local function path(cfg, value)
			cfg = cfg.project or cfg
			local dirs = path.translate(project.getrelative(cfg, value))

			if type(dirs) == 'table' then
				dirs = table.filterempty(dirs)
			end

			return dirs
		end

		local function expandRuleString(prop, value)
			-- list
			if type(value) == "table" then
				if #value > 0 then
					local switch = prop.switch or ""
					if prop.separator then
						return switch .. table.concat(value, prop.separator)
					else
						return switch .. table.concat(value, " " .. switch)
					end
				else
					return nil
				end
			end

			-- bool just emits the switch
			if prop.switch and type(value) == "boolean" then
				if value then
					return prop.switch
				else
					return nil
				end
			end

			-- enum
			if prop.values then
				local switch = prop.switch or {}
				value = table.findKeyByValue(prop.values, value)
				if value == nil then
					return nil
				end
				return switch[value]
			end

			-- primitive
			local switch = prop.switch or ""
			value = tostring(value)
			if #value > 0 then
				return switch .. value
			else
				return nil
			end
		end

		for _, prop in ipairs(self.propertydefinition) do
			local fld = p.rule.getPropertyField(self, prop)
			local value = cfg[fld.name]
			if value ~= nil then

				if fld.kind == "path" then
					value = path(cfg, value)
				elseif fld.kind == "list:path" then
					value = path(cfg, value)
				end

				value = expandRuleString(prop, value)
				if value ~= nil and #value > 0 then
					environ[prop.name] = p.esc(value)
				end
			end
		end
	end

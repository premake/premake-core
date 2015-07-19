---
-- action.lua
-- Work with the list of registered actions.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake
	p.action = {}

	local action = premake.action



--
-- Process the raw command line arguments from _ARGV to populate
-- the _ACTION global and _ARGS table.
--

	_ACTION = nil
	_ARGS = {}

	for i, arg in ipairs(_ARGV) do
		if not arg:startswith("/") and not arg:startswith("--") then
			if not _ACTION then
				_ACTION = arg
			else
				table.insert(_ARGS, arg)
				_ARGS[arg] = arg
			end
		end
	end



--
-- The list of registered actions. Calls to newaction() will add
-- new entries here.
--

	action._list = {}


---
-- Register a new action.
--
-- @param act
--    The new action object.
---

	function action.add(act)
		-- validate the action object, at least a little bit
		local missing
		for _, field in ipairs({"description", "trigger"}) do
			if not act[field] then
				missing = field
			end
		end

		if missing then
			local name = act.trigger or ""
			error(string.format('action "%s" needs a  %s', name, missing), 3)
		end

		action._list[act.trigger] = act
	end


---
-- Trigger an action.
--
-- @param name
--    The name of the action to be triggered.
---

	function action.call(name)
		local act = action._list[name]

		if act.onStart then
			act.onStart()
		end

		for sln in p.global.eachSolution() do
			local onSolution = act.onSolution or act.onsolution
			if onSolution and not sln.external then
				onSolution(sln)
			end

			for prj in p.solution.eachproject(sln) do
				local onProject = act.onProject or act.onproject
				if onProject and not prj.external then
					onProject(prj)
				end
			end
		end

		for rule in p.global.eachRule() do
			local onRule = act.onRule or act.onrule
			if onRule and not rule.external then
				onRule(rule)
			end
		end

		if act.execute then
			act.execute()
		end

		if act.onEnd then
			act.onEnd()
		end
	end


---
-- Retrieve the current action, as determined by _ACTION.
--
-- @return
--    The current action, or nil if _ACTION is nil or does not match any action.
---

	function action.current()
		return action.get(_ACTION)
	end


---
-- Retrieve an action by name.
--
-- @param name
--    The name of the action to retrieve.
-- @returns
--    The requested action, or nil if the action does not exist.
---

	function action.get(name)
		-- "Next-gen" actions are deprecated
		if name and name:endswith("ng") then
			name = name:sub(1, -3)
		end
		return action._list[name]
	end


---
-- Iterator for the list of actions.
---

	function action.each()
		-- sort the list by trigger
		local keys = { }
		for _, act in pairs(action._list) do
			table.insert(keys, act.trigger)
		end
		table.sort(keys)

		local i = 0
		return function()
			i = i + 1
			return action._list[keys[i]]
		end
	end


---
-- Determines if an action makes use of the configuration information
-- provided by the project scripts (i.e. it is an exporter) or if it
-- simply performs an action irregardless of configuration, in which
-- case the baking and validation phases can be skipped.
---

	function action.isConfigurable(self)
		if not self then
			self = action.current() or {}
		end
		if self.onSolution or self.onsolution then
			return true
		end
		if self.onProject or self.onproject then
			return true
		end
		return false
	end



---
-- Activates a particular action.
--
-- @param name
--    The name of the action to activate.
---

	function action.set(name)
		_ACTION = name

		-- Some actions imply a particular operating system
		local act = action.get(name)
		if act then
			_OS = act.os or _OS
		end

		-- Some are implemented in standalone modules
		if act and act.module then
			require(act.module)
		end
	end


---
-- Determines if an action supports a particular language or target type.
--
-- @param feature
--    The feature to check, either a programming language or a target type.
-- @returns
--    True if the feature is supported, false otherwise.
---

	function action.supports(feature)
		if not feature then
			return true
		end
		local self = action.current()
		if not self then
			return false
		end
		if self.valid_languages then
			if table.contains(self.valid_languages, feature) then
				return true
			end
		end
		if self.valid_kinds then
			if table.contains(self.valid_kinds, feature) then
				return true
			end
		end
		return false
	end


--
-- Determines if an action supports a particular configuration.
-- @return
-- True if the configuration is supported, false otherwise.
--
	function premake.action.supportsconfig(action, cfg)
		if not action then
			return false
		end
		if action.supportsconfig then
			return action.supportsconfig(cfg)
		end
		return true
	end

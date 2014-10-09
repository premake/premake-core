---
-- action.lua
-- Work with the list of registered actions.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
---

	premake.action = {}
	local action = premake.action

	local p = premake



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
			end
		end
	end



--
-- The list of registered actions. Calls to newaction() will add
-- new entries here.
--

	action._list = {}


--
-- Register a new action.
--
-- @param act
--    The new action object.
--

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

		-- add it to the master list
		action._list[act.trigger] = act
	end


--
-- Trigger an action.
--
-- @param name
--    The name of the action to be triggered.
-- @returns
--    None.
--

	function action.call(name)
		local act = action._list[name]

		for sln in p.solution.each() do
			if act.onsolution then
				act.onsolution(sln)
			end
			for prj in p.solution.eachproject(sln) do
				if act.onproject and not prj.external then
					act.onproject(prj)
				end
			end
		end

		for rule in p.rule.each() do
			if act.onrule then
				act.onrule(rule)
			end
		end

		if act.execute then
			act.execute()
		end
	end


--
-- Retrieve the current action, as determined by _ACTION.
--
-- @return
--    The current action, or nil if _ACTION is nil or does not match any action.
--

	function action.current()
		return action.get(_ACTION)
	end


--
-- Retrieve an action by name.
--
-- @param name
--    The name of the action to retrieve.
-- @returns
--    The requested action, or nil if the action does not exist.
--

	function action.get(name)
		-- "Next-gen" actions are deprecated
		if name and name:endswith("ng") then
			name = name:sub(1, -3)
		end
		return action._list[name]
	end


--
-- Iterator for the list of actions.
--

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
			return act._list[keys[i]]
		end
	end


--
-- Activates a particular action.
--
-- @param name
--    The name of the action to activate.
--

	function action.set(name)
		_ACTION = name

		-- Some actions imply a particular operating system
		local act = action.get(name)
		if act then
			_OS = act.os or _OS
		end
	end


--
-- Determines if an action supports a particular language or target type.
--
-- @param act
--    The action to test.
-- @param feature
--    The feature to check, either a programming language or a target type.
-- @returns
--    True if the feature is supported, false otherwise.
--

	function action.supports(act, feature)
		if not act then
			return false
		end
		if act.valid_languages then
			if table.contains(act.valid_languages, feature) then
				return true
			end
		end
		if act.valid_kinds then
			if table.contains(act.valid_kinds, feature) then
				return true
			end
		end
		return false
	end



--
-- Determines if an action supports a particular configuration.
-- @return
--    True if the configuration is supported, false otherwise.
--

	function action.supportsconfig(act, cfg)
		if not act then
			return false
		end

		if act.supportsconfig then
			return act.supportsconfig(cfg)
		end

		return true
	end


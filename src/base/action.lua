---
-- action.lua
-- Work with the list of registered actions.
-- Copyright (c) 2002-2015 Jess Perkins and the Premake project
---

	local p = premake
	p.action = {}

	local action = p.action



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

		if act.os ~= nil then
			p.warnOnce(act.trigger, "action '" .. act.trigger .. "' sets 'os' field, which is deprecated, use 'targetos' instead.")
			act.targetos = act.os
			act.os = nil
		end

		action._list[act.trigger] = act
	end



---
-- Initialize an action.
--
-- @param name
--    The name of the action to be initialized.
---

	function action.initialize(name)
		local a = action._list[name]
		if (a.onInitialize) then
			a.onInitialize()
		end
	end



---
-- Trigger an action.
--
-- @param name
--    The name of the action to be triggered.
---

	function action.call(name)
		local a = action._list[name]

		if a.onStart then
			a.onStart()
		end

		for wks in p.global.eachWorkspace() do
			local onWorkspace = a.onWorkspace or a.onSolution or a.onsolution
			if onWorkspace and not wks.external then
				onWorkspace(wks)
			end

			for prj in p.workspace.eachproject(wks) do
				local onProject = a.onProject or a.onproject
				if onProject and not prj.external then
					onProject(prj)
				end
			end
		end

		for rule in p.global.eachRule() do
			local onRule = a.onRule or a.onrule
			if onRule and not rule.external then
				onRule(rule)
			end
		end

		if a.execute then
			a.execute()
		end

		if a.onEnd then
			a.onEnd()
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
		if self.onWorkspace or self.onSolution or self.onsolution then
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

		-- Some actions imply a particular operating system or architecture
		local act = action.get(name)
		if act then
			_TARGET_OS = act.targetos or _TARGET_OS
			_TARGET_ARCH =  act.targetarch or _TARGET_ARCH
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

		if not self.valid_languages and not self.valid_kinds then
			return true
		end

		if self.valid_languages and table.contains(self.valid_languages, feature) then
			return true
		end

		if self.valid_kinds and table.contains(self.valid_kinds, feature) then
			return true
		end

		return false
	end

---
-- Determines if an action supports a particular toolset.
--
-- @param language
--    The language that toolset belongs.
-- @param toolset
--    The toolset to check.
-- @returns
--    True if the toolset is supported, false otherwise.
---
	function action.supportsToolset(language, toolset)
		if not language or not toolset then
			return true
		end
		local self = action.current()
		if not self then
			return false
		end
		local language_keys_map = {
			["C"] = "cc",
			["C++"] = "cc",
			["C#"] = "dotnet",
			["D"] = "dc",
		}
		local language_key = language_keys_map[language]
		if not language_key then
			p.warn("Unknown mapping for language %s", language)
			return true
		end
		if not self.valid_tools then
			return true
		end
		local valid_tools = self.valid_tools[language_key]
		if not valid_tools then
			return true
		end
		toolset = p.tools.normalize(toolset)
		toolset = toolset:explode("-", true, 1)[1] -- get rid of version

		return table.contains(valid_tools, toolset)
	end

--
-- Determines if an action supports a particular configuration.
-- @return
-- True if the configuration is supported, false otherwise.
--
	function p.action.supportsconfig(action, cfg)
		if not action then
			return false
		end
		if action.supportsconfig then
			return action.supportsconfig(cfg)
		end
		return true
	end

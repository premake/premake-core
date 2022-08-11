local State = require('state')
local Type = require('type')

local Config = Type.declare('Config', State)


---
-- Instantiate a new configuration helper.
--
-- @param state
--    The configuration state.
-- @returns
--    A new configuration helper instance.
---

function Config.new(state)
	local cfg = Type.assign(Config, state)

	cfg.configuration = state.configurations[1]
	cfg.platform = state.platforms[1]
	cfg.name = table.concat({ cfg.configuration, cfg.platform }, '|')

	return cfg
end


---
-- Given a container state (i.e. workspace or project), returns a list of build
-- configuration and platform pairs for that state, as an array of query selectors
-- suitable for passing to `State.selectAny()`, ex.
--
--     { configurations = 'Debug', platforms = 'x86_64' }
---

function Config.fetchConfigPlatformPairs(state)
	local configs = state.configurations
	local platforms = state.platforms

	local results = {}

	for i = 1, #configs do
		if #platforms == 0 then
			table.insert(results, {
				configurations = configs[i]
			})
		else
			for j = 1, #platforms do
				table.insert(results, {
					configurations = configs[i],
					platforms = platforms[j]
				})
			end
		end
	end

	return results
end


return Config

local State = require('state')
local Type = require('type')

local dom = select(1, ...)

local Block = Type.declare('Block', State)


---
-- Instantiate a new block configuration helper.
--
-- @param state
--    The block configuration state.
-- @returns
--    The new block helper instance.
---

function Block.new(state)
    local blk = Type.assign(Block, state)

    local name = state.blocks[1]
    blk.name = name

    return blk
end


---
-- Retrieve the configurations contained by this block.
--
-- @param createCallback
--    A function with signature `(workspace, build, platform)` which will be called for
--    each build/platform pair found in the block.  Return a new `dom.Config` to represent
--    the configuration, or `nil` to ignore it.
-- @returns
--    An array of `dom.Config`.
---

function Block.fetchConfigs(self, createCallback)
    local configs = {}

    local selectors = dom.Config.fetchConfigPlatformPairs(self)
    for i = 1, #selectors do
        local selector = selectors[i]
        local cfg = createCallback(self, selector.configurations, selector.platforms)
        configs[i] = cfg
        configs[cfg.name] = cfg
    end

    return configs
end


return Block

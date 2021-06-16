---
-- Stub out problematic Lua functions while tests are running.
---

local testing = select(1, ...)


testing.onBeforeTest(function()
end)


testing.onAfterTest(function()
end)

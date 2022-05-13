---
-- Registers GCC as a valid toolset.
---
local toolset = require('toolsets')
toolset.register('gcc', require('gcc'))

local premake = require('premake')
local dom = require('dom')

local DomBlockTests = test.declare('DomBlockTests', 'dom')

local _blk


---
-- Sets up the DOM Block Tests.
---
function DomBlockTests.setup()
    block('MyBlock', function()
        
    end)

    _blk = dom.Block.new(dom.Root.new():select({ blocks = 'MyBlock' }))
end


---
-- Tests to make sure the name of the Block element is set correctly.
---
function DomBlockTests.new_setsName()
    test.isEqual('MyBlock', _blk.name)
end
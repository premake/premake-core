local Store = require('store')

local StoreTests = test.declare('StoreTests', 'store')


local store

function StoreTests.setup()
	store = Store.new()
end


---
-- `new()` should return an object and not crash.
---

function StoreTests.new_returnsObject()
	test.isNotNil(store)
end

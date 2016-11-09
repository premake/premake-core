---
-- tests/base/test_softrequire.lua
-- Test optional module loading.
-- Copyright (c) 2016 Jason Perkins and the Premake project
---

	local suite = test.declare("base_softrequire")


---
-- Soft require of existing module should return the module.
---

	function suite.returnsModule_onExistingModule()
		test.isnotnil(softrequire("self-test"))
	end


---
-- Soft require of non-existent module should return nil.
---

	function suite.returnsNil_onMissingModule()
		test.isnil(softrequire("no-such-module"))
	end

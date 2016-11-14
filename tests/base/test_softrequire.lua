---
-- tests/base/test_softrequire.lua
-- Test optional module loading.
-- Copyright (c) 2016 Jason Perkins and the Premake project
---

	local suite = test.declare("base_softrequire")

	local TEST_MODULE = {
		_VERSION = "5.0"
	}


	function suite.setup()
		package.preload.TEST_MODULE = function()
			return TEST_MODULE
		end
	end

	function suite.teardown()
		package.loaded.TEST_MODULE = nil
		package.preload.TEST_MODULE = nil
	end


---
-- Soft require of existing module should return the module.
---

	function suite.returnsModule_onExistingModule()
		test.isnotnil(softrequire("TEST_MODULE"))
	end


---
-- Soft require of non-existent module should return nil.
---

	function suite.returnsNil_onMissingModule()
		test.isnil(softrequire("no-such-module"))
	end


---
-- Soft require should be nil on a version mismatch.
---

	function suite.returnsNil_onVersionMismatch()
		test.isnil(softrequire("TEST_MODULE", "^1.0"))
	end


---
-- If module was not loaded, should still not be loaded after version mismatch.
---

	function suite.leavesModuleUnloaded_onVersionMismatch()
		softrequire("TEST_MODULE", "^1.0")
		test.isnil(package.loaded.TEST_MODULE)
	end


---
-- If module was loaded, should still be loaded after version mismatch.
---

	function suite.leavesModuleLoaded_onVersionMismatch()
		package.loaded.TEST_MODULE = TEST_MODULE
		softrequire("self-test", "^1.0")
		test.isequal(TEST_MODULE, package.loaded.TEST_MODULE)
	end

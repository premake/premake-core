---
title: Adding Unit Tests
---

Premake includes an automated testing system that you can use the verify the behavior of your new module.


## Add your first test

Within our [Lucky module](Introducing-Modules.md) folder, create a new folder named `tests`.

Within that folder, create a new file named `tests/test_lucky_numbers.lua` with a simple failing test:

```lua
local suite = test.declare("lucky_numbers")

function suite.aFailingTest()
	test.isequal(2, 3)
end
```

You'll also need a manifest to list all of your test files. Create another file in that same folder named `_tests.lua`:

```lua
lucky = require('lucky')  -- replace with name of your module, obviously

return {
	"test_lucky_numbers.lua",
}
```

When you're all done, your module should now look like:

```
lucky/
|- lucky.lua
`- tests/
	|- _tests.lua
	`- test_lucky_numbers.lua
```

## Enable the testing module

Premake's automated testing module is considered an advanced, developer-only feature which is not enabled by default. To enable it, you simply need to add the line `test = require("self-test")` somewhere it will be executed before your tests run.

The best place to put it is in your [system script](System-Scripts.md), which will make the testing action available to all of your projects. But if that isn't feasible for you or your users, you can also place it in your project or testing script.

Premake's own code makes use of the latter approach: its `premake5.lua` script defines a custom action named "test", which in turn enables the built-in testing module:

```lua
newaction {
	trigger = "test",
	description = "Run the automated test suite",
	execute = function ()
		test = require "self-test"
		premake.action.call("self-test")
	end
	}
```

## Run your test

Once the testing module is enabled, `cd` to your module folder and run the command `premake5 self-test`. You should see your simple failing test fail.

```
$ premake5 self-test
Running action 'self-test'...
lucky_numbers.aFailingTest: ...e/Premake/Modules/lucky/tests/test_lucky_numbers.lua:4: expected 2 but was 3
0 tests passed, 1 failed in 0.00 seconds
```

If developing new tests for premake itself, it is often beneficial to run smaller subsets of tests with the command-line option --test-only:

```
$ premake5 --test-only=lucky_numbers test
```

## Passing a test

To complete the example, let's replace our failing test with one which actually calls our module.

```lua
local suite = test.declare("lucky_numbers")

function suite.makesEightLucky()
	local x = lucky.makeNumberLucky(8)
	test.isequal(56, x)
end
```

And give it a go:

```
$ premake5 self-test
Running action 'self-test'...
1 tests passed, 0 failed in 0.00 seconds
```

## Next steps?

The `tests` folder in the Premake source code contains over 1,000 tests which you can use as examples. The ones in [`tests/actions/vstudio/vc2010`](https://github.com/premake/premake-core/tree/master/tests/actions/vstudio/vc2010) tend to be the most frequently updated and maintained, and generally make the best examples.

You can see the full set of test assertions (`test.isequal()`, `test.capture()`, etc.) in the Premake source code at [`modules/self-test/test_assertions.lua`](https://github.com/premake/premake-core/blob/master/modules/self-test/test_assertions.lua).

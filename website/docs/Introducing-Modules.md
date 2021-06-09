---
title: Introducing Modules
---

A Premake module is simply a Lua script that follows a few extra conventions:

* the name of the script file is the name of the module
* the script should be placed in a folder of the same name
* the folder should be placed [somewhere Premake can find it](Locating-Scripts.md)

Let's start with a simple example. Create a new module by creating a folder named `lucky` and placing it [somewhere where Premake can find it](Locating-Scripts.md). Create a new file inside this folder named `lucky.lua`, with this simple starter module:

```lua
-- lucky.lua
-- My lucky Premake module

-- Start by defining a table to hold the interface to my module. By
-- convention we call this "m".

	local m = {}

-- Print out a message to show that our module has loaded.

	print("The lucky module has loaded!")

-- Finish by returning my module's interface

	return m
```

To use our new module, we just need to require it in any of our project scripts, something like this:

```lua
require "lucky"

workspace "MyWorkspace"
	configurations { "Debug", "Release" }

project "MyProject"
	-- and so on...
```

When we generate this project, we should see our message displayed in the output:

```
$ premake5 vs2012
The lucky module has loaded!
Building configurations...
Running action 'vs2010'...
Generating MyWorkspace.sln...
Generating MyProject.vcxproj...
Done.
```

`require()` is [Lua's standard module loading function](http://www.lua.org/pil/8.1.html) (though the version in Premake has been extended to support [more search locations](Locating-Scripts.md)). The first time a module is required, Lua will load it and return the module's interface (the table we assigned to `m` in the example). If the module is later required again, the same table instance will be returned, without reloading the scripts.

Any local variables or functions you define in your module will be private, and only accessible from your module script. Variables or functions you assign to the module table will public, and accessible through the module interface returned from `require()`.

Here is an example of a public function which accesses a private variable:

```lua
-- lucky.lua
-- My lucky Premake module

	local m = {}

-- This variable is private and won't be accessible elsewhere

	local secretLuckyNumber = 7

-- This function is public, and can be called via the interface

	function m.makeNumberLucky(number)
		return number * secretLuckyNumber
	end

	return m
```

You could then use this module's functions in your project scripts like so:


```lua
local lucky = require "lucky"
local luckyEight = lucky.makeNumberLucky(8)
```

That's all there to it!

Note that if you decide you want to [share your module](/community/modules) with other people, there are a [few other considerations to make](Sharing-Your-Module.md).


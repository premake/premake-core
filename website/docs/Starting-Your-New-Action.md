When developing something as complex as a new exporter, it is a good idea to build it as a [module](Developing-Modules.md). Doing so helps organize the code, provides [a way to automate testing](Adding-Unit-Tests.md), and makes it easy to [share your code with others](Sharing-Your-Module.md).

So let's start by setting up a module containing a really simple action. Create a new file named `lua.lua` and place it into a folder named `lua`. Place this `lua` folder [somewhere Premake can find it](Locating-Scripts.md).

Copy this simple skeleton action definition into your `lua.lua`:


```lua
-- lua/lua.lua

premake.modules.lua = {}
local m = premake.modules.lua

local p = premake

newaction {
	trigger = "lua",
	description = "Export project information as Lua tables",

	onStart = function()
		print("Starting Lua generation")
	end,

	onWorkspace = function(wks)
		printf("Generating Lua for workspace '%s'", wks.name)
	end,

	onProject = function(prj)
		printf("Generating Lua for project '%s'", prj.name)
	end,

	execute = function()
		print("Executing Lua action")
	end,

	onEnd = function()
		print("Lua generation complete")
	end
}

return m
```

I'll explain what all of that means in a moment, but first let's try it out and make sure everything is working. To see our new action in action, we'll need to require it into an existing project's `premake5.lua` script.

```lua
require "lua"  -- add this to load your module

workspace "MyWorkspace"
	configurations { "Debug", "Release" }

project "MyProject"
	-- etc.
```

Then we can generate that project with our new `lua` action and see the `print()` functions get called.

```
$ premake5 lua
Building configurations...
Running action 'lua'...
Starting Lua generation
Generating Lua for workspace 'MyWorkspace'
Generating Lua for project 'MyProject'
Executing Lua action
Lua generation complete
Done.
```

(Quick side note: if you'd like to make this or any third-party module available without having to add a `require()` to every project script, just put that `require("lua")` call in your [system script](System-Scripts.md) instead.)


### Explain. ###

We start out by creating a table to hold our module's interface. Since we'll be referencing this interface quite a lot in our code, we assign it to the shortcut `m` for "module".

```lua
premake.modules.lua = {}
local m = premake.modules.lua
```

We will also be calling functions from the `premake` namespace frequently, so we assign that to the shortcut `p` for "premake".

```lua
local p = premake
```

Now we're ready to register our new action with Premake, using `newaction()`.

```lua
newaction {
	trigger = "lua",
	description = "Export project information as Lua",
```

`trigger` is the token that should be typed on the Premake command line to cause our action to be triggered (i.e. `premake5 lua`).

`description` is the string which should appear in Premake's help text to describe what our action does. You can view this by running `premake5 --help` against the project script we modified above.

Next, we register callbacks for Premake to use when it is time to export the project:

```lua
onStart = function()
	print("Starting Lua generation")
end,

onWorkspace = function(wks)
	printf("Generating Lua for workspace '%s'", wks.name)
end,

onProject = function(prj)
	printf("Generating Lua for project '%s'", prj.name)
end,

execute = function()
	print("Executing Lua action")
end,

onEnd = function()
	print("Lua generation complete")
end
```

All of these callbacks are optional; you only need to include the ones you are actually interested in receiving.

`onStart` is called first to indicate that processing has begun.

`onWorkspace` is called once for every workspace that was declared, via the [`workspace`](workspace.md) function, in the user's project script.

`onProject` is called once for every project that was declared, via the [`project`](project.md) function, in the user's project script.

`execute` is called after all projects and workspaces have been processed. This is a good place to put more general code that doesn't require a workspace or project as input, and should only run once.

`onEnd` is called to indicate the processing is complete.

Finally, we return our module's interface back to the caller (the `require("lua")` call in our project or system script).

```lua
return m
```

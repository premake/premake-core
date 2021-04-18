---
title: Generating Project Files
---

Now let's extend our new action to actually output some workspace and project files so we can begin to get a sense for how things work.

First we need to know what we want to generate. Let's start with a very simple Premake project script, then we'll figure out how we want it to appear when we translate it to Lua.

```lua
workspace "Greetings"
	configurations { "Debug", "Release" }

project "HelloApp"
	kind "ConsoleApp"
	language "C++"
	files { "hello.h", "hello.cpp" }
```

There are, of course, many ways we could express this in Lua. For the purposes of this tutorial, we'll start by creating two files, starting with `Greetings.wks.lua`:

```lua
workspace = {
	name = "Greetings",
	projects = {
		["HelloApp"] = {
			path = "HelloApp.prj.lua",
		},
	},
}
```

Workspaces generally are used to manage a list of projects, so we'll try to do the same with our Lua version.

We'll also generate a second file named `HelloApp.prj.lua`, containing some of the easily accessible project information.

```lua
project = {
	name = "MyConsoleApp",
	uuid = "B19F86AA-524E-4260-B200-243C70F2DA04",
	kind = "ConsoleApp",
	language = "C++",
}
```

This is just to get things started; we'll come back to the configurations and the source code files and all of the other settings later.


## Creating the Files

Creating these files is easy: Premake has a built-in function to do just that, which we can leverage in our action's `onWorkspace()` and `onProject()` callbacks.

```lua
-- lua/lua.lua

premake.modules.lua = {}
local m = premake.modules.lua

local p = premake

newaction {
	trigger = "lua",
	description = "Export project information as Lua",

	onStart = function ()
	end,

	-- create a new file with a ".wks.lua" extension and
	-- then call our generateWorkspace() function.
	onWorkspace = function(wks)
		p.generate(wks, ".wks.lua", m.generateWorkspace)
	end,

	-- create a new file with a ".prj.lua" extension and
	-- then call our generateProject() function.
	onProject = function(prj)
		p.generate(prj, ".prj.lua", m.generateProject)
	end,
}


function m.generateWorkspace(wks)
	p.w('This is a Lua "workspace" file.')
end


function m.generateProject(prj)
	p.w('This is a Lua "project" file.')
end


return m
```

The `premake.generate()` function uses the information contained in the workspace or project to figure out the right name of location for the file, and then creates it on the disk. Once the file has been successfully created and opened, it then calls the function we provide as the last argument in the call (`generateWorkspace()` and `generateProject()` respectively) and passes it the corresponding workspace or project object to be exported.

The `p.w()` function, which stands for "Premake write", simply outputs a text string to the currently open file. You'll be seeing much more of this one.

If you go ahead and generate that project (i.e. run `premake5 lua` again), you will see the files get created on disk, each containing the corresponding "This is a..." message.


## Populating the Workspace

Now we can begin to fill in our workspace and project files. Let's begin with the easy parts of the workspace.

```lua
function m.generateWorkspace(wks)
	p.push('workspace = {')
	p.w('name = "%s",', wks.name)

	p.push('projects = {')
	p.pop('},')

	p.pop('}')
end
```

A couple of new functions here: `p.push()` writes the provided string to the output file, and increments an internal indentation level. `p.pop()` decrements the indentation level, and then writes its provided string to the output. `p.w()`, which we saw earlier, outputs its string at the current indentation level as set by `push()` and `pop()`.

So between all that pushing and popping, we end up with a nicely indented workspace file with an empty list of projects.

```lua
workspace = {
	name = "Greetings",
	projects = {
	},
}
```

Let's tackle that project list next. Premake has an entire API for working with workspaces, which you can find by browsing the [src/base/workspace.lua](https://github.com/premake/premake-core/blob/master/src/base/workspace.lua) script in Premake's source code.

*(Coming soon, just need to make a few code changes...)*


## Populating the Project

Since we're only exporting a few of the simple fields, generating our project file is quite easy:

```lua
function m.generateProject(prj)
	p.push('project = {')
	p.w('name = "%s",', prj.name)
	p.w('uuid = "%s",', prj.uuid)
	p.w('kind = "%s"', prj.kind)
	p.pop('}')
end
```

Which gives us a project file like:

```lua
project = {
	name = "MyConsoleApp",
	uuid = "B19F86AA-524E-4260-B200-243C70F2DA04",
	kind = "ConsoleApp",
	language = "C++",
}
```

## Escapes and Indents and EOLs

For the sake of completeness, a few last points.

First, indentation. By default, Premake will uses tab characters to indent the output. If your target format uses a different character sequence, two spaces for instances, you can adjust that using Premake's `p.indent()` function.

```lua
p.indent("  ")
```

Similarly, Premake will output Unix-style "\n" line endings by default, which can be changed with the `p.eol()` function.

```lua
p.eol("\r\n")
```

If you wish to change these values for both your generated workspaces and projects, you can place them in your action's `onStart()` function. If the values are different between workspaces and projects, put then in `onWorkspace()` and `onProject()` instead.

```lua
onStart = function()
	p.indent("  ")
	p.eol("\r\n")
end
```

Finally, before we go we should consider string escaping. If, for example, someone were to name their project `Joe's "Lucky" Diner`, we would try to generate this Lua script...

```lua
	name = "Joe's "Lucky" Diner",
```

...which would fail to load in a Lua interpreter, since the double quotes aren't properly matched. Instead, we ought to be generating:

```lua
	name = "Joe's \"Lucky\" Diner",
```

Premake allows exporters to define an "escaper", a function which is used to transform values before they are written to the output. For our Lua exporter, we want to escape those double quotes with a backslash, and we should also escape backslashes while we're at it, which we can do by adding this function to our module:

```lua
function m.esc(value)
	value = value:gsub('\\', '\\\\')
	value = value:gsub('"', '\\"')
	return value
end
```

We can then tell Premake to use this function for both our workspaces and our project by registering our escaper in our action's `onStart()`.

```lua
onStart = function()
	p.escaper(m.escaper)
end
```

One more step: since we don't *always* want to escape values, Premake provides a separate call `p.x()` for those times when we do. For our example case, we really only need to worry about the workspace and solution names right now, since the other fields are limited to values which do not contain special characters (while there is no harm in using `p.x()` on values that do not contain special characters, there is a small performance hit which can add up for large projects).

So our final script looks like this:

```lua
-- lua/lua.lua

premake.modules.lua = {}
local m = premake.modules.lua

local p = premake

newaction {
	trigger = "lua",
	description = "Export project information as Lua",

	onStart = function ()
		p.escaper(m.esc)
	end,

	onWorkspace = function(wks)
		p.generate(wks, ".wks.lua", m.generateWorkspace)
	end,

	onProject = function(prj)
		p.generate(prj, ".prj.lua", m.generateProject)
	end,
}


function m.generateWorkspace(wks)
	p.push('workspace = {')
	p.x('name = "%s",', wks.name)

	p.push('projects = {')
	p.pop('},')

	p.pop('}')
end


function m.generateProject(prj)
	p.push('project = {')
	p.x('name = "%s",', prj.name)
	p.w('uuid = "%s",', prj.uuid)
	p.w('kind = "%s"', prj.kind)
	p.pop('}')
end


function m.esc(value)
	value = value:gsub('\\', '\\\\')
	value = value:gsub('"', '\\"')
	return value
end


return m
```

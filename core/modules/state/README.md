# Premake State Module

The State module is responsible for running queries against the project information collected from the end user's scripts and returning the resulting collection of field values. You can ask for all of the settings for the "Debug" build configuration of "MyProject", and this module will assemble and return the result.

(Side note: I would really like this code to be simpler and easier to understand without the exposition. I'm hoping that once other people start looking at it someone will clue me in to a simpler approach or a new technique. In the meantime...)

It will be easier to understand the code with some background.

## Scopes

I use "scope" as a shorthand for "unit of containment". A workspace is a scope, a project is a scope, a project configuration is a scope, as is a file and a file build configuration. Lots of scopes. Scopes also imply aggregation and inheritance: a workspace contains one or more project, a project contains one or more build configurations. Depending on the capabilities of the toolset, a project can inherit settings from its workspace; a project build configuration from its project.

Most toolsets support a scope hierarchy something like this:

```
`-- global
  |
  `-- workspace
    |
    |-- configuration/platforms
	|
	`-- projects
	  |
	  |-- configurations/platforms
	  |
	  `-- files
	    |
		`-- configurations/platforms
```

The State module uses a table of key-value pairs to describe a scope. The keys are field names, matching what you would use in your project scripts: 'workspaces', 'projects', 'configurations', 'files', etc.

```lua
{}  -- global
{ workspaces = 'MyWorkspace' }  -- workspace
{ projects = 'MyProject' }  -- project
```

## Conditions

The scopes are matched to _conditions_, which are the criteria you supply to a `when()` statement in your project scripts.

```lua
when({ 'workspaces:MyWorkspace'}, function () ... end)

-- shorthand for `workspaces('MyWorkspace'); when({ 'workspaces:MyWorkspace' }, ...)
workspace('MyWorkspace', function () ... end)
```

## Blocks

_Blocks_ are objects containing a chunk of project settings. They roughly correspond to the function blocks on your `when()`, `workspace()` and `project()` statements. A bit of project script like this...

```lua
when({ 'configurations:Debug' }, function ()
   defines { 'A', 'B', 'C' }
   symbols 'On'
)
```

...gets turned into a block that looks something like...

```lua
{
	_condition = { 'configurations:Debug' },
	_operation = 'ADD',
	defines = { 'A', 'B', 'C' },
	symbols = 'On'
}
```

## Evaluating Queries

Each query is made up of two constraints: the scope and the initial values. Scopes were mentioned above; the initial values are a key-value table of additional state that can be used to satisfy conditions.

```lua
-- Setting initial values to this...
{
	action = 'vstudio',
	system = 'macos'
}

-- would pass this...
when({ 'action:vstudio' }, ...)

-- and fail this...
when({ 'system:windows' }, ...)
```

When a query is evaluated, each block is iterated over and its condition checked against the target scope and the current set of values. If the condition passes, the settings contained in that block are added to the current set of values, and evaluation moves on to the next block.

## Scope Matching

Value matching is straightforward: the corresponding field must be set, and its value must match whatever value or pattern is specified in the condition. Scope matching is a little more involved. In order for a block to be considered "in scope", it's condition must test each field described by the scope.

```lua
-- this scope
{ workspaces = 'MyWorkspace', projects = 'MyProjects' }

workspace('MyWorkspace', function ()
	-- doesn't match this block; 'MyProject' isn't part of the condition

	project('MyProject', function ()
		-- matches this block; 'MyWorkspace' and 'MyProject' have both been tested
	end)
end)

project('MyProject', function ()
	-- doesn't match this block; 'MyWorkspace' isn't being tested
end)
```

## Removing Values

This is where things get messy. Take this example:

```lua
project('MyProject', function ()
	configurations { 'Debug', 'Release' }
	defines { 'A', 'B', 'C' }

	when({ 'configurations:Release' }, function ()
		removeDefines 'B'
	end)
end)
```

The project file format used by most toolsets (e.g. Visual Studio, Xcode, Make) are _additive_. Once you set a value, there is no easy way to remove it. (Yes, in this example you could undefine the symbol, but that only works for defines; you'd have to come up with a special case for every setting, and it would fall on the exporter author to figure it out and ick no, there is no easy way.) So if we define 'B' at the project level...well, then we're stuck with it. Both the 'Debug' and 'Release' configurations will pick it up, and that's not what we want. It really needs to be removed at the _project_ level, and then _added back in_ to the 'Debug' configuration, which in this example is the only place it actually gets used.

When everything works correctly, you end up with a project file that looks like:

```lua
project 'MyProject'
   defines 'A', 'C'

   configuration 'Debug'
	  defines 'B'

   configuration 'Release'
end
```

It's an edge case, but a significant amount of the code in both `state.lua` and `query.lua` is dedicated to making it work.

## State APIs

To pull state out of the project configuration, start by creating a new global state object, passing in the initial set of environmental values.

```lua
local global = premake.newState({
	action = 'vstudio'
})
```

From the global scope, you can pull values that sit "outside" of any workspace. For this project script...

```lua
defines 'GLOBAL'

workspace('MyWorkspace', function ()
	configurations { 'Debug', 'Release' }
	defines 'WORKSPACE'

	project('MyProject', function ()
		kind 'StaticLibrary'
		defines 'PROJECT'
	end)
end)
```

...the global scope results look like...

```lua
local defines = global.defines       -- returns { 'GLOBAL' }
local workspaces = global.workspaces -- returns { 'MyWorkspace' }
```

From the global scope, you can index `workspaces` as shown to get the list of workspace names. With the name, you can then select the settings for that workspace from the global scope.

```lua
local wks = global:select({ workspaces = 'MyWorkspace' })

local projects = wks.projects      -- { 'MyProject' }
local configs = wks.configurations -- { 'Debug', 'Release' }
local defines = wks.defines        -- { 'WORKSPACE' }
```

In the same way, you can select a project from a workspace.

```lua
local prj = wks:select({ projects = 'MyProject' })

local kind = prj.kind        -- 'StaticLibrary'
local defines = prj.defines  -- { 'PROJECT' }
local configs = prj.configs  -- nil, not set in project scope, see next section
```

Selecting configurations, files, and file configurations behaves in the same way.

### Inheritance

Visual Studio, as an example, expects all project settings to be placed in a project file, i.e. `MyProject.vcxproj`. To model this, we want the settings returned by the project scope to also include settings from the container workspace and global scopes. Enable inheritance using `withInheritance()` to turn on this behavior.

```lua
local global = premake.newState({ ... })
local wks = global:select({ workspaces = 'MyWorkspace' }):withInheritance()
local prj = wks:select({ projects = 'MyProject' }):withInheritance()

local defines = prj.defines        -- { 'GLOBAL', 'WORKSPACE', 'PROJECT' }y
local configs = prj.configurations -- { 'Debug', 'Release' }
```

Inheritance can be set for any or no scopes. You could also choose to inherit the global settings into the workspace, but not inherit the workspace settings into the project.

```lua
local global = premake.newState({ ... })
local wks = global:select({ workspaces = 'MyWorkspace' }):withInheritance()
local prj = wks:select({ projects = 'MyProject' })

wks.defines   -- { 'GLOBAL', 'WORKSPACE' }
prj.defines   -- { 'PROJECT' }
```

You can also enable or disable inheritance per fetch. Continuing the example above:

```lua
prj.defines                     -- { 'PROJECT' }
prj:withInheritance().defines   -- { 'GLOBAL', 'WORKSPACE', 'PROJECT' }
```

### Includes

Selecting one scope out of another implies a level of containment. The global scope contains workspaces, a workspace contains projects. Consider this project script:

```lua
workspace('Workspace1', function ()
	defines 'WORKSPACE1'
	project('MyProject', function ()
		defines 'PROJECT1'
	end)
end)

workspace('Workspace2', function ()
	defines 'WORKSPACE2'
	project('MyProject', function ()
		defines 'PROJECT2'
	end)
end)

project('MyProject', function ()
	defines 'PROJECT3'
end)
```

I can select 'MyProject' out of 'Workspace1'...

```lua
wks = global:select({ workspaces = 'Workspace1' })
prj = wks:select({ projects = 'MyProject' })

prj.defines -- { 'PROJECT1' }
```

The containment implied by selecting out of Workspace1 ensures that only values that are directly relevant to Workspace1 get included.

TODO: finish this thought; need to also include the 'MyProject' block from the global scope to get the expected result.

```lua
wks = global:select({ workspaces = 'Workspace1' })
prj = wks:select({ projects = 'MyProject' }):fromScopes(global)

prj.defines -- { 'PROJECT1', 'PROJECT3' }
```

## Fini

This concludes our introduction to the State module. Helpful? Check out the source code documentation and one of the existing exporter modules for more usage examples, and give a shout on the GitHub project if you're still stuck.

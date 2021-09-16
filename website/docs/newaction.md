Registers a new command-line action argument. For more information, see [Command Line Arguments](Command-Line-Arguments.md).

```lua
newaction { description }
```

### Parameters ###

`description` is a table describing the new action. It may contain the following fields:

| Field       | Description                                                                        |
|-------------|------------------------------------------------------------------------------------|
| trigger     | What the user would type on the command line to select the action, e.g. "vs2013".  |
| shortname   | A short summary for the help text, e.g. "Visual Studio 2013".                      |
| description | A description of the action's result, e.g. "Generate Visual Studio 2013 project files". |
| execute     | A function to be executed when the action is fired.                                |
| os          | Deprecated, use targetos instead. |
| targetos    | If the toolset targets a specific OS, the [identifier](system.md) for that OS. |
| valid_kinds | The list of [project kinds](kind.md) supported by the action. |
| valid_languages | The list of [languages](language.md) supported by the action. |
| valid_tools | The list of [tools](toolset.md) supported by the action. |
| toolset | Default [tools](toolset.md). |
| onStart     | A callback marking the start of action processing. |
| onSolution | Deprecated, use onWorkspace instead. |
| onWorkspace | A callback for each workspace specified in the user script. |
| onProject   | A callback for each project specified in the user script. |
| onRule      | A callback for each rule specified in the user script. |
| onEnd       | A callback marking the end of action processing. |
| onCleanWorkspace | A callback for each workspace, when the clean action is selected. |
| onCleanProject  | A callback for each project, when the clean action is selected. |
| onCleanTarget   | A callback for each target, when the clean action is selected. |
| pathVars    | A map of Premake tokens to toolset specific identifiers. |

The callbacks will fire in this order:

1. `onStart()`
2a. `onWorkspace()` for each workspace
2b. `onProject()` for each project in each workspace
3. `onRule()` for each rule
4. `execute()`
5. `onEnd()`


### Availability ###

Premake 5.0 and later.


### Examples ###

Register a new action to install the software project.

```lua
newaction {
   trigger     = "install",
   description = "Install the software",
   execute     = function ()
      os.copyfile("bin/debug/myprogram", "/usr/local/bin/myprogram")
   end
}
```

### See Also ###

* [Command Line Arguments](Command-Line-Arguments.md)

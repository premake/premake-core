Turns the Editor Integration feature on. This is simply a hint to the action to add extra information into the generated workspace that allows an IDE to know which/where and how premake was executed. This is currently really only implemented for the Visual Studio action, but other actions may use this too in the future.

There is a plugin that allows re-execution of the premake step from within Visual Studio, which can be found here:
https://github.com/tvandijck/PremakeExtension

```lua
editorintegration ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Allow editor integration functionality with Premake. |
| Off   | Disallow editor integration functionality with Premake. |

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio until 2026.

### Examples ###

```lua
-- Turn on IDE integration
editorintegration "On"
```

Turns the Editor Integration feature on. This is simply a hint to the action to add extra information into the generated workspace that allows an IDE to know which/where and how premake was executed. This is currently really only implemented for the Visual Studio action, but other actions may use this too in the future.

There is a plugin that allows re-execution of the premake step from within Visual Studio, which can be found here:
https://github.com/tvandijck/PremakeExtension

```lua
editorintegration "value"
```

If no value is set for a configuration, the toolset's default setting (usually "Off") will be used.

### Parameters ###

`value` is a boolean value, i.e. "On" or "Off".

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
-- Turn on IDE integration
editorintegration "On"
```

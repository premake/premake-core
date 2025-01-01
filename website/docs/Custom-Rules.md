---
title: Custom Rules
---

Rule file generation is a new and experimental feature of Premake 5.0, which currently only supports Visual Studio and the gmake action. It allows you describe how to build a particular kind of file, similar to [custom build commands](Custom-Build-Commands.md), but in a more generic way, and with variables that can be set in your project script.

At generation time, Premake will output the appropriate rule files for the target action, just as it does for workspaces and projects.  For Visual Studio 2010+, Premake will generate `RuleName.props`, `RuleName.targets`, and `RuleName.xml`. Currently, no other actions are supported.

The documentation for this feature is still very incomplete.


## Your First Rule

A simple build rule might look like this:

```lua
rule "MyCustomRule"
  display "My custom compiler"
  fileextension ".xyz"

  buildmessage 'Compiling %(Filename) with MyCustomCC'
  buildcommands 'MyCustomCC.exe -c "%(FullPath)" -o "%(IntDir)/%(Filename).obj"'
  buildoutputs '%(IntDir)/%(Filename).obj'
```

This rule will pass all files in project with the ".xyz" file extension through the specified build command. At export time, the files `MyCustomRule.props`, `MyCustomRule.targets`, and `MyCustomRule.xml` will be generated in the sample directory. Like workspaces and projects, this can be changed with [`location`](location.md) and [`filename`](filename.md).

There are still some shortcomings with the current implementation, notably that we don't have a generic set of variables to use in the commands. The example above uses Visual Studio's own variables such as `%(FullPath)` and `%(IntDir)`; obviously these won't work if rules are implemented for a different toolset.

To use the sample rule from above in a project, list the rule name in a [`rules`](rules.md) statement:

```lua
project "MyProject"
  rules { "MyCustomRule" }
```


## Rule Properties

The benefit of custom rules over [custom build commands](Custom-Build-Commands.md) is the ability to specify *properties*, which can then be set like any other project or configuration value. Properties are defined with [`propertydefinition`](propertydefinition.md) functions, including default values which can be overridden by specific project configurations.

```lua
rule "MyCustomRule"
  -- ...rule settings...

  propertydefinition {
    name = "StripDebugInfo",
    kind = "boolean",
    display = "Strip Debug Info",
    description = "Remove debug information from the generated object files"
    value = false,
    switch = "-s"
  }
```

Properties may then be used in the rule commands by enclosing the name in square brackets. This, again, is a Visual Studio convention; we may switch it up if support for additional exporters becomes available. You might find in [Tokens](Tokens.md) some portable tokens for replacement.

```lua
buildcommand 'MyCustomCC.exe -c "%(FullPath)" -o "%(IntDir)/%(Filename).obj" [StripDebugInfo]
```

The string `[StripDebugInfo]` will be set with the switch value `-s` if the value is set to true.

To set the properties for a rule, Premake will create a setter function of the format *ruleName*Vars(). To set the example property above for a project's release configuration only:

```lua
project "MyProject"
  rules { "MyCustomRule" }

  filter { "configurations:Release" }
    myCustomRuleVars {
      StripDebugInfo = true
    }
```

## Rule Batching

With MSBuild, custom rules can be batched if same properties are used. To enable this, use `file.ruleinputs` tokens in `buildcommands`. If corresponding `buildoutputs` is up-to-date to the input, then the input will be omitted. This token falls back to `file.relpath` on unsupported environment.

```lua
rule "BatchRule"
  fileextension ".xyz"
  buildcommands "MyProcessor.exe %{file.ruleinputs}"
```


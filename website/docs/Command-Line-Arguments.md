---
title: Command Line Arguments
---

Premake provides the ability to define and handle new command-line arguments from within your project script using the [newaction](newaction.md) and [newoption](newoption.md) functions.

## Actions and Options

Premake recognizes two types of arguments: _actions_ and _options_.

An _action_ indicates what Premake should do on any given run. For instance, the `vs2013` action indicates that Visual Studio 2013 project files should be generated. The `clean` action causes all generated files to be deleted. Only one action may be specified at a time.

An _option_ modifies the behavior of the action. For instance, the `dotnet` option is used to change which .NET compiler set is used in the generated files. Options can accept a value, such as `--dotnet=mono` or act as a flag, like `--with-opengl`.

From within your script, you can identify the current action with the [`_ACTION`](globals/premake_ACTION.md) global variable, a string value. You can check for an option using the [`_OPTIONS`](globals/premake_OPTIONS.md) table, which contains a list of key-value pairs. The key is the option identifier ("dotnet"), which references the command line value ("mono") or an empty string for valueless options.

```lua
-- delete a file if the clean action is running
if _ACTION == "clean" then
   -- do something
end

-- use an option value in a configuration
targetdir ( _OPTIONS["outdir"] or "out" )
```

## Creating New Options

New command-line options are created using the [`newoption`](newoption.md) function, passing a table which fully describes the option. This is best illustrated with some examples.

Here is an option intended to force the use of OpenGL in a 3D application. It serves as a simple flag, and does not take any value.

```lua
newoption {
   trigger = "with-opengl",
   description = "Force the use of OpenGL for rendering, regardless of platform"
}
```

Note the commas after each key-value pair; this is required Lua syntax for a table. Once added to your script, the option will appear in the help text, and you may use the trigger as a keyword in your configuration blocks.

```lua
filter { "options:with-opengl" }
   links { "opengldrv" }

filter { "not options:with-opengl" }
   links { "direct3ddrv" }
```

The next example shows an option with a fixed set of allowed values. Like the example above, it is intended to allow the user to specify a 3D API.

```lua
newoption {
   trigger = "gfxapi",
   value = "API",
   description = "Choose a particular 3D API for rendering",
   allowed = {
      { "opengl",    "OpenGL" },
      { "direct3d",  "Direct3D (Windows only)" },
      { "software",  "Software Renderer" }
   },
   default = "opengl"
}
```

As before, this new option will be integrated into the help text, along with a description of each of the allowed values. Premake will check the option value at startup, and raise an error on invalid values. The <b>value</b> field appears in the help text, and is intended to give the user a clue about the type of value that is expected. In this case, the help text will appear like this:

```
--gfxapi=API      Choose a particular 3D API for rendering; one of:
	opengl        OpenGL
	direct3d      Direct3D (Windows only)
	software      Software Renderer
```

Unlike the example above, you now use the _value_ as a keyword in your configuration blocks.

```lua
filter { "options:gfxapi=opengl" }
   links { "opengldrv" }

filter { "options:gfxapi=direct3d" }
    links { "direct3ddrv" }

filter { "options:gfxapi=software" }
    links { "softwaredrv" }
```

As a last example of options, you may want to specify an option that accepts an unconstrained value, such as an output path. Just leave off the list of allowed values.

```lua
newoption {
   trigger     = "outdir",
   value       = "path",
   description = "Output directory for the compiled executable"
}
```


## Creating New Actions

Actions are defined in much the same way as options, and can be as simple as this:

```lua
newaction {
   trigger     = "install",
   description = "Install the software",
   execute = function ()
      -- copy files, etc. here
   end
}
```

The actual code to be executed when the action is fired should be placed in the `execute()` function.

That's the simple version, which is great for one-off operations that don't need to access to the specific project information. For a tutorial for writing a more complete action, see [Adding a New Action](Adding-New-Action.md).

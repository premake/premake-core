# commandLineOption

Load and executes a Lua script file.

```lua
commandLineOption { definition... }
```

## Parameters

`definition` is a table describing the new command line option. The following fields are recognized:

| | |
|---------------|-----------------------------------------------------------------------|
| `trigger`     | What the user would type on the command line (required)               |
| `description` | A short description of the option, to be displayed in the help text.  |
| `value`       | If the option needs a value, a hint to what type of value is expected |
| `allowed`     | A list of key-value pairs listing the allowed values for the option   |
| `default`     | A default value to be used if the option is not specified             |
| `execute`     | A function to execute when the option is specified by the user        |

## Return Value

None.

## Availability

Premake 6.0 or later (available in 4.0 or later as `newaction` and `newoption`).

## Examples

Register a new option to select a rendering API for a 3D application.

```lua
commandLineOption {
   trigger = "--gfxapi",
   value = "API",
   description = "Choose a particular 3D API for rendering",
   default = "opengl",
   allowed = {
      { "opengl",   "OpenGL" },
      { "direct3d", "Direct3D (Windows only)" },
      { "metal",    "Metal (macOS only)" }
   }
}
```

Once registered, the option can be used on the comamnd line, and will appear in the help text shown by the `--help` option.

```
$ premake6 --gfxapi opengl vs2019
```

Options may also specify a function to be called if present on the command line.

```lua
commandLineOption {
    trigger = '--version',
    description = 'Display version information',
    execute = function()
        print(string.format('Premake Build Script Generator version %s', _PREMAKE.VERSION))
    end
}

```

## See Also

* [options.definitionOf](options.definitionOf.md)
* [options.register](options.register.md)
* [options.valueOf](options.valueOf.md)

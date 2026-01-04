Registers a new command-line option. For more information, see [Command Line Arguments](Command-Line-Arguments.md).

```lua
newoption { description }
```

### Parameters ###

`description` is a table describing the new option. It may contain the following fields:

| Field       | Description                                                                        |
|-------------|------------------------------------------------------------------------------------|
| trigger     | What the user would type on the command line to select the option, e.g. `--name`. |
| description | A short description of the option, to be displayed in the help text. |
| value       | Optional. If the option needs a value, provides a hint to the user what type of data is expected. |
| allowed     | Optional. A list of key-value pairs listing the allowed values for the option. |
| default     | Optional. Sets the default for this option if not specified on the commandline. |
| category    | Optional. Places the option under a separate header when the user passes `--help` |


### Applies To ###

Global configurations.

### Availability ###

Premake 4.0 and later.


### Examples ###

Register a new option to select a rendering API for a 3D application.

```lua
newoption {
   trigger     = "gfxapi",
   value       = "API",
   description = "Choose a particular 3D API for rendering",
   default     = "opengl",
   category    = "Build Options",
   allowed = {
      { "opengl",    "OpenGL" },
      { "direct3d",  "Direct3D (Windows only)" },
      { "software",  "Software Renderer" }
   }
}
```

### See Also ###

* [Command Line Arguments](Command-Line-Arguments.md)

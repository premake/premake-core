Specifies a message to display to the user before starting execution of any specified [pre-link commands](prelinkcommands.md).

```lua
prelinkmessage ("message")
```

### Parameters ###

`message` is the message to be displayed.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
project "MyProject"
   prelinkcommands { "{COPYFILE} %[dependencies/*.lib] %[bin]" }
   prelinkmessage "Copying dependencies..."
```

## See Also ##

* [Tokens](Tokens.md)
* [prelinkcommands](prelinkcommands.md)
* [prebuildmessage](prebuildmessage.md)
* [postbuildmessage](postbuildmessage.md)

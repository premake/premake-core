Specifies a message to display to the user before starting execution of any specified [pre-build commands](prebuildcommands.md).

```lua
prebuildmessage ("message")
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
   prebuildcommands { "copy dependencies/*.lib bin" }
   prebuildmessage "Copying dependencies..."
```

### See Also ###

* [prebuildcommands](prebuildcommands.md)
* [postbuildmessage](postbuildmessage.md)
* [prelinkmessage](prelinkmessage.md)

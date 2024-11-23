Specifies a message to display to the user before starting execution of any specified [post-build commands](postbuildcommands.md).

```lua
postbuildmessage ("message")
```

### Parameters ###

`message` is the message to be displayed.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
project "MyProject"
   postbuildcommands { "{COPYFILE} %[dependencies/*.lib] %[bin]" }
   postbuildmessage "Copying dependencies..."
```

### See Also ###

* [Tokens](Tokens.md)
* [postbuildcommands](postbuildcommands.md)
* [prebuildmessage](prebuildmessage.md)
* [prelinkmessage](prelinkmessage.md)

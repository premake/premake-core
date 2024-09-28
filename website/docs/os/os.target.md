Returns the name of the operating system currently being targeted.
See [system](system.md) for a complete list of OS identifiers.

The targeted OS may be overridden on the command line with the `--os` option.
```
$ premake5 --os=macosx xcode4
```

### Examples ###
```lua
print("Target os: " .. os.target())
```

### See Also ###
[system](system.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.


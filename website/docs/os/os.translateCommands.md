Translate [command tokens](Tokens.md#command-tokens) into their OS or action specific equivalents.

```lua
cmd = os.translateCommands("cmd", map)
```

### Parameters ###

`cmd` is the command line to be translated. May be a single string or an array of strings.

`map` is either an [OS identifier](system.md) (e.g. "windows") to use one of Premake's built-in token mappings, or a table containing a custom mapping. If omitted, the currently targeted OS identifier will be used.


### Return Value ###

A new command line string with all command tokens replaced.

### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- translate for the currently targeted OS
cmd = os.translateCommands("{COPY} file1.txt file2.txt")

-- translate for a specific OS
cmd = os.translateCommands("{COPY} file1.txt file2.txt", "windows")

-- translate using a custom map
cmd = os.translateCommands("{COPY} file1.txt file2.txt", {
	copy = function(v)
		return "dup " .. v
	end
})
```


### See Also ###

* [Tokens](Tokens.md)

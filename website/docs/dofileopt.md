Find and execute a Lua source file, but continue without error if the file is not present.

```lua
dofileopt("filename")
```

### Parameters ###

`fname` is the name of the file to load. This may be specified as a single file path or an array of file paths, in which case the first file found is run.

### Return Value ###

True if a file was found and executed, nil otherwise.

### Availability ###

Premake 5.0 or later.


### See Also ###

* [include](include.md)

Turns on/off the automatic linking of `.obj` files that are output by custom build commands. The default behaviour is to link `.obj` files when they are output by custom build commands.

```lua
linkbuildoutputs "value"
```

### Parameters ###

`value` is a boolean value, i.e. "On" or "Off".


### Applies To ###

Project configurations and rules.


### Availability ###

Premake 5.0 or later.


### Examples ###

Use [custom build commands](Custom-Build-Commands.md) to copy Wavefront .obj model files around without the linker trying to link them:

```lua
filter "**/models/**.obj"
	-- Copy these files into the target directory while preserving the
	-- folder structure.
	buildcommands {
		os.translateCommands '{mkdir} "%{ path.join(cfg.buildtarget.directory, path.getdirectory(file.relpath)) }"',
		os.translateCommands '{copy} "%{ file.relpath }" "%{ path.join(cfg.buildtarget.directory, path.getdirectory(file.relpath)) }"'
	}

	buildoutputs "%{ path.join(cfg.buildtarget.directory, file.relpath) }"

	-- The default behaviour is to link .obj if a custom build command
	-- outputs them, but we don't want that since these are Wavefront .obj
	-- model files and not object files.
	linkbuildoutputs "Off"
```


### See Also ###

* [Custom Build Commands](Custom-Build-Commands.md)
* [Custom Rules](Custom-Rules.md)
* [buildcommands](buildcommands.md)
* [compilebuildoutputs](compilebuildoutputs.md)

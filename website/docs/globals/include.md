Looks for and executes another script file, if it hasn't been run previously.

```lua
include("path")
```

### Parameters ###

`path` is the file system path to a script file or a directory. If a directory is specified, Premake looks for a file named `premake5.lua` in that directory and runs it if found.

If the file or directory specified has already been included previously, the call is ignored. If you want to execute the same script multiple times, use Lua's [dofile()](http://www.lua.org/manual/5.1/manual.html#pdf-dofile) instead.


### Return Value ###

Any values returned by the included script are passed through to the caller.


### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- runs "src/MyApplication/premake5.lua"
include "src/MyApplication"

-- runs "my_script.lua" just once
include "my_script.lua"
include "my_script.lua"
```


### See Also ###

* [dofileopt](dofileopt.md)
* [includeexternal](includeexternal.md)

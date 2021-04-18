Runs a shell command and return the output.

```lua
result, errorCode = os.outputof("command")
```

### Parameters ###

`command` is a shell command to run.


### Return Value ###

The output and error code of the command.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
-- Get the ID for the host processor architecture
local proc = os.outputof("uname -p")
```


### See Also ###

* [os.executef](os.executef.md)

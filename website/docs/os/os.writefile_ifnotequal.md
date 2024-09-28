Writes a string to a file, if the string differs from the current version of the file.

```lua
ok, err = os.writefile_ifnotequal("text", "filename")
```

### Parameters ###

`text` is the string to be written to the file.

`filename` is the file system path to the target file.


### Return Value ###

True if successful, otherwise nil and an error message.


### Availability ###

Premake 5.0 or later.

Creates a new symbolic link to a file.

```lua
os.linkfile("src", "dst")
```

### Parameters ###

`src` is the path of the file to create a symbolic link to.
`dst` is the path to the created symbolic link.

### Return Value ###

True if successful, otherwise nil and an error message.

### Availability ###

Premake 5.0-beta4 or later.
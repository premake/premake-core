Checks the target operating system against a particular identifier or tag.
See [os.getSystemTags](os.getSystemTags.md) for documentation about OS tags.

### Examples ###
```lua
print("Android: " .. os.istarget("android"))
print("Mobile: " .. os.istarget("mobile"))
print("Desktop: " .. os.istarget("desktop"))
```

### See Also ###
[os.target](os.target.md)
[os.getSystemTags](os.getSystemTags.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.


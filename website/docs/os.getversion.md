Retrieve version information for the host operating system.

```lua
sysinfo = os.getversion()
```

### Parameters ###

None.

### Return Value ###

A table, containing the following key-value pairs:

| Field         | Description                                       |
|---------------|---------------------------------------------------|
| majorversion  | The major version number                          |
| minorversion  | The minor version number                          |
| revision      | The bug fix release or service pack number        |
| description   | A human-readable description of the OS version    |

On platforms where this function has not been implemented, it will return zero for all version numbers, and the platform name as the description.


### Availability ###

Premake 4.4 or later.


### Examples ###

```lua
local ver = os.getversion()
print(string.format(" %d.%d.%d (%s)",
   ver.majorversion, ver.minorversion, ver.revision,
   ver.description))

-- On Windows XP: "5.1.3 (Windows XP)"
-- On OS X,: "10.6.6 (Mac OS X Snow Leopard)"
```

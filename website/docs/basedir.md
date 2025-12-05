---
title: basedir
description: Sets the base directory for a configuration
keywords: [premake, basedir, base directory, path, config]
---

Sets the base directory for a configuration, from with other paths contained by the configuration will be made relative at export time.

```lua
basedir ("path")
```

You do not normally need to set this value, as it is filled in automatically with the current working directory at the time the configuration block is created by the script.

### Parameters ###

`path` **string** - is an absolute path, from which other paths contained by the configuration should be made relative.

### Applies To ###

Any configuration.

### Availability ###

Premake 4.4 or later.

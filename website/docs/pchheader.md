Specifies the #include form of the precompiled header file name.

```lua
pchheader ("name.h")
```

See [Precompiled Headers](Precompiled-Headers.md) for more information.

### Parameters ###

`name.h` is the name of the precompiled header, as it is specified in the #include statements of the project source code. If your source code includes the header like this:

```c
#include "myproject.h"
```

...specify the header in your script like this, even if the file itself is located on a different path relative to the project (and presumably found at compile time via the include file search paths):

```lua
pchheader "myproject.h"
```

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 and up.

## See Also ##

* [Precompiled Headers](Precompiled-Headers.md)
* [pchsource](pchsource.md)

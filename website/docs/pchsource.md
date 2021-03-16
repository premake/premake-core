Specifies the C/C++ source code file which controls the compilation of the header.

```lua
pchsource ("sourcefile.cpp")
```

See [Precompiled Headers](Precompiled-Headers.md) for more information.

### Parameters ###

`sourcefile.cpp` is the name of the source code which triggers the compilation of the header. This file must contain the header file's `#include` statement as the first line of code; this is usually the only statement in the file.

(Can anyone find a good link to this in the MSDN docs? They just rearranged the site and I'm not finding anything useful right now.)

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 and up.

## See Also ##

* [Precompiled Headers](Precompiled-Headers.md)
* [pchheader](pchheader.md)
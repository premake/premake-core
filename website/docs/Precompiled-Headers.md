---
title: Precompiled Headers
---

Due to differences between how the different toolsets handle precompiled headers, this subject is far more complex than it needs to be.

Visual Studio requires two pieces of information in order to enable precompiled headers: the *header file* to be precompiled, and a *source file* to trigger and control the compilation. In a default, out-of-the-box Visual Studio generated C++ project, these are called *stdafx.h* and *stdafx.cpp* respectively. You can set these in Premake like so:

```lua
pchheader "stdafx.h"
pchsource "stdafx.cpp"
```

Every other toolset (so far anyway) requires only the header file.

The PCH source file is just a regular old source code file containing a single line: an include statement that pulls in the header to be precompiled:

```c
#include "stdafx.h"
```

Nothing special, but you must have this file in order for precompiled headers to work in Visual Studio. You may call this file whatever you want, and put it wherever you want in your source tree. Like any other file, the path to the precompiled header source file should be set relative to the project script, and is automatically made relative to the generated project file. Non-Visual Studio toolsets will ignore the `pchsource` value, so it's safe to set it unconditionally.

Setting the header file, on the other hand, get a bit more complicated.

## Setting the Header File

When setting the precompiled header file, you don't provide the path to the file as you might expect. Rather, you specify how the include will appear in the source code. Most of the time your header is located at the root level of your project source tree, in the same folder as the project file, and you include it like this:

```c
#include "stdafx.h"
```

In this case, your precompiled header should be set to "stdafx.h". Simple enough. In your Premake script, you would set:

```lua
pchheader "stdafx.h"
```

What if you have source code that is nested in a subfolder, such as `./utils/myhelper.cpp`? Normally, you'd want to modify your include statement in that case to reference the header file that is at the project root, one level above you:

```c
#include "../stdafx.h"
```

But Visual Studio will give you an error, claiming that the precompiled header could not be found. It is, all all files of the project, looking for an exact match to the precompiled header string "stdafx.h". If your source code is nested in multiple levels of folders, they must all include the precompiled header using the same string, with the folder containing the header listed in the include file search paths. In Premake-speak, you must do:

```lua
pchheader "stdafx.h"
includedirs { "." }  -- assuming the project file will be in this directory
```

And all of your source code files must include the header as:

```c
#include "stdafx.h"
```

If you actually do want to include a path in the include statement, you must match it exactly in your Premake script.

```c
#include "include/stdafx.h"
```
```lua
pchheader "include/stdafx.h"
```

If you need more information, or a more step-by-step explanation, here is [a good article on CodeProject](http://www.codeproject.com/Articles/320056/Projects-in-Visual-Cplusplus-2010-Part-3-Precompil) that covers the process of setting up precompiled headers for Visual Studio.

Note: When specifying `pchsource` make sure to include the path to the `pchsource` file just like you would for your regular source files. Otherwise Visual Studio will not build the ***.pch** file. An example is provided where src_dir is the path to your source code.

```lua
pchsource(src_dir.."stdafx.cpp")
files{src_dir.."**.h", src_dir.."**.cpp"}
```

## Considerations for Non-Visual Studio Tools

Premake does its best to make all of this just work transparently across all of its supported toolsets. For instance, if your header is located in a folder called `includes` and you set up your project like:

```lua
pchheader "stdafx.h"
includedirs { "includes" }
```

...Premake is smart enough to check the include search paths to locate the header, and create required force include in your generated Makefiles.

```make
FORCE_INCLUDE = -include includes/stdafx.h
```

If, for whatever reason, you can't follow the Visual Studio convention on your other platforms, you can always nest the header description in the appropriate configuration blocks.

```lua
filter "action:vs*"  -- for Visual Studio actions
	pchheader "stdafx.h"
	pchsource "stdafx.cpp"

filter "action:not vs*"  -- for everything else
	pchheader "includes/std.afx.h"
```

For reference, here is the [Clang Compiler User's Manual section on precompiled headers](http://clang.llvm.org/docs/UsersManual.html#usersmanual-precompiled-headers).

## Summary

The important things to remember here are:

* If you want your code to build with precompiled headers in Visual Studio, your `#include` statement must be exactly the same in all source code files. Or you can use compiler option /FI (Name Forced Include File) https://docs.microsoft.com/en-us/cpp/build/reference/fi-name-forced-include-file?view=vs-2017

* When specifying the PCH header in your Premake script, the value provided should match the value in your source code's `#include` statements exactly.

* The value provided to `pchheader` is treated as a *string*, not a *path* and is not made relative to the generated project file. Rather is it passed through as-is.

* If you have multiple folder levels in your source code tree, you must add the folder containing the header to be precompiled to your include file search paths.

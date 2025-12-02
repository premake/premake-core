---
title: callingconvention
description: Sets whether or not the compiler should build STL modules.
keywords: [premake, callingconvention, cdecl, fastcall, stdcall, vectorcall, function calling convention, compiler, project config]
---


Sets the [function calling convention](https://en.wikipedia.org/wiki/X86_calling_conventions).

```lua
callingconvention ("convention")
```

### Parameters ###

| Convention  | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| Cdecl       | Standard C calling convention; caller cleans the stack after the function.  |
| FastCall    | Passes some arguments via registers for faster function calls.              |
| StdCall     | Standard calling convention for WinAPI; callee cleans the stack.            |
| VectorCall  | Optimized for vector types; passes arguments in registers for performance.  |


### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

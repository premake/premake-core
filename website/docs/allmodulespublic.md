---
title: allmodulespublic
description: "Controls whether all C++ modules in the project are exported as public modules."
keywords: [premake,visual studio,modules,public]
---

Controls whether all C++ modules in the project are exported as public modules.

```lua
allmodulespublic "value"
```

### Parameters ###

| value | Description                                                   |
| ----- | ------------------------------------------------------------- |
| On    | All C++ modules in the given project(s) will be public.       |
| Off   | Not all C++ modules in the given project(s) will be public.[] |

## Applies To ###

The `config` scope.

### Availability ###

Visual Studio 2019 and later.
Premake 5.0-beta2 or later.

### Examples ###

```lua
allmodulespublic "On"
```


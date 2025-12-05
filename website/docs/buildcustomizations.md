---
title: buildcustomizations
description: Imports custom .props files for Visual Studio.
keywords: [premake, buildcustomizations, visual studio, props, project configuration]
---

Imports custom .props files for Visual Studio.

```lua
buildcustomizations { "name" }
```

### Parameters ###

`name` **string** — The name of the Visual Studio build customization to import (corresponding to a `.props` file, without extension)..

### Applies To ###

The `project` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
buildcustomizations { "string" }
```


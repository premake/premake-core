---
title: conformancemode
description: Enables or disables the compiler’s standards conformance mode.
keywords: [premake, conformancemode, standards conformance, permissive-, c++, visual studio, compiler options]
---

Controls whether the compiler enforces strict language standards conformance.
In Visual Studio, this corresponds to the `/permissive-` option, which turns on standard‑compliant C++ behavior and disables certain non‑standard Microsoft extensions.

```lua
conformancemode(enabled)
```

### Parameters ###

| enabled | Description                                                                                  |
| ------- | -------------------------------------------------------------------------------------------- |
| On      | Enable standards‑conformance mode (`/permissive-`), enforcing strict C++ compliance.         |
| Off     | Disable standards‑conformance mode, allowing Microsoft extensions and non‑standard behavior. |


## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 1 or later.

### Examples ###

```lua
conformancemode (value)
```


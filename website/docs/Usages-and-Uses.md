---
title: Usages & Uses
---

Defining how libraries of code are to be used is a crucial piece of any build system. Premake exposes this functionality via the `usage` and `uses` APIs. A `usage` specifies a reusable configuration scope which can be later consumed by `uses`.

Unlike other scopes, usages do not inherit their properties from their parent scopes. This is to ensure that consumers only receive the configuration explicitly specified by the usage block.

```lua
project "A"
  defines { "A_PRIVATE_DEF" }
  usage "PUBLIC"
    defines { "A_PUBLIC_DEF" }

project "B"
    uses { "A" }
    -- B will now contain the defines { "A_PUBLIC_DEF" }
```

Usage containers can be provided with any name, however Premake provides three names of power. These words of power allow specifying the name of a project in the `uses` field rather than having to specify the exact name of the usage block.

* `PRIVATE` specifies a usage block that will be applied only to the project defining the usage. This is the default behavior of properties defined outside of usage blocks in Premake.
* `INTERFACE` specifies a usage block that will be applied only to any projects consuming the usage.
* `PUBLIC` specifies a usage that will be applied to both the project defining the usage and any projects consuming the usage.

Usages are not applied recursively by default. This is to match the existing Premake behaviors where everything is private by default. In order to apply usages recursively, usage blocks can be utilized to specify which usages should be propagated to the children. This chain can be applied indefinitely by specifying the usages that should be applied in each project's `PUBLIC` block.

```lua
project "A"
  usage "PUBLIC"
    defines { "A_PUBLIC_DEF" }

project "B"
  usage "PUBLIC"
    uses { "A" }
    defines { "B_PUBLIC_DEF" }

project "C"
  -- C will now contain the defines { "A_PUBLIC_DEF", "B_PUBLIC_DEF" }
  uses { "B" }
```

Similarly, for forcing consumers to link or depend on your project, we can specify a usage block as follows:

```lua
project "MyLib"
  -- Force consumers to link MyLib, but do not force MyLib to link against it
  usage "INTERFACE"
    links { "MyLib" }

project "MyExe"
  -- MyExe will now link against MyLib
  uses { "MyLib" }
```

It's worth noting that `usage` blocks do not need to be named with a name of power. They can be specified and used as follows:

```lua
project "A"
  usage "MyCustomUsageName"
    defines { "HelloWorld" }

project "B"
  uses { "MyCustomUsageName" }
```

### See Also ###

* [usage](usage.md)
* [uses](uses.md)

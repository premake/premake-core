Specifies the target operation system min and max versions.

```lua
systemversion ("value")
```

### Parameters ###

`value` is a colon-delimited string specifying the min and max version, `min:max`.

### Applies To ###

Project.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "Windows" }

   filter "system:Windows"
      systemversion "10.0.10240.0" -- To specify the version of the SDK you want
```

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "Windows" }

   filter "system:Windows"
      systemversion "latest" -- To use the latest version of the SDK available
```

### See Also ###

* [system](system.md)

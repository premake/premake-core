Specifies a list of libraries or assembly references which should be copied to the target directory as part of the build. Refer to the Visual Studio C# project feature of the same name.

```lua
copylocal { "libraries" }
```

If a project includes multiple calls to `copylocal` the lists are concatenated, in the order in which they appear in the script.

Note that, by default, all referenced non-system assemblies in a C# project are copied. This function only needs to called when a subset of the referenced assemblies should be copied. To disable copying of *all* references, use the `NoLocalCopy` build flag instead (see Examples, below).

### Parameters ###

`libraries` is a list of the libraries or assemblies to be copied as part of the build. The names specified here should match the names used in the call to `links()`.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 and later. This feature is currently only supported for Visual Studio C# projects.

### Examples ###

Copy only the **Renderer** and **Physics** assemblies to the target directory; do not copy **nunit.framework**. Note that the links may refer to project or assembly references.

```lua
links { "Renderer", "Physics", "nunit.framework" }
copylocal { "Renderer", "Physics" }
```

The link should be specified in exactly the same way in both `links()` and `copylocal()`.

```lua
links { "Renderer", "../ThirdParty/nunit.framework" }
copylocal { "../ThirdParty/nunit.framework" }
```

If you want to prevent any assemblies from being copied, use the **NoLocalCopy** flag instead.

```lua
flags { "NoCopyLocal" }
```

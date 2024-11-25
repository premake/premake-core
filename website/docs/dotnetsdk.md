Selects a .NET SDK

```lua
dotnetsdk "SDK"
```

For more information see the MSDN documentation [here](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview)

## parameters ##
`SDK` is one of:

 * [Default](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props)
 * [Web](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/web-sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [Razor](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [Worker](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers)
 * [Blazor](https://learn.microsoft.com/en-us/aspnet/core/blazor/)
 * [WindowsDesktop](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props-desktop?view=aspnetcore-8.0)
 * [MSTest](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-sdk)


## mstest ##
when using MSTest sdk a version has to be specified!
### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 beta4 or later.

Visual studio is the only toolset currently supported.

### Examples ###
```lua
dotnetsdk "Web"
```

```lua
dotnetsdk "Web/3.4.0"

```
## CustomSDK

```lua
premake.api.addAllowed("dotnetsdk", "CustomSDK") -- add the customSDK to allowed values for dotnetsdk
dotnetsdk "CustomSDK/3.4.0"
```

```lua
premake.api.addAllowed("dotnetsdk", "CustomSDK") -- add the customSDK to allowed values for dotnetsdk
dotnetsdk "CustomSDK"
```

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
SDK used for MSTest is `"3.6.1"`, to use another version create or update global.json near the solution.
### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 beta3 or later.

Visual studio is the only toolset currently supported.

### Examples ###
```lua
dotnetsdk "Web"
```

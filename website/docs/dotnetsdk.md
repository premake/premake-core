Selects a .NET Sdk

```lua
dotnetsdk "sdk"
```

[overview](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview)

## parameters ##
`sdk` is one of
 * [web](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/web-sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [razor](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [worker](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers)
 * [blazor](https://learn.microsoft.com/en-us/aspnet/core/blazor/)
 * [windowsdesktop](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props-desktop?view=aspnetcore-8.0)
 * [mstest](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-sdk)


## mstest ##
to make the MSTest sdk work you need to add the version to `global.json`:
```json
{
    "msbuild-sdks": {
        "MSTest.Sdk": "3.6.1"
    }
}
```
:::warning
`global.json` needs to be located in the same folder as your solution
:::

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 beta3 or later.

Visual studio is the only toolset currently supported.

### Examples ###
use the web sdk

```lua
dotnetsdk "web"
```

Selects a .NET SDK

```lua
dotnetsdk "SDK"
```

For more information see the MSDN documentation [here](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview)

## parameters ##
`SDK` is one of:

 * [web](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/web-sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [razor](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json)
 * [worker](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers)
 * [blazor](https://learn.microsoft.com/en-us/aspnet/core/blazor/)
 * [windowsdesktop](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props-desktop?view=aspnetcore-8.0)
 * [mstest](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-sdk)


## mstest ##
To make the MSTest SDK work you need to add the version to `global.json`:
```json
{
    "msbuild-sdks": {
        "MSTest.Sdk": "3.6.1"
    }
}
```
:::note
`global.json` will be auto generated when it does not exist!
:::

:::warning
`global.json` needs to be located in the same folder as your solution.
:::

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 beta3 or later.

Visual studio is the only toolset currently supported.

### Examples ###
```lua
dotnetsdk "Web"
```

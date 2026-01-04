Selects a .NET SDK

```lua
dotnetsdk ("SDK")
```

For more information see the MSDN documentation [here](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview)

## Parameters ##
`SDK` is one of:

| SDK | Description | Notes |
|-----|-------------|-------|
| Default | Uses the default .NET SDK | [Default](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props) |
| Web | Uses the Web SDK | [Web](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/web-sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json) |
| Razor | Uses the Razor SDK | [Razor](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/sdk?toc=%2Fdotnet%2Fnavigate%2Ftools-diagnostics%2Ftoc.json&bc=%2Fdotnet%2Fbreadcrumb%2Ftoc.json) |
| Worker | Uses the Worker SDK | [Worker](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers) |
| Blazor | Uses the Blazor SDK | [Blazor](https://learn.microsoft.com/en-us/aspnet/core/blazor/) |
| WindowsDesktop | Uses the Windows Desktop SDK | [WindowsDesktop](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props-desktop?view=aspnetcore-8.0) |
| MSTest | Uses the Microsoft Test SDK | [MSTest](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-sdk), Requires a version to be specified |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta5 or later for Visual Studio only.

### Examples ###
Specify an SDK.
```lua
dotnetsdk "Web"
```

Specify with an SDK and a version.
```lua
dotnetsdk "Web/3.4.0"
```

A custom SDK can be specified using the following:
```lua
premake.api.addAllowed("dotnetsdk", "CustomSDK") -- add the custom SDK to allowed values for dotnetsdk
dotnetsdk "CustomSDK"

dotnetsdk "CustomSDK/3.4.0" -- Specifying a version with a custom SDK is also supported
```

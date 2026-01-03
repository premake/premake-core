Replaces some function calls with intrinsic or otherwise special forms of the function that help your application run faster.

[Visual Studio 2017's Description of Intrinsics](https://docs.microsoft.com/en-us/cpp/build/reference/oi-generate-intrinsic-functions?view=vs-2017)

```lua
intrinsics ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Enables intrinsic functions which generate faster, but possibly longer code. |
| Off   | Disables intrinsic functions. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later for Visual Studio or the MSC toolset.

### Examples ###

```lua
intrinsics "On"
```


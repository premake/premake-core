Replaces some function calls with intrinsic or otherwise special forms of the function that help your application run faster.

[Visual Studio 2017's Description of Intrinsics](https://docs.microsoft.com/en-us/cpp/build/reference/oi-generate-intrinsic-functions?view=vs-2017)

```lua
intrinsics "value"
```

### Parameters ###

`value` one of:
* `on`  - Enables intrinsic functions which generate faster, but possibly longer code.
* `off` - Disables intrinsic functions.

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
intrinsics "On"
```


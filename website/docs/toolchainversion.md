Specifies the version of the toolchain to use.

```lua
toolchainversion ("value")
```

### Parameters ###

`value` is one of:

### Android Projects ###

* `4.6`: GCC 4.6
* `4.8`: GCC 4.8
* `4.9`: GCC 4.9
* `3.4`: Clang 3.4
* `3.5`: Clang 3.5
* `3.6`: Clang 3.6
* `3.8`: Clang 3.8
* `5.0`: Clang 5.0

### Linux Projects ###

* `remote`: Remote Compilation and Debugging
* `wsl`: Windows Subsystem for Linux
* `wsl2`: Windows Subsystem for Linux 2

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later, only applies to Android projects.
Premake 5.0.0 beta 3 or later, only applies to Visual Studio Linux projects.

### Examples ###

```lua
toolchainversion "5.0"
```


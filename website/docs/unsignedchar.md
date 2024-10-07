Force sign of `char`

```lua
unsignedchar (value)
```

Note that `char` is still a distinct type from `signed char` and `unsigned char`.

### Parameters ###

`value` is one of:


* Off: Make `char` signed. (default on msc)
* On: Make `char` unsigned.

Don't use that api to have default for gcc/clang

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
unsignedchar "On"
```

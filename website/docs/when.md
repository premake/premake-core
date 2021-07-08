Conditionally apply build settings.  See [Conditional Settings](authoring/conditional-settings.md) for a complete explanation.

```lua
when({ 'condition', ... }, function ()
	-- settings
end)
```

The settings contained in the callback will only be applied when all of the supplied conditions have been met.

### Parameters

`condition` is an array of one or more conditions, eg. `{ 'configurations:Debug' }`.

`function` is a callback which specifies the build settings associated with the provided conditions. Note that _this callback will be invoked immediately_. The conditions and provided settings will be stored and evaluated later within the context of a specific [action](actions/about-actions.md).

### Return Value

None.

### Availability

Premake 6.0 and later.

### See Also

- [Conditional Settings](authoring/conditional-settings.md)

### Examples

Apply preprocessor symbols to specific build configurations.

```lua
when({ 'configurations:Debug' }, function ()
  defines { '_DEBUG' }
end)

when({ 'configurations:Release' }, function ()
  defines { 'NDEBUG' }
end)
```

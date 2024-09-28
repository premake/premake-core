Gets the value of an environment variable from the host system.

```lua
id = os.getenv(var)
```

### Parameters ###

`var` Environment variable name.

### Return Value ###

Returns the value of the environment variable if one is set, or nil.

### Availability ###

Premake 4.0 or later.

### Examples ###

```lua
if os.getenv('FOO') == "bar" then
   -- do something specific when FOO=bar
end
```

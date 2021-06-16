# premake.callArray

Call an array of functions.

```lua
premake = require('premake')
path = premake.callArray(funcs, args...)
```

## Parameters

`funcs` is a list of functions to be called, or a function which returns a list of functions.

`...` is an optional list of argument(s) to be passed to the functions.

## Return Value

None.

## Availability

Premake 5.0 or later.

Returns a [Universally Unique Identifier](http://en.wikipedia.org/wiki/UUID).

```lua
id = os.uuid(name)
```

### Parameters ###

`name` is an optional string value. If provided, it will be used to create a deterministic, hash-based identifier.

### Return Value ###

A new UUID, a string value with the format <b>74CFC033-FA4D-4B1E-A871-7DC48FA36769</b>.

### Availability ###

Premake 4.0 or later.

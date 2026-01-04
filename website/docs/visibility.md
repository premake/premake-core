Sets the default visibility for exported symbols in a shared object library.

```lua
visibility ("switch")
```

By default, the generated project files will use the compilers default settings symbol visibility when building shared object libraries.

### Parameters ###

`switch` is an identifier for symbol information.

| Option      | Availability |
|-------------|--------------|
| `Default`   | gcc          |
| `Hidden`    | gcc          |
| `Internal`  | gcc          |
| `Protected` | gcc          |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

This project hides exported symbols for release builds.

```lua
project "MyProject"
    filter "configurations:Release"
        visibility "Hidden"
```

### See Also ###

 * gcc page about [visibility](https://gcc.gnu.org/wiki/Visibility)

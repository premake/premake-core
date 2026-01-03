Sets the programming language used by a project.

```lua
language ("lang")
```

### Parameters ###

`lang` is the language identifier. Some languages require a module for full support.

| Language | Module                        |
|----------|-------------------------------|
| `C`      | Built-in; always available    |
| `C++`    | Built-in; always available    |
| `C#`     | Built-in; always available    |
| `F#`     | Built-in; always available    |


### Applies To ###

Project configurations.

### Availability ###

`C`, `C++`, and `C#` are available in Premake 4.0 or later. Others are 5.0.0-alpha1 or later.

### Examples ###

Set the project language to C++.

```lua
language "C++"
```

Set the project language to C#

```lua
language "C#"
```

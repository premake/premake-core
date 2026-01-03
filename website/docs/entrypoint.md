Specify the program entry point, e.g. `main()`.

```lua
entrypoint ("value")
```

### Parameters ###

`value` is the name of the program's entry point function.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.


### Examples ###

Use the Microsoft Windows console application entry point instead of the usual `WinMain()`.

```lua
entrypoint "mainCRTStartup"
```


### See Also ###

* [`WinMain` flag](flags.md)

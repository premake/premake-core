Opens a REPL (replace-eval-print loop) prompt where you can enter and evaluate Lua commands against the current script environment.

```lua
debug.prompt()
```

This call is also tied to the `--interactive` flag: specifying this flag will open a prompt after the project scripts have been executed and "baked" for the current environment.

### Availability ###

Premake 5.0.0-alpha1 or later.

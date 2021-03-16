Places files into groups or "virtual paths", rather than the default behavior of mirroring the filesystem in IDE-based projects. So you could, for instance, put all header files in a group called "Headers", no matter where they appeared in the source tree.

```lua
vpaths { ["group"] = "pattern(s)" }
```

Note that Lua tables do not maintain any ordering between key-value pairs, so there is no precedence between the supplied rules. That is, you can't write a rule that rewrites the results of an earlier rule, since there is no guarantee in which order the rules will run.

### Parameters ###

A list of key/value pairs, specified with Lua's standard syntax, which map file patterns to the group in which they should appear. See the examples below for a more complete explanation.

### Applies To ###

Project configurations. [Not all exporters currently support](Feature-Matrix.md) per-configuration file lists however.

### Availability ###

Premake 4.4 or later.

### Examples ###

Place all header files into a virtual path called "Headers". Any directory information is removed, so a path such as `src/lua/lua.h` will appear in the IDE as `Headers/lua.h`.

```lua
vpaths { ["Headers"] = "**.h" }
```

You may also specify multiple file patterns using the table syntax.

```lua
vpaths {
   ["Headers"] = { "**.h", "**.hxx", "**.hpp" }
}
```

It is also possible to include the file's path in the virtual group. Using the same example as above, this rule will appear in the IDE as `Headers/src/lua/lua.h`.

```lua
vpaths { ["Headers/*"] = "**.h" }
```

Any directory information explicitly provided in the pattern will be removed from the replacement. This rule will appear in the IDE as `Headers/lua/lua.h`.

```lua
vpaths { ["Headers/*"] = "src/**.h" }
```

You can also use virtual paths to remove extra directories from the IDE. For instance, this rule will cause the previous example to appear as `lua/lua.h`, removing the `src` part of the path from *all* files.

```lua
vpaths { ["*"] = "src" }
```

And of course, you can specify more than one rule at a time.

```lua
vpaths {
   ["Headers"] = "**.h",
   ["Sources/*"] = {"**.c", "**.cpp"},
   ["Docs"] = "**.txt"
}
```

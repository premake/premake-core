Returns the list of tags corresponding to a system.

There are tags specific to each operating system (see [system()](system.md) for a complete list of identifiers.),
and meta tags like `posix`, `darwin`, `desktop` and `mobile` tags.

### Tags ###

| OS       | Tags                                    |
|----------|-----------------------------------------|
| aix      | aix, posix, desktop                     |
| android  | android, mobile                         |
| bsd      | bsd, posix, desktop                     |
| haiku    | haiku, posix, desktop                   |
| ios      | ios, darwin, posix, mobile              |
| linux    | linux, posix, desktop                   |
| macosx   | macosx, darwin, posix, desktop          |
| solaris  | solaris, posix, desktop                 |
| tvos     | tvos, darwin, posix, mobile             |
| uwp      | uwp, windows, desktop                   |
| windows  | windows, win32, desktop                 |

### Examples ###

```lua
print("iOS system tags: " .. table.concat(os.getSystemTags("ios"), ", "))
-- iOS system tags: ios, darwin, posix, mobile
```

### See Also ###
[os.istarget](os.istarget.md)
[os.target](os.target.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.


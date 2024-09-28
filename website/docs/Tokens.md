---
title: Tokens
---

Tokens provide the ability to substitute computed values into a configuration setting. Using tokens, you can specify a single value that automatically adjusts itself to different platforms and configurations.

Tokens come in two varieties: *value tokens*, and *command tokens*.

## Value Tokens

Value tokens are expressions wrapped in a `%{}` sequence. Tokens have access to one or more context objects, depending on their scope within the project: `wks`, `prj`, `cfg`, and `file`. You can access all of the fields of these context objects within the token.

```lua
%{wks.name}
%{prj.location}
%{cfg.targetdir}
```

The contents of the %{} are run through `loadstring()` and executed at token-replacement time, so more complex replacements can be used. You can access any global value.

```lua
%{wks.name:gsub(' ', '_')}
```

You can use `wks`, `prj`, `cfg`, and `file` to represent the current workspace, project, configuration, and file configuration respectively. Note that these values must be in scope for the type of value you are trying to substitute or the object will be nil. You'll have to hunt around for the available fields until I have a chance to document them, but in general they follow the API names (includedirs, location, flags, etc.).

Some known tokens (feel free to add more as you use them):

```lua
wks.name
wks.location -- (location where the workspace/solution is written, not the premake-wks.lua file)

prj.name
prj.location -- (location where the project is written, not the premake-prj.lua file)
prj.language
prj.group

cfg.longname
cfg.shortname
cfg.kind
cfg.architecture
cfg.platform
cfg.system
cfg.buildcfg
cfg.buildtarget -- (see [target], below)
cfg.linktarget -- (see [target], below)
cfg.objdir

file.path
file.abspath
file.relpath
file.directory
file.reldirectory
file.name
file.basename -- (file part without extension)
file.extension -- (including '.'; eg ".cpp")

-- These values are available on build and link targets
-- Replace [target] with one of "cfg.buildtarget" or "cfg.linktarget"
--   Eg: %{cfg.buildtarget.abspath}
[target].abspath
[target].relpath
[target].directory
[target].name
[target].basename -- (file part without extension)
[target].extension -- (including '.'; eg ".cpp")
[target].bundlename
[target].bundlepath
[target].prefix
[target].suffix
```

The paths are expanded relative to premake script, to obtain absolute paths, you have to add `!` as in `%{!file.path}`.

## Command Tokens

Command tokens represent a system level command in a shell-neutral way.

```lua
postbuildcommands {
	"{COPYFILE} %[file1.txt] %[file2.txt]"
}
```


You can use command tokens anywhere you specify a command line, including:

* [buildcommands](buildcommands.md)
* [cleancommands](cleancommands.md)
* [os.execute](os/os.execute.md)
* [os.executef](os/os.executef.md)
* [postbuildcommands](postbuildcommands.md)
* [prebuildcommands](prebuildcommands.md)
* [prelinkcommands](prelinkcommands.md)
* [rebuildcommands](rebuildcommands.md)

Command tokens are replaced with an appropriate command for the target shell. For Windows, path separators in the commmand arguments are converted to backslashes.

The available tokens, and their replacements:

| Token      | DOS/cmd                                     | Posix           |
|------------|---------------------------------------------|-----------------|
| {CHDIR}    | chdir {args}                                | cd {args}       |
| {COPYFILE} | copy /B /Y {args}                           | cp -f {args}    |
| {COPYDIR}  | xcopy /Q /E /Y /I {args}                    | cp -rf {args}   |
| {DELETE}   | del {args}                                  | rm -rf {args}   |
| {ECHO}     | echo {args}                                 | echo {args}     |
| {MKDIR}    | IF NOT EXIST {args} (mkdir {args})          | mkdir -p {args} |
| {MOVE}     | move /Y {args}                              | mv -f {args}    |
| {RMDIR}    | rmdir /S /Q {args}                          | rm -rf {args}   |
| {TOUCH}    | type nul >> {arg} && copy /b {arg}+,, {arg} | touch {args}    |

:::caution
The following tokens are deprecated:
:::

| Token      | DOS                                         | Posix           | Remarks                             |
|------------|---------------------------------------------|-----------------|-------------------------------------|
| {COPY}     | xcopy /Q /E /Y /I {args}                    | cp -rf {args}   | Use {COPYDIR} or {COPYFILE} instead |

### Path in commands

Paths in Premake should be relative to premake script in which they appears.

When you specify a path inside a commands, you have to wrap path insice `%[]` to allow correct trnasformation for the generator.

i.e.

```lua
buildcommands {
	"{COPYFILE} %[%{!file.abspath}] %[%{!sln.location}/%{file.basename}]"
}
```

## Tokens and Filters

Tokens are not expanded in filters. See [issue 1306](https://github.com/premake/premake-core/issues/1036#issuecomment-379685035) for some illustrative examples.

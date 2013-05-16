Premake Extension to support the [D](http://dlang.org) language

### Why ###
This code is an extension to the core Premake codebase to enable additional
functionality to be provided to that most excellent build system without having
to disturb, or disrupt the core functionality.

It does this through the auspices of the underlying [Lua](http://www.lua.org) technology
which easily enables loading extra functions into the system at runtime.

### How ###

Lua provides a well defined mechanism for locating modules at execution time.
As Premake is built around a standard Lua core, the normal Lua module loading
mechanism is available, and utilised by this extension.

To allow the Lua engine to locate the extension code, it is necessary to
provide a single hint in the form of a path definition for the 
[require](http://www.lua.org/pil/8.1.html) function to be able to load the
extension(s) on demand.

eg.
```
#!bash
LUA_PATH=/path/to/extension/?.lua premake4 gmake
```

which instructs Lua to use the nominated path when attempting to load any //required// modules.
Hence, by specifying the path to the directory containing this extension in the
environment variable LUA_PATH, the build system can locate, load and execute
this code.  All that is then necessary to enable support for the "D" Premake
extension is to add the following statement to the top of your premake4.lua
file:

```
#!lua
require "d"
```

### Example ###

Simplisticly, lets assume you have the [Premake D Extension](https://bitbucket.org/premakeext/d) 
checked out to "/home/user/premake-ext/d" and have a D console application project with the following 
structure:

```
project
  |
  +- src
  |  |
  |  +- main.d
  |  |
  |  +- extra.d
  |
  +- premake4.lua

```
Then the contents of your premake4.lua file would be:

```
#!lua
require "d"

solution "MySolution"
    configurations { "release", "debug" }

    project "MyDProject"
        kind "ConsoleApp"
        language "D"
        files { "src/main.d", "src/extra.d" }
```

and you **MUST** then execute Premake as follows:

```
#!bash
$ LUA_PATH=/home/user/premake-ext/d/?.lua premake4 gmake
$ make
(happiness)
```

### Additional Niceties ###

A pull request will be initiated against the [Premake Dev](https://bitbucket.org/premake/premake-dev) 
code to automatically add some standard extension paths to the Lua
'package.path' (ie. LUA_PATH) setting to enable looking for extensions in
standard places.  If you then have extension(s) checked out in one of those
standard locations, there will be no need to provide an additional
environmental override to locate them, and you will be able to utilise as many
extensions as needed with ease.  The current list of standard locations is
currently:

```
        1. {PREMAKE_PATH}/ext/?/?.lua
        2. ./premake/?/?.lua
        3. ~/.premake/?/?.lua
        4. /usr/share/premake/?/?.lua
```
Hence, extensions may reside alongside the Premake executable itself (1), in
the current project directory (2), in the users home directory (3), or
system-wide (4).


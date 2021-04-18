---
title: Sharing Configuration Settings
---

> I'm very interested in having a project A be able to specify information that project B can use to compile and link against project A, without having to repeat that information all over the place.

There have been discussions on forums new and old about this in the past; search for "usages". It would be great to pull those together here for reference if anyone gets a chance. In the meantime, feel free to add your approaches below.

---

**@starkos:** We use functions here. For specifying how to compile and link against a library:

```lua
-- How to declare it
function someLibrary(options)
   defines { ... }
   links { ... }
   options = options or {}
   if options.someFlag then
      defines { ... }
   end
end

-- How to use it
project "someOtherProject"
   kind "ConsoleApp"
   someLibrary { someFlag="true" }
```

And for defining "classes" of projects:

```lua
function someComponent_test(name)
   project(name)
   kind "ConsoleApp"
   defines { ... }
   links { ... }
   filter {}
end
```

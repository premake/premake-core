---
title: Coding Conventions
---

When in doubt, follow the existing code style.

### Method calling styles

Be aware that calling methods using `:` is measurably slower than `.`, due to the required extra table lookups.

```lua
# faster
string.len(x)

# slower
x:len()
```

However, using `:` can lead to more concise, more readable code, so it's a tradeoff. Until there is profiling data to suggest otherwise, we're using `.` for the host code and core modules, and `:` for everything else.

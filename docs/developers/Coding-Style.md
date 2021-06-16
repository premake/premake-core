### `.` versus `:` calling styles

Be aware the calling methods using `:` is measurably slower than `.`.

```lua
# faster
string.len(x)

# slow
x:len()
```

However, using `:` can lead to more concise, more readable code. Until I have profiling data to suggest otherwise, I'm sticking to `.` calls for the core code, and probably also for most of the module logic. I'm allowing `:` in places where I believe the performance hit is justified for better readability, ex. the unit test suites.

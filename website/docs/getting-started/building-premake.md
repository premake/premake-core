---
title: Building Premake
---

I'm not planning to make any official release of Premake6 until I feel it has reached a beta level of development.  In the meantime, you'll have to grab the source from the `6.x` branch of [premake-core](https://github.com/premake/premake-core).

I also haven't supplied a bootstrapping makefile yet, so you'll need to use a working install of Premake5 to generate project files for Premake6.

I also haven't implemented script embedding yet, so you'll have to run Premake6 in place.

```bash
# Generate project files
premake5 gmake

# Build
make config=debug

# Test
bin/debug/premake6 test

# Run
bin/debug/premake6 vstudio
```


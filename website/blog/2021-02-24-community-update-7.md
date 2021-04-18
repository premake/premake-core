---
title: "Community Update #7"
tags: [community-updates]
author: starkos
author_url: https://github.com/starkos
author_image_url: https://avatars.githubusercontent.com/u/249247?v=4
author_title: Premake Admin & Developer
---

A quick update this cycle so I can get right back to it: I managed to free up meaningful blocks of time for Premake in February—felt good!—and tackle **files** and **removeFiles**, support configuration and platform specific files, and get it all exporting to Visual Studio (…and bulldoze through the rabbit holes along the way). From the user-facing side not a big change, but [a hefty commit](https://github.com/starkos/premake-next/commit/f5cb8678a6cc2939faceacbb8143bd9a094709f6) just the same. The core platform is starting to feel reasonably complete.

### What's Next

- For real this time, first thing: step away from the code and open an RFC on merging the projects. I've never been great at that whole "stepping away from the code" thing but I'll do my very best.
- Work with [@KyrietS](https://github.com/KyrietS) to bring [a new & improved documentation system online](https://github.com/premake/premake-core/pull/1587).

Longer term: push to get the new code to the point where it can generate its own Visual Studio project files. I've actually done a good chunk of work on this, but wasn't quite able to bring it home this month. Then do the same with Xcode.

### Meanwhile in V5

The community making the world a better place…

- [#1551](https://github.com/premake/premake-core/pull/1551) Add NetCore to CLR API ([@nickclark2016](https://github.com/nickclark2016))
- [#1554](https://github.com/premake/premake-core/pull/1554) [clang] Use `llvm-ar` linker when LTO flag is set ([@JoelLinn](https://github.com/JoelLinn))
- [#1552](https://github.com/premake/premake-core/pull/1552) Fix MSC LTO, runtime, subsystem ([@JoelLinn](https://github.com/JoelLinn))
- [#1560](https://github.com/premake/premake-core/pull/1560) Add newer shader versions ([@dpeter99](https://github.com/dpeter99))
- [#1562](https://github.com/premake/premake-core/pull/1562) Remove moduledownloader to avoid RCE ([@gibbed](https://github.com/gibbed))
- [#1564](https://github.com/premake/premake-core/pull/1564) Improve .NET version check to support net5.0+ ([@ClxS](https://github.com/ClxS))
- [#1565](https://github.com/premake/premake-core/pull/1565) Move AllowUnsafeBlocks to project level property ([@ClxS](https://github.com/ClxS))
- [#1566](https://github.com/premake/premake-core/pull/1566) Set execute bit on Bootstrap.bat ([@ratzlaff](https://github.com/ratzlaff))
- [#1571](https://github.com/premake/premake-core/pull/1571) Add useFullPaths for Visual Studio projects ([@cos-public](https://github.com/public))
- [#1576](https://github.com/premake/premake-core/pull/1576) Mesh and amplification shader type for Visual Studio ([@pkurth](https://github.com/pkurth))

### Thanks!

Kudos and a call out to **[@samsinsane](https://github.com/samsinsane)** and the contributors listed above, **[CitizenFX Collective](https://opencollective.com/_fivem#section-contributions)** for their continued strong financial support, and to [all of our monthly backers](https://opencollective.com/premake#section-contributors)! Be sure to check out their work and support them back if you can!

Lots of big changes happening—I welcome questions, suggestions, and concerns. Everything is up for discussion, from the feature set to the coding style. You can message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at starkos@industriousone.com, or open an issue on [the premake-next GitHub project](https://github.com/starkos/premake-next).

~st.

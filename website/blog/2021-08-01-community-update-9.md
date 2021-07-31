---
title: "Community Update #9"
tags: [community-updates]
author: starkos
author_url: https://github.com/starkos
author_image_url: https://avatars.githubusercontent.com/u/249247?v=4
author_title: Premake Admin & Developer
---

I can't believe we're already eight months into 2021, how did this happen.

### **Branch, don't backport**

In the last update, I asked for input on where the work going into [premake-next](https://github.com/starkos/premake-next) should end up: branch a new 6.x major version, or backport the changes to 5.x? There was [solid consensus](https://github.com/premake/premake-core/discussions/1616) that premake-next should be treated as a new major version, with v5 upgraded to a stable release for on-going support. Thanks to everyone who participated and offered feedback!

With that settled, I've archived the premake-next repository and moved all development to [a new 6.x branch on premake-core](https://github.com/premake/premake-core/tree/6.x). As of the next release, I'll be upgrading the status of 5.0 from alpha to beta, with the intention of making the first stable release shortly.

### The Path to 5.0

Premake's perpetual alpha status [causes confusion](https://github.com/premake/premake-core/issues/1536) and makes it [difficult for some people to adopt](https://github.com/premake/premake-core/issues/1423). We've been hanging on to that label in the hope we'd get a chance to overhaul the makefile and Xcode exporters. But now that we have a v6 branch it makes sense break things over there instead, and get v5 to a stable release sooner rather than later.

I've [opened a 5.0 milestone](https://github.com/premake/premake-core/milestone/3) on the project and will be assigning a few issues to myself there. If you have a backward-compatibility breaking change that you feel must get in before 5.0 becomes stable, open or escalate an issue ASAP so we can get it on the roadmap. And as ever, we're all really busy, so any help getting this over the finish line is much appreciated!

### Premake6

In other news, Premake6 can now generate its own Visual Studio project files and bootstrap itself. That doesn't sound very impressive, but it does means that all of the under the hood stuff is now online and working as intended, and a full vertical slice has been completed. 🎉

[@nickclark2016](https://github.com/nickclark2016) has volunteered to begin looking into a new-and-improved makefile exporter, which frees me up to start looking at Xcode and improving the way we represent toolsets like Clang and GCC. The stable release of 5.0 is likely to take up all the air in the room for a bit, but hopefully I can report progress on those soon.

### Community Contributions

The community keeps things rolling—many thanks to everyone listed here!

- [#1570](https://github.com/premake/premake-core/pull/1570) Initial C++20 module support for Visual Studio ([@hannes-harnisch](https://github.com/hannes-harnisch))
- [#1625](https://github.com/premake/premake-core/pull/1625) Remove "*ng" action deprecation and auto-fix ([@noresources](https://github.com/noresources))
- [#1635](https://github.com/premake/premake-core/pull/1635) Fix typo in Using Premake documentation ([@abhiss](https://github.com/abhiss))
- [#1638](https://github.com/premake/premake-core/pull/1638) Fix broken links in docs ([@KyrietS](https://github.com/KyrietS))
- [#1642](https://github.com/premake/premake-core/pull/1642) Fix spelling mistake ([@Troplo](https://github.com/Troplo))
- [#1644](https://github.com/premake/premake-core/pull/1644) Fix author name and update time on pages ([@KyrietS](https://github.com/KyrietS))
- [#1645](https://github.com/premake/premake-core/pull/1645) Add missing support for prebuildmessage/postbuildmessage for Codelite ([@Jarod42](https://github.com/Jarod42))
- [#1649](https://github.com/premake/premake-core/pull/1649) Fix curl header search path ([@depinxi](https://github.com/depinxi))
- [#1654](https://github.com/premake/premake-core/pull/1654) xcode4: Fix missing link of sibling project with custom targetextension ([@depinxi](https://github.com/depinxi))
- [#1655](https://github.com/premake/premake-core/pull/1655) Compiler Version support for Visual Studion 2017+ ([@nickclark2016](https://github.com/nickclark2016))
- [#1657](https://github.com/premake/premake-core/pull/1657) Renormalize line endings ([@nickclark2016](https://github.com/nickclark2016))
- [#1663](https://github.com/premake/premake-core/pull/1663) compilebuildoutputs make some comments obsolete ([@Jarod42](https://github.com/Jarod42))
- [#1668](https://github.com/premake/premake-core/pull/1668) Fix v6 bootstrapping from v5 ([@starkos](https://github.com/starkos))
- [#1673](https://github.com/premake/premake-core/pull/1673) Updated sidebar to include toolsversion link ([@nickclark2016](https://github.com/nickclark2016))
- [#1662](https://github.com/premake/premake-core/pull/1662) Handle buildcommand for Codelite ([@Jarod42](https://github.com/Jarod42))
- [#1658](https://github.com/premake/premake-core/pull/1658) Fix D module compiler output for visual studio ([@nickclark2016](https://github.com/nickclark2016))

Additional gratitude and good wishes to everyone who helped review pull requests and triage issues this cycle. Projects like this don't work without you.

<div style={{textAlign: 'center'}}>
	<a href="https://opencollective.com/_fivem">
		<img src="https://images.opencollective.com/_fivem/2f78b5f/logo/128.png"/>
	</a>
</div>

A big shout out to our premier sponsor **[Cfx.re](https://opencollective.com/_fivem)** and all [our monthly backers](https://opencollective.com/premake#section-contributors)—be sure to check out their work and support them back if you can!

I welcome questions, suggestions, and concerns. Message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at [starkos@industriousone.com](mailto:starkos@industriousone.com), or [open a discussion on GitHub](https://github.com/premake/premake-core/discussions).

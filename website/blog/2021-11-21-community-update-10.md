---
title: "Community Update #10"
tags: [community-updates]
authors: starkos
---

### Premake 5.0-beta1! 🥳

After one of the world's longest alpha cycles, Premake5 has finally entered beta! I don't know about you, but I definitely had a drink to celebrate. Might have been two, even. Probably.

As [previously discussed](/blog/2021/08/01/community-update-9#the-path-to-50), we've started the process of stabilizing 5.0 and shifting breaking changes over to the new v6.x branch. We've [set up a milestone to track our progress](https://github.com/premake/premake-core/milestone/3) toward a stable 5.0 release, and this is the first step in working it down.

Most of the changes in the queue are under-the-hood: release automation, bootstrapping, and unit test fixes. The only potentially significant breaking change remaining is [promoting the `gmake2` exporter](https://github.com/premake/premake-core/issues/1099), which I will be prioritizing for the next beta. If you happen to still be using the older `gmake` exporter, please give `gmake2` a try and let us know if you encounter issues! Most fixes have been going to `gmake2` lately, so we expect your experience will be a good one.

{/* truncate */}

### Premake6

As of this morning, Premake6 is now "self-hosting" on Visual Studio, Make, and Xcode, meaning that it can generate its own project files, which can then be used to build Premake6. This is a big milestone, since we can now move past isolated unit tests and actually verify our changes with working builds on all three toolsets. All of Premake's core functionality is now fully online, and we're shifting our focus to prioritizing and porting individual features. Still lots of hardcoded settings and to-dos, but full speed ahead!

_(Speaking of which: I know the pace is slow&mdash;definitely slower than I would like&mdash;but thanks to [our backers](#our-sponsors) it’s steady progress. For a bunch of nights-and-weekends part-timers we’re doing alright.)_

I'm currently taking a bug fix & cleanup pass over what we have so far, and filling in gaps in the documentation to make sure we're not leaving too much debt behind. High priority next steps include rethinking how we abstract toolsets like GCC & Clang, so we can push ahead implementing new features on top of those abstractions. And then implementing links and (...drum roll...) _[usages](https://github.com/premake/premake-core/issues/1346)_ (yes, really!) so we can start linking projects and their dependencies together.

Hat tip to [@nickclark2016](https://github.com/nickclark2016) for tackling the new makefile exporter!

### Community Contributions

Yay open source development! 🎉 Big shout out to everyone who took the time to contribute this cycle.

- [#1629](https://github.com/premake/premake-core/pull/1629) Add support for macOS universal binary ([@tempura-sukiyaki](https://github.com/sukiyaki))
- [#1661](https://github.com/premake/premake-core/pull/1661) Add `frameworkdirs` support to gmake & gmake2 with gcc/clang toolsets ([@depinxi](https://github.com/depinxi))
- [#1672](https://github.com/premake/premake-core/pull/1672) C# Symbol Premake → VS Mapping Changes ([@nickclark2016](https://github.com/nickclark2016))
- [#1680](https://github.com/premake/premake-core/pull/1680) Fix some build issues with mingw ([@Biswa96](https://github.com/Biswa96))
- [#1687](https://github.com/premake/premake-core/pull/1687) Update deprecated entry for newaction ([@Jarod42](https://github.com/Jarod42))
- [#1704](https://github.com/premake/premake-core/pull/1704) VS2022 Exporter ([@nickclark2016](https://github.com/nickclark2016))
- [#1710](https://github.com/premake/premake-core/pull/1710) Add support for SSE 4.2 ([@ActuallyaDeviloper](https://github.com/ActuallyaDeviloper))
- [#1712](https://github.com/premake/premake-core/pull/1712) Add OpenMP support for Visual Studio ([@T-rvw](https://github.com/rvw))
- [#1713](https://github.com/premake/premake-core/pull/1713) Upgrade docusaurus version to beta.6 ([@KyrietS](https://github.com/KyrietS))
- [#1715](https://github.com/premake/premake-core/pull/1715) Docs maintenance ([@KyrietS](https://github.com/KyrietS))
- [#1718](https://github.com/premake/premake-core/pull/1718) Deprecate `configuration()` ([@starkos](https://github.com/starkos))
- [#1720](https://github.com/premake/premake-core/pull/1720) Improve `justmycode` ([@T-rvw](https://github.com/rvw))
- [#1721](https://github.com/premake/premake-core/pull/1721) Add custom rules for Gmake2 & Codelite ([@Jarod42](https://github.com/Jarod42))
- [#1723](https://github.com/premake/premake-core/pull/1723) Add configuration condition to VS csproj references ItemGroup ([@cicanci](https://github.com/cicanci))
- [#1726](https://github.com/premake/premake-core/pull/1726) Updated cdialect and cppdialect docs ([@LORgames](https://github.com/LORgames))
- [#1727](https://github.com/premake/premake-core/pull/1727) Updated architecture docs ([@LORgames](https://github.com/LORgames))
- [#1728](https://github.com/premake/premake-core/pull/1728) Add action to check for and generate missing documentation ([@LORgames](https://github.com/LORgames))
- [#1730](https://github.com/premake/premake-core/pull/1730) Added missing `compileas` values to docs ([@LORgames](https://github.com/LORgames))
- [#1734](https://github.com/premake/premake-core/pull/1734) Add VS 2022 bootstrapping support ([@afxw](https://github.com/afxw))
- [#1736](https://github.com/premake/premake-core/pull/1736) Update showcase to include Orx ([@sausagejohnson](https://github.com/sausagejohnson))
- [#1737](https://github.com/premake/premake-core/pull/1737) Change Visual Studio Version to 17 so sln is opened with VS2022 ([@simco50](https://github.com/simco50))
- [#1739](https://github.com/premake/premake-core/pull/1739) Fix #1628 failing macOS os.findlib() test ([@starkos](https://github.com/starkos))
- [#1744](https://github.com/premake/premake-core/pull/1744) Add check for missing values in documentation ([@LORgames](https://github.com/LORgames))
- [#1745](https://github.com/premake/premake-core/pull/1745) Adding documentation for module options ([@hannes-harnisch](https://github.com/harnisch))
- [#1749](https://github.com/premake/premake-core/pull/1749) Changed C++20 to emit C++20 instead of C++Latest in MSVC ([@nickclark2016](https://github.com/nickclark2016))
- [#1752](https://github.com/premake/premake-core/pull/1752) Added C17/GNU17 support to gmake/gmake2 exporters ([@nickclark2016](https://github.com/nickclark2016))
- [#1753](https://github.com/premake/premake-core/pull/1753) Update documentation link in README ([@nickclark2016](https://github.com/nickclark2016))

Extra thanks to the unsung heroes not mentioned here who helped review pull requests, triage issues, and generally keep the machine humming.

### Our Sponsors {#our-sponsors}

<div style={{textAlign: 'center'}}>
	<a href="https://opencollective.com/_fivem">
		<img src="https://images.opencollective.com/_fivem/2f78b5f/logo/128.png"/>
	</a>
</div>

Which brings us at last to our regular _thank you_ & shout out to our premier sponsor **[Cfx.re](https://opencollective.com/_fivem)** as well as all [our monthly backers](https://opencollective.com/premake#section-contributors)—be sure to check out their work and support them back if you can!

I welcome questions, suggestions, and concerns. Message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at [starkos@industriousone.com](mailto:starkos@industriousone.com), or [open a discussion on GitHub](https://github.com/premake/premake-core/discussions).

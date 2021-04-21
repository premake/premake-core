---
title: "Community Update #8"
tags: [community-updates]
author: starkos
author_url: https://github.com/starkos
author_image_url: https://avatars.githubusercontent.com/u/249247?v=4
author_title: Premake Admin & Developer
---

### Welcome Website!

The biggest update this cycle: a new and very much improved Premake website. Built with [Docusaurus](https://docusaurus.io), the new site gives us better navigation and search, a place for news (with RSS!) and it sure looks a hell of a lot better than my "make a website in 20 minutes" version we were running before.

Many thanks to [@KyrietS](https://github.com/KyrietS) for kicking off the process and the help with bootstrapping and content migration! 🙌

On the process side, this upgrade means that the [documentation now lives with the code](https://github.com/premake/premake-core/tree/master/website/docs). Anyone can contribute by submitting a pull request, and the docs can now be updated right alongside the code that implements the changes. I'm optimistic this will help us improve the accuracy and timeliness of the documentation.

_(The GitHub wiki served us well in its time, and is still there for the historical record. But people tended to not keep it up to date with the code. Navigation and search wasn't as nice. And permissions were all-or-nothing; there was no great way to strike a balance between community edits and preventing spam and vandalism.)_

Very happy about this.

### Premake v5.0-alpha16 Released

I…did not realize how long it had been since there was a proper release. Pandemic and all that. I've corrected the matter: [v5.0-alpha16 is now available](https://github.com/premake/premake-core/releases/tag/v5.0.0-alpha16), with lots of good improvements. See the full changelog [here](https://github.com/premake/premake-core/releases/tag/v5.0.0-alpha16).

(By the way, if anyone out there has a knack for build automation I'd love to see these releases automated. Get in touch!)

### RFC: Branch or Backport

I also finally sat down and [opened an RFC](https://github.com/premake/premake-core/discussions/1616) to figure out what to do with the work going on over at [premake-next](https://github.com/starkos/premake-next): branch and push ahead to a v6, or backport the improvements into v5? I've gone back and forth on it but came down on the side of branching; now I'd love to hear what the community thinks. Join the discussion [here](https://github.com/premake/premake-core/discussions/1616).

### What's Next for Next

While we're discussing, I'm hoping to get back to [premake-next](https://github.com/starkos/premake-next), finish up the first few build switches (defines, include directories, that kind of thing), and show them working for both project and file-level configurations, exported for Visual Studio.

### Thanks 🙏

As I do but never do enough, many thanks to [@samsinsane](https://github.com/samsinsane), [@KyrietS](https://github.com/KyrietS), and [everyone who contributed code](https://github.com/premake/premake-core/pulls?q=is%3Apr+is%3Aclosed+sort%3Aupdated-desc) and helped review PRs and issues this cycle.

Many thanks to **[CitizenFX Collective](https://opencollective.com/_fivem#section-contributions)** and **[all our monthly backers](https://opencollective.com/premake#section-contributors)** who allow me to work on Premake instead of shilling for client work. Couldn't be doing this without your generosity.

And as ever: I welcome questions, suggestions, and concerns. Message or DM me at [@premakeapp](https://twitter.com/premakeapp), email at starkos@industriousone.com, or [open a discussion on GitHub](https://github.com/premake/premake-core/discussions).

~st.

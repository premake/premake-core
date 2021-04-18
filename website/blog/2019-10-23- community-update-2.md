---
title: "Community Update #2"
tags: [community-updates]
author: starkos
author_url: https://github.com/starkos
author_image_url: https://avatars.githubusercontent.com/u/249247?v=4
author_title: Premake Admin & Developer
---

For this cycle (I work in eight-week cycles and fill in as much Premake work as I can), I completed a long overdue pruning of [the pull request backlog](https://github.com/starkos/premake-next/pulls). Working up from the oldest, I was able to get it down to just four, all in striking distance of merging and just needing a little follow-up (assistance welcome!). I'll drop a list of all the PRs that were moved at the bottom of this update. Because…

…more importantly, while I have this opportunity to log solid blocks of time to Premake ([thank you!](https://opencollective.com/premake#section-contributors)), I'm taking on its biggest weakness: the project configuration system, the heart of the program that stores your scripted project settings and serves them back to the exporters and actions. The shortcomings in this system are the reason why it's so difficult to support per-file configurations, why we struggle to express makefiles succinctly, and why we can't do a better job of scaling up to large numbers of platforms/architectures/toolsets/etc. Fixing this fixes many things.

To get this done in the most expedient way, and with the least disruption, I’ve [spun up a new working space at premake-next](https://github.com/starkos/premake-next). For those interested, you can read more about what I'm doing, why, and where it's all headed [over there](https://github.com/starkos/premake-next). And I’ll also continue posting regular updates [here on the Collective](https://opencollective.com/premake).

Which brings me to the part where I give a huge THANK YOU! to our continuing sponsors **[CitizenFX Collective](https://opencollective.com/_fivem)** and [Industrious One](https://opencollective.com/industriousone). I would not be able to tackle any of this were it not for your continued support. 🙌

For the next cycle, I plan to start filling in the details of an improved configuration storage approach and, if possible, merge another [pull request or two](https://github.com/premake/premake-core/pulls).

~st.

**Completed Tasks:**

- Boostrapped [Premake-next](https://github.com/starkos/premake-next)
- Closed [PR #1259](https://github.com/premake/premake-core/pull/1259) with [PR #1355](https://github.com/premake/premake-core/pull/1355)
- Closed [PR #1271](https://github.com/premake/premake-core/pull/1271) with [PR #1356](https://github.com/premake/premake-core/pull/1356)
- Closed [PR #1063](https://github.com/premake/premake-core/pull/1063) with [PR #1357](https://github.com/premake/premake-core/pull/1357)
- Merged new PRs [#1345](https://github.com/premake/premake-core/pull/1345), [1351](https://github.com/premake/premake-core/pull/1351), [1352](https://github.com/premake/premake-core/pull/1352), [1353](https://github.com/premake/premake-core/pull/1353), [1358](https://github.com/premake/premake-core/pull/1358)
- Closed [issue #38](https://github.com/premake/premake-core/issues/38) and [PR #624](https://github.com/premake/premake-core/pull/624) with [feature request #1344](https://github.com/premake/premake-core/issues/1344)
- Closed [issue #237](https://github.com/premake/premake-core/issues/237) and [PR #956](https://github.com/premake/premake-core/pull/956) with [feature request #1346](https://github.com/premake/premake-core/issues/1346)
- Closed stale PRs [#968](https://github.com/premake/premake-core/pull/968), [1003](https://github.com/premake/premake-core/pull/1003), [1054](https://github.com/premake/premake-core/pull/1054), [1112](https://github.com/premake/premake-core/pull/1112), [1119](https://github.com/premake/premake-core/pull/1119), [1196](https://github.com/premake/premake-core/pull/1196), [1252](https://github.com/premake/premake-core/pull/1252), [1301](https://github.com/premake/premake-core/pull/1301)
- Added new "Get help" and "Ask a question" issue templates; improved "Report a bug" and "Request a feature" templates

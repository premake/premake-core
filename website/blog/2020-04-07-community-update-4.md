---
title: "Community Update #4"
tags: [community-updates]
authors: starkos
---

It's been much longer than anticipated since the last community update. I was out of the country for a bit, and then shortly after my return the whole Situation hit the fan and things got crazy for a while. I'm back now, up and running and looking ahead to what's next. I hope all of you are also safe and sound and getting your groove back.

#### Inbox Zero

Rather than diving right back into [premake-next](https://github.com/starkos/premake-next), it felt best to take a turn clearing out the lingering pull requests that have been haunting our queue, in some cases for years now. [@saminsane](https://github.com/samsinsane) has been doing a fantastic job triaging your new PRs and getting them merged; I just had to deal with the older ones which, for various reasons, couldn't easily be landed.

Long story short: after several years, we're at [inbox zero](https://twitter.com/premakeapp/status/1250780905016303616). Check out [Premake's recently closed PR list](https://github.com/premake/premake-core/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) for the details on how we got there.

Whew!

#### Alpha-15

With inbox zero reached, we also cut [a new 5.0 alpha release](https://github.com/premake/premake-core/releases/tag/v5.0.0-alpha15) with over 50 changes and fixes, from over 20 different contributors. Nicely done everyone, and thanks! 🙌

{/* truncate */}

#### Premake5 Stable?

Speaking of changes and releases, [#1423](https://github.com/premake/premake-core/issues/1423) from [@dvzrz](https://github.com/dvzrv) asks whether it's (finally) time to cut a stable release of Premake5. Fair question! As I responded on the issue, [@saminsane](https://github.com/samsinsane) and I have discussed this before, and our general feeling is that there are too many big, breaking changes that still need to be made.

> Gmake/Gmake2 situation needs to be sorted, the Xcode exporter needs to be made fit for use, both Gmake & Xcode need to be made module-friendly, and the toolset abstractions need to be reworked to support more real-world setups. The internal APIs really should be cleaned up and naming conventions standardized for module developers.

Help tackling those areas is, of course, very welcome.

That said…

#### Back to Next

With the PRs cleared and a new alpha released, I'm now turning my attention back to [premake-next](https://github.com/starkos/premake-next). I'm going to adjust the plan a bit and focus on getting the new storage and query systems online ASAP. Fixing these two systems is the point of whole exercise, and it seems worth getting more eyes on them sooner than later, even if the configuration blocks have to be manually assembled (i.e. the convenience functions like workspace(), project(), defines(), files(), etc. won't be there yet…it will make sense when you see it).

#### So long and thanks for all the fish

As ever, big and many thanks to everyone who contributed to alpha-15, and to everyone who continues to support [the Premake OpenCollective](https://opencollective.com/premake), with an extra special 🎉 to new sponsors [Emilio Lopez](https://opencollective.com/emilio-lopez) and [Benjamin Schlotter](https://opencollective.com/benjamin-schlotter), and our stalwart benefactor **[CitizenFX Collective](https://opencollective.com/_fivem)**. I wouldn't be able to get any of this done without your help, and I truly appreciate it.

Stay safe!

~st.

(Your feedback is welcome and appreciated—come find us at [github.com/premake](https://github.com/premake) or [@premakeapp](https://twitter.com/premakeapp).)

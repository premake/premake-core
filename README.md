<p align="center">
  <a href="https://premake.github.io/" target="blank"><img src="https://premake.github.io/img/premake-logo.png" height="200" width="200" alt="Premake" /></a>
</p>

# Premake 6

The Premake that comes after Premake 5.

:radioactive: **This is a work in progress of the next major release. This is not the release you are looking for.** :radioactive:

```lua
workspace('MyWorkspace', function ()
    configurations { 'Debug', 'Release' }

    project('MyProject', function ()
        kind 'ConsoleApp'
        files { '**.h', '**.cpp' }

        when({ 'configurations:Debug' }, function ()
            defines { 'DEBUG' }
            symbols 'On'
        end)

        when({ 'configurations:Release' }, function ()
             defines { 'NDEBUG' }
             optimize 'On'
        end)
    end)
end)
```


## What’s going on here?

I’m working on a new major version of Premake (see below).

See **[Changes Since v5](docs/Changes-Since-v5.md)** for a list of the improvements made so far. See [the full documentation](docs/Home.md) to get a sense of what's available.

## Why is a new version needed?

While working to fix some of Premake’s more fundamental issues I’ve come to the conclusion that its project configuration system—the heart of the program which stores and queries the scripted project settings—is fatally flawed. It’s still using the same Visual Studio-centric models that I set out in Premake 1.0, and they’ve hit the limits of what they are able to express.

- It's too inflexible, and can't represent all of the possible formats that it needs to support (Makefile-style projects; anything that supports complex configuration at the workspace level)

- It can't handle toolsets which support multiple platforms in one project, like [Code::Blocks](http://www.codeblocks.org)

- It doesn't scale well to large combinations of platform/architecture/toolset/etc.

- There's no easy way to "roll up" common configuration at the workspace or project level, needed for modern Xcode and Makefile projects

- It does a _terrible_ job handling file level configurations

- The code is excessively complex and difficult to extend and change

- We're hitting the performance limits of the approach, and performance is only so-so at best

I think I know how to fix all of this, but I don’t see how to get there from where we are without breaking…well, pretty much everything. I don’t really want to break everything, and I don’t think you want me to break everything either.

I’m using this space to develop a vertical slice of a new approach, providing something real that other people can see and touch, discuss, and reason about. When that’s done, either a path will be found to fold this back in Premake5, or (more likely IMHO) we’ll create a `v6.x` branch in [premake-core][pc] and full steam ahead on Premake6.

## Does this mean I'm going to have to rewrite all of my scripts?

The version will _not_ be backwards compatible; changes will be needed to existing projects to bring them to v6. At some point, maybe, I'm hoping to provide a transition path. But first I have to prove it works. Stay tuned.

## I need this _now_, how can I make it go faster?

I hear ya. Boy, do I ever.

Contributions here are welcome and appreciated, especially bug fixes and constructive feedback. But please sync up with me to make sure we’re on the same page before setting off to tackle anything big.

Otherwise, the best way to speed things up is to [contribute to our OpenCollective][oc]. Every hour I don’t have to spend hunting down client work is an hour I can spend improving Premake here.

## Can we talk about this?

The easiest way to start a discussion is to [open an issue here](https://github.com/starkos/premake-next/issues). Keep in mind this is a temporary repository so don’t leave anything important lying around; use [premake-core][pc] for that. I can also be reached at [@premakeapp][tw].

## What about toolsets/usages/other issues?

There are definitely other big questions to tackle, but I think this is the most fundamental and, done right, makes solving those other issues easier.

[oc]: https://opencollective.com/premake
[pc]: https://github.com/premake/premake-core
[tw]: https://twitter.com/premakeapp

## Sponsors

Premake is a BSD-licensed open source project. Our many thanks to these fine people who help us spend more time adding features and supporting the community. :tada:

Want to join them? [Learn more here](https://opencollective.com/premake). Use Premake at work? Ask your manager or marketing team about contributing too; your company logo will appear on our [website](https://premake.github.io/) and README, as well as all of our [release pages](https://github.com/premake/premake-core/releases).

### Organizations

<a href="https://opencollective.com/premake#sponsors" target="_blank"><img src="https://opencollective.com/premake/sponsors.svg?width=890&avatarHeight=92&button=false"/></a>

### Individuals

<a href="https://opencollective.com/premake#backers" target="_blank"><img src="https://opencollective.com/premake/backers.svg?width=890&button=false"/></a>

## Contributing

We love getting [pull requests](https://www.quora.com/GitHub-What-is-a-pull-request) and rely heavily on the contributions of our community to keep Premake healthy and growing. If you're new to the project, [our Contributing Guide is here](https://github.com/premake/premake-core/blob/master/CONTRIBUTING.md).

A great big thank you to all of you who have already contributed your time and know-how!

<a href="https://github.com/premake/premake-core/graphs/contributors"><img src="https://opencollective.com/premake/contributors.svg?width=890&avatarHeight=32&button=false" /></a>

## Stay in touch

* Website - https://premake.github.io
* Twitter - [@premakeapp](https://twitter.com/premakeapp)

## License

[BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)

The Lua language and runtime library is &copy; TeCGraf, PUC-Rio.
See their website at http://www.lua.org/

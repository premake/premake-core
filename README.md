<p align="center">
  <a href="https://premake.github.io/" target="blank"><img src="https://premake.github.io/img/premake-logo.png" height="200" width="200" alt="Premake" /></a>
</p>

# Premake 6

The Premake that comes after Premake 5.

:radioactive: **This is a work in progress of a major release. This is (probably) not the release you are looking for.** :radioactive:

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

## FAQs

### What’s going on here?

We're building the next major release of Premake around an entirely new state storage and query system, and hitting some long overdue cleanup along the way.

See **[Changes Since v5](CHANGES_SINCE_V5.md)** for a list of the improvements and major breaking changes made so far. See `website/` for the latest documentation.

### Does this mean I'm going to have to rewrite all of my scripts?

Yes, we are most definitely breaking stuff for the greater good. There are plans to provide a compatibility module to assist with the transition.

### I need this _now_, how can I make it go faster?

I hear ya. Boy, do I ever. Contributions here are welcome and appreciated, especially bug fixes and constructive feedback. But please sync up with me to make sure we’re on the same page before setting off to tackle anything big. Otherwise, the best way to speed things up is to [contribute to our OpenCollective][oc]. Every hour I don’t have to spend hunting down client work is an hour I can spend improving Premake here.

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


[oc]: https://opencollective.com/premake
[pc]: https://github.com/premake/premake-core
[tw]: https://twitter.com/premakeapp

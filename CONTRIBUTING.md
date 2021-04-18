# Contributing to Premake

Thanks for your interest in contributing to Premake! :tada: We love getting [pull requests](https://www.quora.com/GitHub-What-is-a-pull-request) and rely heavily on the contributions of our community to keep Premake healthy and growing.

We want to keep it as easy as possible to contribute changes. These guidelines are intended to help smooth that process, and allow us to review and approve your changes quickly and easily. Improvements are always welcome! Feel free to [open an issue][issue-tracker] or [submit a new pull request][submit-pr]. And finally, these are just guidelines, not rules, so use your best judgement when necessary.

We do everything in [Git][git] hosted on [GitHub][github]. If you're new to this environment, you may want to begin with [Getting Started with GitHub](gh-start) and [Thinkful's GitHub Pull Request Tutorial](thinkful).

## Reporting Bugs

Bugs should be reported on our [GitHub Issue Tracker][issue-tracker].

Please consider if this is something [you can contribute](#contributing-a-fix-or-feature) yourself. Premake is a community project run by volunteers; the best way to get something fixed is to become a contributor!

Before opening an issue, use the search feature at the top of that page to see if it has already been reported.

If you've discovered a new bug, please follow the advice in [How do I ask a good question?][how-to-ask]. While the article is intended for people asking questions on [StackOverflow](https://stackoverflow.com/), it all applies to writing a good bug report too.

## Requesting New Features

Feature requests should be sent to our [GitHub Issue Tracker][issue-tracker].

Please consider if this is something [you can contribute](#contributing-a-fix-or-feature) yourself. Premake is a community project run by volunteers; the best way to get a feature built is to become a contributor!

Before opening a new request, use the search feature at the top of that page to see if it has already been requested.

- Explain the problem that you're having, and anything you've tried to solve it using the currently available features

- Explain how this new feature will help

- If possible, provide an example, like a code snippet, showing what your new feature might look like in use

Also, much of the advice in [How do I ask a good question?][how-to-ask] applies here too.

## Contributing a Fix or Feature

You've created a new fix or feature for Premake. Awesome!

1. If you haven't already, create a fork of the Premake repository

2. Create a topic branch, and make all of your changes on that branch

3. Submit a pull request; see [Writing a Good Pull Request](#writing-a-good-pull-request)

4. Give us a moment. Premake is maintained volunteers on their free time, so we might not be able to respond right away. We're working on improving our turnaround time with resources like this guide and [our OpenCollective][collective].

If you're not sure what any of that means, check out [Getting Started with GitHub](gh-start) and [Thinkful's GitHub Pull Request Tutorial](thinkful) for a complete walkthrough of the process. Gain a life skill!

Some tips...

- Don't hesitate to ask questions on the [issue tracker](issue-tracker) if you get stuck. We're always happy to help people who are trying to contribute. Help us help you help us!

- See [BUILD.txt](https://github.com/premake/premake-core/blob/master/BUILD.txt) for help getting your first build of Premake working. Be sure to run the unit tests!

- Understand exactly what needs to change in Premake's output to get the effect you want. Start by manually creating a working project script to use as a reference, either by adjusting Visual Studio project settings and inspecting the results, or by hand-editing Premake generated project files. Know exactly what you need Premake to do differently before diving in.

- Search the Premake code to find the element you want to change, or those nearby. This should turn up the right location to cut in your change, and also highlight the unit tests that cover that part of the code.

- Copy and paste one of the existing unit tests, and then modify it to match the output you're trying to achieve. If you run the tests again you should see your new test (and only your new test) fail.

- If you need to add new configuration switch(es) to support your feature, you can do that using `api.register()` in [_premake_init.lua](https://github.com/premake/premake-core/blob/master/src/_premake_init.lua).

- [Overrides and Call Arrays](https://github.com/premake/premake-core/wiki/Overrides-and-Call-Arrays) explains how and why we're organizing the code the way we are. Bonus points for converting older code (i.e. GMake and Xcode exporters) to this new and improved format.

- Once everything is working the way you like it, you're ready to submit a pull request for us to merge!


### Writing a Good Pull Request

- Stay focused on a single fix or feature. If you submit multiple changes in a single request, we may like some but spot issues with others. When that happens, we have to reject the whole thing. If you submit each change in its own request it is easier for us to review and approve.

- Limit your changes to only what is required to implement the fix or feature. In particular, avoid style or formatting tools that may modify the formatting of other areas of the code. If your code editor supports [EditorConfig](https://editorconfig.org), turn it on to use [the .editorconfig settings](https://github.com/premake/premake-core/blob/master/.editorconfig) supplied with the Premake sources.

- Write tests! You don't need to go crazy, but we will expect a unit test or two to show that your fix or feature does what it says, and doesn't break in the future. There are many test examples in Premake's source code, covering both the [modules](https://github.com/premake/premake-core/tree/master/modules) and the [core](https://github.com/premake/premake-core/tree/master/tests). Feel free to copy!

- Align [documentation](https://github.com/premake/premake-core/tree/master/website) to your changes. Keeping docs up to date is very important for all users of Premake.

- When you submit a change, try to limit the number of commits involved. A single commit is ideal.

- Follow our coding conventions, which we've intentionally kept quite minimal.

### Coding Conventions

- For symbols that will be visible to project script authors, follow the Lua all-lowercase standard for names: `dosomethingcool`. It's a terrible convention, but it helps us be consistent with Lua's core libraries. Everywhere else, use the much more readable camel case: `doSomethingCool`. (We know this is confusing, and may revisit it in a future major release.)

- Use tabs for indentation, not spaces

- Use Unix (LF) end-of-line sequence

- When in doubt, match the code that's already there


[collective]: https://opencollective.com/premake
[gh-start]: https://help.github.com/en/categories/getting-started-with-github
[git]: https://git-scm.com
[github]: https://github.com
[how-to-ask]: https://stackoverflow.com/help/how-to-ask
[issue-tracker]: https://github.com/premake/premake-core/issues
[submit-pr]: https://github.com/premake/premake-core/pulls
[thinkful]: https://www.thinkful.com/learn/github-pull-request-tutorial/

# PREMAKE RELEASE CHECKLIST

## PREP

* Create a new release branch `release/v5.0-beta1`

* Update `CHANGES.txt`
	* Set version at top of file
	* `premake5 --file=scripts/changes.lua --since=<last_release_rev> changes`
	* Review and clean up as needed

* Update `README.md`
	* "Commits since last release" badge (once out of prerelease replace `v5.0.0-alphaXX` with `latest`)

* Update version in `src/host/premake.h`

* Update version in `website/src/pages/download.js`

* Commit changes and push release branch; wait for CI to pass

* Prep release announcement from change log

## RELEASE

* Run `premake5 package <release branch name> source` (from Posix ideally)

* On each platform, run `premake5 package <release branch name> binary`

* Submit Windows binary to [Microsoft malware analysis](https://www.microsoft.com/en-us/wdsi/filesubmission/) _(Can no longer do this unless it has already been flagged as malware; needs the failing signature in order to submit.)_

* Push any remaining changes; tag release branch

* Create new release on GitHub from `CHANGES.txt`; upload files

* Post announcement to `@premakeapp`

## CYCLE

* Update version in `src/host/premake.h` (e.x `"5.0.0-dev"`)

* Commit

* Merge release branch to master

* Delete release branch

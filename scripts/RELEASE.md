# PREMAKE RELEASE CHECKLIST

## PREP

 * Create a new release branch; push to origin

 * Notify `@premakeapp` of release branch availability; request testing

 * Update `CHANGES.txt`

   * `premake5 --file=scripts/changes.lua --since=<last_release_rev> changes`

   * Review and clean up as needed

 * Update `README.md`

   * "Commits since last release" badge (once out of prerelease replace `v5.0.0-alphaXX` with `latest`)

 * Update version in `src/host/premake.h`

 * Commit `CHANGES.txt`, `README.txt`, `src/host/premake.h`

 * Push release branch to GitHub; wait for CI to pass

 * Prep release announcement from change log

## RELEASE

 * Run `premake5 package <release branch name> source` (from Posix ideally)

 * On each platform, run `premake5 package <release branch name> binary`

 * Merge working branch to release and tag; push with tags

 * Create new release on GitHub from `CHANGES.txt`; upload files

 * Update the download page on github.io

 * Post annoucement to `@premakeapp`


## CYCLE

 * Update version in `src/host/premake.h` (e.x `"5.0.0-dev"`)

 * Commit

 * Merge release branch to master

 * Delete release branch

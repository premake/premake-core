# Premake Website

Premake website is built using [Docusaurus 2](https://v2.docusaurus.io/), a modern static website generator.

## Installation

```
npm install
```

## Local Development

```
npm start
```

This command starts a local development server and open up a browser window. Most changes are reflected live without having to restart the server.

To see a list of broken links (mistakes happen!), be sure to run `npm run build` before submitting updates.

## Build

```
npm run-script build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

## GitHub Actions

* Every **push** and **pull request** that affects anything in `website/**` will trigger website build (to make sure that no errors like broken links were introduced)
* Every **push to the master branch** in this repo that affects anything in `website/**` will trigger website deployment. It means that the website will be built and pushed to the master branch of [premake.github.io](https://github.com/premake/premake.github.io).

## Deployment

Target repo for deployment is specified in `docusaurus.config.js`.

* `organizationName` is a GitHub account name: github.com/**premake**/premake.github.io
* `projectName` is a target repository: github.com/premake/**premake.github.io**

`docusaurus deploy` command is used to automatically build and push static files into [premake.github.io](https://github.com/premake/premake.github.io) repo.
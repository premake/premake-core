# Premake Website

Premake website is built using [Docusaurus 2](https://v2.docusaurus.io/), a modern static website generator. Search functionality is provided for free by [Algolia DocSearch](https://docsearch.algolia.com/).

All docs pages can be found in the `docs/` folder.

## Adding a new entry to the docs
Editing our documentation website is very simple. You don't have to build a whole website for this. All pages are stored in Markdown files, so in order to add a new entry:

1. Add a new Markdown file into the `docs/` folder. Follow naming conventions there.
2. Add your Markdown file's name into the `sidebars.js`. Make sure you've kept alphabetical order among category items.

### Adding a reference to another documentation page

Always reference another documentation page like this:
```markdown
[some text](Case-Sensitive-Filename.md)
```

and **never** like this:
```markdown
[some text](some-markdown-file)
[some text](/docs/some-markdown-file)
[some text](https://premake.github.io/docs/some-markdown-file)
```

*Use existing files in documentation as examples.*

## Installation

```
npm install
```

## Local Development

```
npm start
```

This command starts a local development server and open up a browser window. Most changes are reflected live without having to restart the server.

To see a list of broken links (mistakes happen!), be sure to run `npm run build` before submitting updates. Your changes will be rejected if they contain broken links.

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

Deployments are authenticated by a key pair. The private key is hosted in `premake-core` in **Settings > Secrets**. The public key is host in `premake.github.io` in **Settings > Deploy Keys**.

# Premake Website

Premake's website is built using [Docusaurus 2](https://v2.docusaurus.io/), a documentation-oriented static website generator. Search functionality is provided for free by [Algolia DocSearch](https://docsearch.algolia.com/).

All documentations pages can be found in the `website/docs/` folder. Community updates and other blog posts can be found at `website/blog/`. The home and download pages are at `website/pages`.

## Adding a new entry to the docs

Editing our documentation website is very simple.

1. Add a new Markdown file into the `docs/` folder, following the naming conventions
2. Copy the structure of one of the existing pages, then fill in the sections
2. Add your new entry to `sidebars.js`. If your page is part of a reference category, maintain alphabetical order with the other entries

### Linking to other pages

Always reference another documentation page like this:

```markdown
[some text](Case-Sensitive-Filename-and-Extension.md)
```

If linking to a page outside of `docs/`, use an absolute path.

```markdown
[Modules](/community/modules.md)
```

*Use existing files in documentation as examples.*

## Testing

Docusaurus is a [Node.js](https://nodejs.org/) application, which you can easily run locally to check your work. Assuming you have Node.js installed, run these commands from the `website/` folder.

```bash
# One-time installation of dependencies
npm install

# Start a development server and open in your browser
# Changes to the source files are (usually) hot-loaded
npm start
```

To see a list of broken links (mistakes happen!), be sure to run `npm run build` before submitting updates. Your changes will be rejected if they contain broken links.

## GitHub Actions

- Every **push** and **pull request** that affects anything in `website/**` will trigger a website build and check for broken links

* Every **push to the master branch** which affects anything in `website/**` will trigger a website deployment, building and pushing the new version to the master branch of [premake.github.io](https://github.com/premake/premake.github.io).

## Deployment

The target repository for deployment is specified in `docusaurus.config.js`.

* `organizationName` is a GitHub account name: github.com/**premake**/premake.github.io
* `projectName` is a target repository: github.com/premake/**premake.github.io**

The `docusaurus deploy` command is used to build and push static files into the [premake.github.io](https://github.com/premake/premake.github.io) repository.

Deployments are authenticated by a key pair. The private key is hosted in `premake-core` at **Settings > Secrets**. The public key is hosted in `premake.github.io` in **Settings > Deploy Keys**.

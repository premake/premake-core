module.exports = {
	title: 'Premake',
	tagline: 'Powerfully simple build configuration',
	url: 'https://premake.github.io/',
	baseUrl: '/',
	scripts: [
		'https://use.fontawesome.com/dd1c9cd9ff.js'
	],
	onBrokenLinks: 'throw',
	onBrokenMarkdownLinks: 'throw',
	favicon: 'img/favicon.ico',
	organizationName: 'premake',
	projectName: 'premake.github.io',
	themeConfig: {
		prism: {
			additionalLanguages: ['lua'],
		},
		algolia: {
			apiKey: '7440a29a5d611582272899683f54f54e',
			indexName: 'premake',
		},
		navbar: {
			title: 'Premake',
			logo: {
				alt: 'Premake Logo',
				src: 'img/premake-logo.png',
			},
			items: [
				{
					to: '/docs/',
					activeBasePath: 'docs',
					label: 'Docs',
					position: 'left',
				},
				{
					to: '/blog',
					label: 'News',

				},
				{
					to: '/community/support',
					label: 'Community',
					position: 'left',
					activeBaseRegex: `/community/`
				},
				{
					href: 'https://twitter.com/premakeapp',
					position: 'right',
					className: 'fa fa-twitter fa-2x',
					'aria-label': 'Premake on Twitter',
				},
				{
					href: 'https://github.com/premake/premake-core',
					position: 'right',
					className: 'fa fa-github fa-2x',
					'aria-label': 'GitHub repository'
				},
			],
		},
		footer: {
			style: 'dark',
			links: [
				{
					title: 'Learn',
					items: [
						{
							label: 'Introduction',
							to: '/docs/What-Is-Premake'
						},
						{
							label: 'Download',
							to: '/download'
						},
						{
							label: 'Your First Script',
							to: '/docs/Your-First-Script'
						},
						{
							label: 'Premake 4.x',
							to: 'https://github.com/premake/premake-4.x/wiki',
						}
					],
				},
				{
					title: 'Community',
					items: [
						{
							label: 'Discussions',
							href: 'https://github.com/premake/premake-core/discussions',
						},
						{
							label: 'Stack Overflow',
							href: 'https://stackoverflow.com/questions/tagged/premake',
						},
						{
							label: 'Help',
							to: '/community/support'
						}
					],
				},
				{
					title: 'More',
					items: [
						{
							label: 'Blog',
							to: '/blog'
						},
						{
							label: 'GitHub',
							href: 'https://github.com/premake/premake-core/',
						},
						{
							label: 'Twitter',
							href: 'https://twitter.com/premakeapp',
						},
						{
							label: 'OpenCollective',
							href: 'https://opencollective.com/premake',
						}
					],
				},
			],
			copyright: `Copyright © ${new Date().getFullYear()} Premake`,
		},
	},
	presets: [
		[
			'@docusaurus/preset-classic',
			{
				docs: {
					sidebarPath: require.resolve('./sidebars.js'),
					editUrl: 'https://github.com/premake/premake-core/edit/master/website/',
					showLastUpdateAuthor: true,
					showLastUpdateTime: true,
				},
				blog: {
					blogSidebarTitle: 'Posts',
				},
				theme: {
					customCss: require.resolve('./src/css/custom.css'),
				},
			}
		],
	],
	plugins: [
		[
			'@docusaurus/plugin-content-docs',
			{
				id: 'community',
				path: 'community',
				editUrl: 'https://github.com/premake/premake-core/edit/master/website/',
				routeBasePath: 'community',
				sidebarPath: require.resolve('./sidebars-community.js'),
				showLastUpdateAuthor: true,
				showLastUpdateTime: true,
			}
		]
	]
};

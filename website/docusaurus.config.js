module.exports = {
	title: 'Premake',
	tagline: 'Powerfully simple build configuration',
	url: 'https://premake.github.io/',
	baseUrl: '/',
	onBrokenLinks: 'throw',
	onBrokenMarkdownLinks: 'throw',
	favicon: 'img/premake-logo.png', // FIXME: make actual favicon.ico file
	organizationName: 'premake',
	projectName: 'premake.github.io',
	themeConfig: {
		prism: {
			additionalLanguages: ['lua'],
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
					to: '/download',
					label: 'Download',
					position: 'left'
				},
				{
					to: '/community/support',
					label: 'Community',
					position: 'left',
					activeBaseRegex: `/community/`
				},
				{
					href: 'https://github.com/premake/premake-core',
					label: 'GitHub',
					position: 'left',
				},
			],
		},
		footer: {
			style: 'dark',
			links: [
				{
					title: 'Documentation',
					items: [
						{
							label: 'Premake 5.0',
							to: 'docs/',
						},
						{
							label: 'Premake 4.x',
							to: 'https://github.com/premake/premake-4.x/wiki',
						},
					],
				},
				{
					title: 'Community',
					items: [
						{
							label: 'StackOverflow',
							href: 'https://stackoverflow.com/questions/tagged/premake',
						},
						{
							label: 'Twitter',
							href: 'https://twitter.com/premakeapp',
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
							label: 'GitHub',
							href: 'https://github.com/premake/premake-core/',
						},
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
				theme: {
					customCss: require.resolve('./src/css/custom.css'),
				},
			},
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

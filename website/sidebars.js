module.exports = {
	docs: [
		'welcome',
		{
			collapsed: false,
			type: 'category',
			label: 'Introduction',
			items: [
				'getting-started/what-is-premake',
				'getting-started/using-premake',
				'getting-started/building-premake'
			]
		},
		{
			collapsed: true,
			type: 'category',
			label: 'Actions',
			items: [
				'actions/about-actions',
				'actions/vstudio'
			]
		},
		{
			collapsed: true,
			type: 'category',
			label: 'Authoring Scripts',
			items: [
				'authoring/your-first-script',
				'authoring/workspaces-and-projects',
				'authoring/conditional-settings',
				'authoring/locating-scripts',
			]
		},
		{
			collapsed: true,
			type: 'category',
			label: 'Extending Premake',
			items: [
				'extending/introduction',
				'extending/coding-conventions',
				'extending/state-and-queries'
			]
		},
		{
			collapsed: true,
			type: 'category',
			label: 'Reference',
			items: [
				{
					collapsed: true,
					type: 'category',
					label: 'options',
					items: [
						'options/overview',
						'options/all',
						'options/definitionOf',
						'options/each',
						'options/execute',
						'options/register',
						'options/valueOf',
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'os',
					items: [
						'os/overview',
						'os/chdir',
						'os/getCwd',
						'os/isFile'
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'path',
					items: [
						'path/overview',
						'path/getAbsolute',
						'path/getBaseName',
						'path/getDirectory',
						'path/getKind',
						'path/getName',
						'path/isAbsolute',
						'path/translate'
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'premake',
					items: [
						'premake/abort',
						'premake/callArray',
						'premake/checkRequired',
						'premake/locateModule',
						'premake/locateScript'
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'string',
					items: [
						'string/overview',
						'string/findLast',
						'string/split',
						'string/startsWith'
					]
				},
				'_ARGS',
				'_PREMAKE',
				'_SCRIPT',
				'_SCRIPT_DIR',
				'_USER_HOME_DIR',
				'commandLineOption',
				'doFile',
				'doFileOpt',
				'filename',
				'loadFile',
				'location',
				'printf',
				'project',
				'projects',
				'when',
				'workspace',
				'workspaces'
			]
		}
	],
};

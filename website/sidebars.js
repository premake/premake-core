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
				'actions/vstudio',
				'actions/xcode'
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
					label: 'export',
					items: [
						'export/Exporting',
						'export/export_append',
						'export/export_appendLine',
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'options',
					items: [
						'options/Options',
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
						'os/OS',
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
						'path/Paths',
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
						'premake/Premake',
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
						'string/Strings',
						'string/findLast',
						'string/split',
						'string/startsWith'
					]
				},
				{
					collapsed: true,
					type: 'category',
					label: 'version',
					items: [
						'version/Versions',
						'version/version_new',
						'version/version_is',
						'version/version_lookup',
						'version/version_map'
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

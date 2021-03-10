module.exports = {
  mainSidebar: [
    {
      collapsed: false,
      type: 'category',
      label: 'Getting Started',
      items: [
        'Home',
        'What-Is-Premake',
        'Building-Premake',
        'Getting-Premake',
        'Using-Premake',
        'Getting-Help',
        'Who-Uses-Premake'
      ]
    },
    {
      collapsed: true,
      type: 'category',
      label: 'Guides',
      items: [
        'Sharing-Configuration-Settings'
      ]
    },
    {
      collapsed: true,
      type: 'category',
      label: 'Reference',
      items: [
        'basedir',
        {
          collapsed: false,
          type: 'category',
          label: 'os',
          items: [
            'os.chdir',
            'os.mkdir',
            'os.rmdir'
          ]
        },
        {
          collapsed: false,
          type: 'category',
          label: 'path',
          items: [
            'path.getabsolute',
            'path.getbasename',
            'path.getdirectory',
            'path.getdrive',
            'path.getextension',
            'path.getname'
          ]
        }
      ],
    }
  ],
};

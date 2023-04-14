from distutils.core import setup

setup(name='zotero_poll',
      version='0.0.0',
      description='Poll Zotero on interactive loop',
      packages=['zotero_poll'],
      entry_points={
        'console_scripts': [
            'zotero_poll=zotero_poll:main',
        ]
    }
 )

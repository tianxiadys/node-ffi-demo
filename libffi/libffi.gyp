{
    'targets': [
        {
            'target_name': 'libffi',
            'type': 'shared_library',
            'product_dir': 'build',
            'include_dirs': [
                'fixed',
                'include'
            ],
            'direct_dependent_settings': {
                'include_dirs': [
                    'fixed',
                    'include'
                ],
            },
            'sources': [
                'fixed/ffiload.c',
                'src/closures.c',
                'src/prep_cif.c',
                'src/types.c',
                'src/tramp.c'
            ],
            'conditions': {
            }
        }
    ]
}

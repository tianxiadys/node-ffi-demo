{
    'targets': [
        {
            'target_name': 'libffi',
            'type': 'shared_library',
            'include_dirs': ['fixed', 'include'],
            'direct_dependent_settings': {
                'include_dirs': ['fixed', 'include'],
            },
            'sources': [
                'fixed/ffi.c',
                'fixed/ffiload.c',
                'src/closures.c',
                'src/debug.c',
                # dlmalloc.c has already been included in closures.c
                'src/java_raw_api.c',
                'src/prep_cif.c',
                'src/raw_api.c',
                'src/tramp.c',
                'src/types.c',
                '<(INTERMEDIATE_DIR)/ffiasm.asm',
            ],
            'actions': [
                {
                    'action_name': 'libffi_msvc_gen_asm',
                    'message': 'Generating Microsoft ASM file from ffiasm.S',
                    'msvs_cygwin_shell': 0,
                    'inputs': ['fixed/ffiasm.S'],
                    'outputs': ['<(INTERMEDIATE_DIR)/ffiasm.asm'],
                    'action': [
                        'cl',
                        '-nologo',
                        '-EP',
                        '-P',
                        '-I',
                        './fixed',
                        '-I',
                        './include',
                        '-Fi<(INTERMEDIATE_DIR)/ffiasm.asm',
                        './fixed/ffiasm.S',
                    ],
                }
            ],
            'conditions': [
            ]
        }
    ]
}

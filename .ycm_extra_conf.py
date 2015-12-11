import os
import re


def FlagsForFile(filename, **kwargs):

    project_dir = os.path.dirname(os.path.realpath(__file__))
    project_include_dir = os.path.join(project_dir, 'dist', 'include')

    flags = [
        '-Wall',
        '-Wextra',
        '-Werror'
        '-pedantic',
        # '-isystem',
        # '/usr/include',
    ]

    ## test sources must search headers in dist/include directory
    if re.match('.*_test.cpp', os.path.basename(filename)):
        flags += [
            '-I',
            project_include_dir,
        ]

    flags += ['-xc++']
    flags += ['-std=c++11']

    return {
        'flags':    flags,
        'do_cache': True
    }

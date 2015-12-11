import os
import sys

dirname = os.path.dirname(os.path.realpath(sys.argv[0]))
print(os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), 'dist', 'include'))


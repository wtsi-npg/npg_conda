import subprocess
from os.path import join, dirname, exists

path = join(dirname(__file__))

if not exists(join(path, 'data', 'channel')):
    subprocess.run([join(path, 'data', 'make_channel.sh'), join(path, 'data')])

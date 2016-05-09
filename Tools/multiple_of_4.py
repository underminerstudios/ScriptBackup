#!/usr/bin/python
import subprocess
import sys

# this script makes sure that a passed texture is a multiple of 4 pixels in size (in place)
# it does so by cropping, but a smarter move would be to add a transparent border!

res = subprocess.check_output("/usr/local/bin/identify %s" % sys.argv[1], shell=True)
size = res.split()[2]
width, height = map(int, size.split("x"))
new_width = int(width / 4.0) * 4
new_height = int(height / 4.0) * 4

command = "/usr/local/bin/mogrify -gravity NorthWest -crop %dx%d+0+0 %s" % (new_width, new_height,  sys.argv[1])

print command 
subprocess.call(command, shell=True)
subprocess.call("identify %s" % sys.argv[1], shell=True)

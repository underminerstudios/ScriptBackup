import subprocess
import os
import sys
import re

def get_audio_length(filename):
  try:
    subprocess.check_output("ffmpeg -i %s" % filename,
      stderr=subprocess.STDOUT,
      shell=True
    )
  except subprocess.CalledProcessError, e:
    res = e.output
  m = re.search(r"Duration: (\d\d):(\d\d):(\d\d).(\d\d)", res)
  try:
    seconds = 60*60*int(m.group(1)) + 60*int(m.group(2)) + int(m.group(3)) + 0.01*int(m.group(4))
  except AttributeError:
    seconds = 0

  return seconds

if __name__=='__main__':
  print get_audio_length(sys.argv[1])


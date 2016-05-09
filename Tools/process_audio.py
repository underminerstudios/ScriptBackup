#!/usr/bin/python

import os
import glob
import re
import subprocess
import argparse

os.chdir(os.path.dirname(__file__))

parser = argparse.ArgumentParser(description='process sounds')
parser.add_argument('-u', action="store_true", dest="utterances")
parser.add_argument('-m', action="store_true", dest="music")

args = parser.parse_args()

if args.utterances:
  print "processing utterances"
  # process utterances
  for dirname in glob.glob("../Raw/Utterances/uncut/*"):
    if os.path.isdir(dirname) and re.match(r"\d\d_\d\d", os.path.basename(dirname)):
      for src in glob.glob(dirname+"/*.wav"):
        if re.search(r"\d\d\d_\d\d\d_\d\d\d.wav$", src):
          shot_id, ext = os.path.splitext(os.path.basename(src))
          dest = "../Assets/Sounds/Utterances/" + shot_id + "_ALL.ogg"
          print src, dest
          subprocess.call("ffmpeg -i %s -acodec libvorbis %s" % (src, dest), shell=True)

if args.music:
  print "processing music"
  # process music
  for ifn in glob.glob("../Raw/Music/*.m4a"):
    stem, ext = os.path.splitext(os.path.basename(ifn))
    ofn = "../Assets/Sounds/Music/" + stem + ".ogg"
    subprocess.call("ffmpeg -i %s -acodec libvorbis %s" % (ifn, ofn), shell=True)

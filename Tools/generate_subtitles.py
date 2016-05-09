#!/usr/bin/python
import os
import csv
import requests
import StringIO
import lxml
from lxml import etree as ET
from lxml.builder import E
import pprint
import re
import collections

os.chdir(os.path.dirname(os.path.realpath(__file__)))

# setup logging and log to string
import logging
stream = StringIO.StringIO()
handler = logging.StreamHandler(stream)
logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger('generate')
log.setLevel(logging.DEBUG)
log.addHandler(handler)

import argparse

#parser = argparse.ArgumentParser(description='subtitles')
#parser.add_argument('-l', action="store", dest="lang", help="language code", default="EN_US")
#
#args = parser.parse_args()
#cur_lang = parser.lang
cur_lang = "_EN_US"

#############
# CONSTANTS #
#############

# google docs URL
url = "https://docs.google.com/spreadsheets/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=735481263"

languages = ["_EN_US"]

xml_target_dir = "Assets/Resources/"

def main():
  r = requests.get(url)
  text = filter(lambda c: ord(c) < 128, r.text)

  csv_reader = csv.reader(StringIO.StringIO(text))
  rows = list(csv_reader)

  # extract the headings to turn into dictionary keys
  headings = rows.pop(0)
  headings = ["_"+heading for heading in headings]
  rows = [dict(zip(headings, row)) for row in rows]

  # fix up all the rows
  cur_shot_id = None
  for row in rows:
    if row["_Shot"] != "":
      cur_shot_id = row["_Shot"]
    row["shot_id"] = cur_shot_id
    for lang in languages:
      row[lang] = row[lang].strip()
      row[lang] = row[lang].replace("\n", " ")



  shots = collections.OrderedDict()
  for row in rows:
    shot_id = row["shot_id"]
    shot = shots.get(shot_id, [])
    shot.append(row)
    shots[shot_id] = shot

  for shot in shots.values():
    for row in shot:
      if row["_Utterance"] == "":
        row["_Utterance"] = "ALL"
        ## special case: we concatenate all the rest of them
        row[cur_lang] = "//".join([_row[cur_lang] for _row in shot if _row[cur_lang] != ""])
    for row in shot:
      row[cur_lang] = row[cur_lang].split("//")
      row[cur_lang] = map(lambda line: re.sub(r".*:", "", line), row[cur_lang])
      row[cur_lang] = map(lambda line: line.strip(), row[cur_lang])

  subtitles_elem = E.subtitles()
  for shot_id, shot in shots.items():
    for row in shot:
      subtitles_elem.append(E.utterance(
        *[E.line(line) for line in row[cur_lang]],
        utterance_id="%s_%s" % (shot_id, row["_Utterance"])
      ))
  print ET.tostring(subtitles_elem, pretty_print=True)
  with open("../Assets/Resources/subtitles.xml", "w") as f:
    f.write(ET.tostring(subtitles_elem, pretty_print=True))


if __name__=='__main__':
  main()

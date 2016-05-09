#!/usr/bin/python

import os
import csv
import requests
import StringIO
import lxml
from lxml import etree as ET
from lxml.builder import E
import pprint
import collections
import re
import itertools
import datetime
import json
import glob

d = os.path.dirname(os.path.realpath(__file__))
os.chdir(d)

urls = dict(
  FPFly = "https://docs.google.com/spreadsheets/u/1/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=616391112",
  PlaneController = "https://docs.google.com/spreadsheets/u/1/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=2013586648",
  Look = "https://docs.google.com/spreadsheets/u/1/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=1460282409"
)
generated_xml_dir = os.path.join("..", "Assets", "Resources")


for name, url in urls.items():
  r = requests.get(url)

  csv_reader = csv.reader(StringIO.StringIO(r.text))
  rows = list(csv_reader)

  # extract the headings to turn into dictionary keys
  headings = rows.pop(0)
  headings = [heading for heading in headings]
  rows = [dict(zip(headings, row)) for row in rows]
  #rows = dict(zip([row["shot_id"] for row in rows], rows))

  xml = E.shots(
    *[E.shot(**row) for row in rows]
  )

  xml = ET.tostring(xml, pretty_print=True)
  filename = os.path.join(generated_xml_dir, "%s_params.xml" % name)
  print "=== %s ===" % filename
  print xml

  with open(filename, "w") as f:
    f.write(xml)

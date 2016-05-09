#!/usr/bin/python

import os
import lxml
from lxml import etree as ET
import pprint
import subprocess
from PIL import Image

os.chdir(os.path.dirname(os.path.realpath(__file__)))

layouts_xml_path = "../Assets/Resources/layouts.xml"
#sequences_xml_path = "../Raw/Generated/XML/sequences.xml"
sequences_xml_path = "/tmp/Generated/XML/sequences.xml"

with open(layouts_xml_path, "r") as f:
  layouts_root = ET.fromstring(f.read())

comp_types = {}
for rect in layouts_root.xpath("//rect"):
  comp_type = rect.attrib["id"]
  x,y,w,h = [int(rect.attrib[key]) for key in ("left", "top", "width", "height")]
  comp_types[comp_type] = x,y,w,h

with open(sequences_xml_path, "r") as f:
  sequences_root = ET.fromstring(f.read())

for sequence in sequences_root.xpath("//sequence"):
  for i, layout in enumerate(sequence):
    out_im = Image.new("RGB", (192, 108), "black")

    for shot in layout:
      shot_id = shot.attrib["shot_id"]
      comp_type = shot.attrib["comp_type"]
      x,y,w,h = map(lambda v: v/10, comp_types[comp_type])
      im = Image.open("../Assets/ReferenceImages/%s.jpg" % shot_id)
      im = im.resize((w, h))
      out_im.paste(im, (x, y, x+w, y+h))
    out_im.save("../Assets/Resources/Thumbnails/%s.jpg" % layout.attrib["layout_id"])
    



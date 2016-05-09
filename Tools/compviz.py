#!/usr/bin/python

import os
import lxml
from lxml import etree as ET
import pprint
import subprocess
from PIL import Image, ImageDraw

#!/usr/bin/python

import os
import lxml
from lxml import etree as ET
import pprint
import subprocess
from PIL import Image, ImageDraw, ImageFont

os.chdir(os.path.dirname(os.path.realpath(__file__)))

font = ImageFont.truetype("Helvetica.ttf", 15)

layouts_xml_path = os.path.realpath(os.path.join("../","Assets","Resources","layouts.xml"))

scale = 3

with open(layouts_xml_path, "r") as f:
  layouts_root = ET.fromstring(f.read())

comp_types = {}
for rect in layouts_root.xpath("//rect"):
  comp_type = rect.attrib["id"]
  x,y,w,h = [int(rect.attrib[key]) for key in ("left", "top", "width", "height")]
  comp_types[comp_type] = x,y,w,h

filenames = []
for i, combination in enumerate(layouts_root.xpath("//combination")):
  if combination.text == "X": continue
  out_im = Image.new("RGB", (1920/scale, 1080/scale), "black")
  draw = ImageDraw.Draw(out_im)
  for code in combination.text.split():
    x,y,w,h = comp_types[code]
    rect = (x/scale+5, y/scale+5, x/scale+5 + w/scale-10, y/scale+5 + h/scale-10)
    draw.rectangle(rect, outline=(255,255,255))
    draw.text((x/scale+10, y/scale+10), "%s %dx%d+%d+%d" % (code, w,h,x,y), font=font)
  filename = combination.text.replace(" ", "")
  draw.line(((0, 1080/scale-1), (1920/scale, 1080/scale-1)))
  filename = os.path.realpath(os.path.join("..", '..', '..',"2bit_Art","CompTypes","%s.jpg") % filename)
  out_im.save(filename)
  filenames.append(filename)

subprocess.call("montage -label '%%f' %s -frame 5 -geometry +5+5 -font Helvetica -tile x%d ../Raw/CompTypes/master.jpg" % (" ".join(filenames), len(filenames)), shell=True)


    





#!/usr/bin/python
import glob
import os
import lxml
from lxml import etree as ET
from lxml.builder import E
import pprint

"""
This script checks the entire directory of animdata XML files looking for files
that are missing their "parent='none'"
"""

os.chdir(os.path.dirname(os.path.realpath(__file__)))

xml_glob = "../Raw/AnimData/*.xml"
filenames = glob.glob(xml_glob)
bad_set = set(filenames)
for file in filenames:
    try:
      with open(file, "r") as f:
        root = ET.fromstring(f.read())
    except XMLSyntaxError:
      print "couldn't read f"

    if root.xpath("//layer[@parent='none']"):
      bad_set.remove(file)
      print ".",
    else:
      print "!"
    print file


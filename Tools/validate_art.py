#!/usr/bin/python
import os
import csv
import requests
import StringIO
import lxml
from lxml import etree as ET
from lxml.builder import E
import pprint
import itertools
import glob

os.chdir(os.path.dirname(os.path.realpath(__file__)))


ae_src_xml_dir = "../Raw/AnimData/"
ae_src_textures_dir = "../Raw/Textures/"

def main():
  for path in glob.glob(ae_src_xml_dir+"/*.xml"):

    with open(path, "r") as f:
      ae_root = ET.fromstring(f.read())

    dirname, ext = os.path.splitext(os.path.basename(path))
    textures = set(os.listdir(os.path.join(ae_src_textures_dir, dirname)))

    nosource = set()
    layers = set()
    bad_parallax_bucket = set()
    try:
      for node in ae_root.xpath("//layer"):
        layers.add(node.attrib["source"])
    except KeyError:
      nosource.add(node.attrib["name"])

    parallax_bucket = node.attrib.get("parallaxBucket", "")
    if parallax_bucket not in ("FG", "MG", "BG"):
      bad_parallax_bucket.add("'%s' (%s)" % (node.attrib["name"], parallax_bucket))
    
    missing_layers = textures.difference(layers)
    missing_textures = layers.difference(textures)
    if missing_layers or missing_textures or nosource or bad_parallax_bucket:
      print dirname
      for name in nosource:
        print "\tEMPTY SOURCE REF: '%s'" % name
      for layer in missing_layers:
        print "\tMISSING LAYER:  '%s'" % layer
      for texture in missing_textures:
        print "\tMISSING TEXTURE: '%s'" % texture
      for detail in bad_parallax_bucket:
        print "\tBAD PARALLAX BUCKET: %s" % detail

if __name__=='__main__':
  main()

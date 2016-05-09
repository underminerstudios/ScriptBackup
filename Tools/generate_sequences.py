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
import subprocess
import glob

from audio_length import get_audio_length

_open = open
def open(*args):
  log.debug("OPEN %s", (args,))
  return _open(*args)

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

parser = argparse.ArgumentParser(description='the generator')
parser.add_argument('-s', action="append", dest="sequences", help="include sequence")
parser.add_argument('-e', action="append", dest="episodes", default=[], help="include episode")
parser.add_argument('-o', action="store", dest="generated_dir", default="../Raw/Generated/", help="output Generated directory")
parser.add_argument('-u', action="store", dest="upload", default=False, help="upload generated data?")

args = parser.parse_args()
log.info("generate shots and sequences for %s at %s", args.sequences, datetime.datetime.now())

generated_dir = args.generated_dir

# sync the s3 bucket
subprocess.call("aws s3 sync s3://com-twobitcircus-wby/production/wby_pipeline/AnimData/ ../Raw/AnimData", shell=True)
subprocess.call("mkdir -p ../Raw/Generated/AnimData", shell=True)
subprocess.call("mkdir -p ../Raw/Generated/XML", shell=True)

#############
# CONSTANTS #
#############

# google docs URL
url = "https://docs.google.com/spreadsheets/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=0"

ae_src_xml_dir = "../Raw/AnimData/"
ae_src_textures_dir = "../Raw/Textures/"

ae_dest_xml_dir = os.path.join(generated_dir, "AnimData/")
generated_xml_dir = os.path.join(generated_dir, "XML/")

# these headings will be copied over verbatim (all lowercase with underscores)
copy_headings = ['Nickname', 'Comp Type', 'Shot Type', 'Parallax Amount', 'Background', 'Background Color', 'Dirt', 'Dirt Color', 'Hotspot', 'Hotspot Color', 'Data Filename', 'Image Dirname']

# read and process the Comp Types
layouts_xml_path = "../Assets/Resources/layouts.xml"
try:
  with open(layouts_xml_path, "r") as f:
    layouts_root = ET.fromstring(f.read())
except XMLSyntaxError:
  print "couldn't read layouts.xml"

comp_sizes = dict()
for rect in layouts_root.xpath("//rect"):
  comp_sizes[rect.attrib["id"]] = (
    int(rect.attrib["left"]), int(rect.attrib["top"]), int(rect.attrib["width"]), int(rect.attrib["height"])
  )

valid_comp_patterns = [elem.text.split() for elem in layouts_root.xpath("//combination")]

# a flattened list of all possible code orderings
valid_comp_orderings = set(itertools.chain(*[list(itertools.permutations(codes)) for codes in valid_comp_patterns]))
valid_comp_orderings = ["".join(ordering) for ordering in valid_comp_orderings]


class ShotError(Exception):
  def __init__(self, shot_id, reason):
    self.shot_id = shot_id
    Exception.__init__(self, reason)

class SequenceError(Exception): pass

class SeqElem(object): 
  def __init__(self, sequence_id, comp_rows):
    self.sequence_id = sequence_id
    self.comp_rows = comp_rows

class MultiSeqElem(SeqElem):
  def __init__(self, sequence_id, comp_rows):
    SeqElem.__init__(self, sequence_id, comp_rows)


  def toXml(self):
    initial_frame_offset = self.comp_rows[0]["_frame_offset"]
    return E.layout(
      *[E.shot(
          shot_id=row["shot_id"],
          music=row["music"],
          music_offset=str(row["music_offset"]),
          sfx1=row["sfx1"],
          sfx1_offset=str(row["sfx1_offset"]),
          sfx2=row["sfx2"],
          sfx2_offset=str(row["sfx2_offset"]),
          comp_type=row["comp_type"],
          start_time=str(row["start_time"]),
          end_time=str(row["end_time"]),
          #audio_duration=str(row.get("_audio_duration", 0))
        ) for row in self.comp_rows],
      layout_id=self.getLayoutId()
    )

  def getLayoutId(self):
    return ",".join([row["shot_id"] for row in self.comp_rows])

class ActiveSeqElem(SeqElem):
  def toXml(self):
    return E.active(
      prefab_id=self.comp_rows[0]["shot_id"],
      layout_id=self.comp_rows[0]["shot_id"]
    )


def generate_shot_xml(row):
  return E.shot(
    *[E(k,str(v)) for k,v in row.items() if not k.startswith("_")],
    shot_id=row["shot_id"]
  )


def main():

  # generate a regular expression to identify individual codes
  letter_reo = "|".join(["(%s)" % code for code in comp_sizes.keys()])
  letter_reo = re.compile(letter_reo)

  # and generate a regular expression to identify valid multicomp patterns
  #pattern_reo = "|".join(["(%s)" % "".join(pattern) for pattern in valid_comp_orderings])
  #print pattern_reo
  #pattern_reo = re.compile(pattern_reo)

  # read the new CompData files for MultiComp timing
  comp_data = dict()
  for filename in glob.glob(os.path.join(ae_src_xml_dir, "CompData", "*.json")):
    print "loading ", filename
    elems = json.load(open(filename, "r"))
    for elem in elems:
      shot_id = elem["layerName"]
      comp_data[shot_id] = elem
  print "loaded comp data for %d shots" % len(comp_data)

  r = requests.get(url)

  csv_reader = csv.reader(StringIO.StringIO(r.text))
  rows = list(csv_reader)

  # extract the headings to turn into dictionary keys
  headings = rows.pop(0)
  headings = ["_"+heading for heading in headings]
  rows = [dict(zip(headings, row)) for row in rows]

  cur_sequence_id = None
  for i, row in enumerate(rows):
    row["_idx"] = i+2 # save a reference to the spreadsheet row index

    if row["_Sequence"] != "":
      cur_sequence_id = row["_Sequence"]
    row["sequence_id"] = cur_sequence_id

  # eliminate rows from consideration that aren't in the allowed sequences
  rows = filter(
    lambda r:
      (args.sequences is not None and r["sequence_id"] in args.sequences)
      or filter(lambda episode: r["sequence_id"].startswith(episode), args.episodes)
  , rows)

  # include only rows before the first invalid comp code
  groups_of_rows = itertools.groupby(rows, lambda row: row["sequence_id"])

  _rows = []
  for sequence_id, group_of_rows in groups_of_rows:
    for row in group_of_rows:
      if row["_Comp Type"] in comp_sizes.keys():
        _rows.append(row)
      else:
        print "Invalid comp code in row %d.  Aborting %s" % (row["_idx"], row["sequence_id"])
        break

  rows = _rows

  # embed shot dictionaries inside valid shot rows
  for row in rows:
    # skip rows that aren't valid shot_ids
    row["shot_id"] = row["_Shot"]
    if re.match(r"\d{3}_\d{3}_\d{3}", row["shot_id"]):
      try:
        process_shot_row(row)
      except ShotError, e:
        print "SHOT ERROR", row["shot_id"]
        row["_frame_offset"] = 0
        row["placeholder"] = True
        log.error("(shot %s) %s" % (e.shot_id, e))

  print "looking for multicomps in %d rows" % len(rows)
  # here we convert the Comp Type fields into a string (letters read down the column)
  comp_str = ""
  for i, row in enumerate(rows):
    comp_str += row["_comp_code"]

  
  # iterate through the comp string applying the regexp looking for matches
  multis = []
  start = 0
  while True:
    match = None
    for ordering in valid_comp_orderings:
      if comp_str[start:].startswith(ordering):
        match = ordering
        break
    if match is None:
      break
    codes = [m.group() for m in letter_reo.finditer(match)]

    multis.append(dict(
      pattern=match,
      codes=codes
    ))
    start = start + len(match)

  comps = []
  for multi in multis:
    comp_rows = []
    for i, code in enumerate(multi["codes"]):
      row = rows.pop(0)
      comp_rows.append(row)
    sequence_id = comp_rows[0]["sequence_id"]
    if multi["pattern"] == "@":
      comp = ActiveSeqElem(sequence_id, comp_rows)
    else:
      comp = MultiSeqElem(sequence_id, comp_rows)
    comps.append(comp)

  # split up the comps into sequences of comps
  sequences = collections.OrderedDict()
  for comp in comps:
    sequence_id = comp.sequence_id
    sequence = sequences.get(sequence_id, [])
    sequence.append(comp)
    sequences[sequence_id] = sequence

  # for each comp, compute the maximum length by looking ahead at the
  # next comp to see when it starts
  multicomps = filter(lambda comp: isinstance(comp, MultiSeqElem), comps)
  for i, this_comp in enumerate(multicomps):
    has_placeholder = any([row.get("placeholder",False) for row in this_comp.comp_rows])

    # if any of these shots is a placeholder, then everything plays at 0
    if has_placeholder:
      for row in this_comp.comp_rows:
        row["start_time"] = 0
        row["end_time"]   = 5.0
        row["duration"] = 5.0
    else:
      for row in this_comp.comp_rows:
        comp_data_this_row = comp_data[row["shot_id"]]
        comp_data_first_row = comp_data[this_comp.comp_rows[0]["shot_id"]]

        row["start_time"] = float(comp_data_this_row["startTime"]) - float(comp_data_first_row["startTime"])
        row["end_time"] =   float(comp_data_this_row["end"]) -       float(comp_data_first_row["startTime"])
        row["duration"] =   float(comp_data_this_row["duration"])

  # update the audio tracks so each shot knows where in the track it should play
  _shots = []
  for sequence_id, sequence in sequences.items():
    for comp in sequence:
      _shots.extend(comp.comp_rows)

  sfx_fields = [("_Music","music"), ("_SFX1","sfx1"), ("_SFX2","sfx2")]
  for src_field, dst_field in sfx_fields:
    cur_track = "mute"
    cur_track_accum = 0.0
    for shot in _shots:
      track = shot[src_field]
      if shot["comp_type"] == "@":
        track = "mute"
      if track:
        cur_track = track
        cur_track_accum = 0
      else:
        cur_track_accum += float(shot["duration"])

      shot[dst_field] = cur_track
      shot[dst_field+"_offset"] = cur_track_accum

  # generate the sequences XML
  sequences_root = E.sequences()
  shots_root = E.shots()

  for sequence_id, sequence in sequences.items():
    sequence_root = E.sequence(sequence_id=sequence_id)
    for comp in sequence:
      sequence_root.append(comp.toXml())
      if isinstance(comp, MultiSeqElem):
        for row in comp.comp_rows:
          shots_root.append(generate_shot_xml(row))
    sequences_root.append(sequence_root)

  with open(os.path.join(generated_xml_dir, "shots.xml"), "w") as f:
    f.write(ET.tostring(shots_root, pretty_print=True))

  with open(os.path.join(generated_xml_dir, "sequences.xml"), "w") as f:
    f.write(ET.tostring(sequences_root, pretty_print=True))

  if args.upload:
    # sync generated back to S3
    subprocess.call("aws s3 sync ../Raw/Generated s3://com-twobitcircus-wby/production/wby_pipeline/Generated", shell=True)

  # OdysseyMenus.cs template
  odyssey_menus_template = """
      using UnityEngine;
      using UnityEditor;

      class OdysseyMenus {
        %s

        %s

        %s
      }
  """

  menus_shots = "\n".join([
    """[MenuItem ("Odyssey/Generate Shots/%(sequence_id)s")] public static void GenerateShots%(sequence_id)s() { OdysseyTools.GenerateShots("%(sequence_id)s"); }""" % { "sequence_id": sequence_id } for sequence_id in sequences
  ])
  menus_sequences = "\n".join([
    """[MenuItem ("Odyssey/Generate Sequences/%(sequence_id)s")] public static void GenerateSequence%(sequence_id)s() { OdysseyTools.GenerateSequenceBySequenceId("%(sequence_id)s"); }""" % { "sequence_id": sequence_id } for sequence_id in sequences
  ])

  episode_ids = list(set([sequence_id.split("_")[0] for sequence_id in sequences]))
  menus_episodes = "\n".join([
    """[MenuItem ("Odyssey/Generate Episode/%(episode_id)s")] public static void GenerateEpisode%(episode_id)s() { OdysseyTools.GenerateEpisodeByPrefix("%(episode_id)s"); }""" % { "episode_id": episode_id } for episode_id in episode_ids
  ])


  odyssey_menus_cs = odyssey_menus_template % (menus_shots, menus_sequences, menus_episodes)
  with open("../Assets/Editor/OdysseyMenus.cs", "w") as f:
    f.write(odyssey_menus_cs);


  # save the log output to the etherpad

  res = requests.post("http://wiki.twobitcircus.com/pad/api/1/setText", {
    'apikey':"6fd9a018eb3e6f8e2d80a9dc5190999410aaa32c8cf434074045c0b35966f8d1",
    'padID':"odyssey-generator-output",
    "text": stream.getvalue()
  })
  print "output is available at http://wiki.twobitcircus.com/pad/p/odyssey-generator-output"

def process_shot_row(row):
  shot_id = row["_Shot"]

  row["shot_id"] = shot_id

  # copy the verbatim headings
  for heading in copy_headings:
    row[heading.lower().replace(" ", "_")] = row["_"+heading]

  # deal with comp types
  comp_code = row["_Comp Type"].upper()
  row["_comp_code"] = comp_code

  if comp_code != '@':
    # attempt to open the corresponding anim XML file
    ae_source_xml_path = os.path.join(ae_src_xml_dir, row.get("_Data Filename","") or shot_id) + ".xml"
    try:
      with open(ae_source_xml_path, "r") as f:
        ae_root = ET.fromstring(f.read())
    except IOError:
      raise ShotError(shot_id, "couldn't read %s" % ae_source_xml_path)
    except ET.XMLSyntaxError:
      raise ShotError(shot_id, "couldn't parse %s" % ae_source_xml_path)

    # attempt to open the corresponding anim JSON file_
    ae_json_path = os.path.join(ae_src_xml_dir, row.get("_Data Filename","") or shot_id) + ".json"
    try:
      with open(ae_json_path, "r") as f:
        ae_json = json.loads(f.read())
    except IOError:
      raise ShotError(shot_id, "couldn't read %s" % ae_json_path)
    except ValueError:
      raise ShotError(shot_id, "couldn't parse %s" % ae_json_path)

    # reindex it by name:layerIndex
    ae_json = dict([ ("%s:%s" % (d["layerName"], d["layerIndex"]), d) for d in ae_json ]) 

    # copy some information back into the ae_xml
    for layer in ae_root.xpath('//layer'):
      try:
        key = "%s:%s" % (layer.attrib["name"], layer.attrib["index"])
        layer_json = ae_json[key]
      except KeyError:
        log.error("xml and json mismatch in %s (can't find %s)", shot_id, key)
        continue
      layer.attrib["parallaxBucket"] = {
        "FG": "foreground",
        "MG": "midground",
        "BG": "background",
      }.get(layer_json["parallaxBucket"].strip(), "unknown")

      layer.attrib["anchor"] = layer_json["anchor"]
    
    # write the XML back to the destination ae_xml file in /AnimData
    ae_dest_xml_path = os.path.join(ae_dest_xml_dir, row.get("_Data Filename","") or shot_id) + ".xml"
    with open(ae_dest_xml_path, "w") as f:
      f.write(ET.tostring(ae_root, pretty_print=True))
    
    try:
      meta = ae_root.find("meta")
      row["total_frames"] = meta.attrib["totalFrames"]
      row["frame_duration"] = meta.attrib["frameDuration"]
      row["_frame_offset"] = abs(int(round(float(meta.attrib.get("frameStart", 0)))))

      composition = ae_root.find("composition")
      row["width"] = composition.attrib["w"]
      row["height"] = composition.attrib["h"]
    except KeyError:
      raise ShotError(shot_id, "problem reading ae xml")

    # FIXME
    # get the audio length for later (this is hack for the moment)
    row["_audio_duration"] = get_audio_length("../Assets/Sounds/Utterances/%s_ALL.ogg" % row["shot_id"])
    #print "audio duration %s %s" % (row["shot_id"], row["_audio_duration"])

if __name__=='__main__':
  main()

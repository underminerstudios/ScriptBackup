import csv
import requests
import StringIO
from lxml import etree as ET
from lxml.builder import E
import pprint

# google docs URL
url = "https://docs.google.com/spreadsheets/d/1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw/export?format=csv&id=1nZ8YH8f1Ii74Fdq5kwTooj74r1WQOFhuGy2g2atwRGw&gid=0"

# these headings will be copied over verbatim (all lowercase with underscores)
copy_headings = ['Nickname', 'Parallax Cluster', 'Parallax Rake', 'Background', 'Background Color', 'Dirt', 'Dirt Color', 'Hotspot', 'Hotspot Color', 'Additional Prefab']

r = requests.get(url)

csv_reader = csv.reader(StringIO.StringIO(r.text))
rows = list(csv_reader)

# extract the headings to turn into dictionary keys
headings = rows.pop(0)
rows = [dict(zip(headings, row)) for row in rows]

# we'll record errors in parsing by shot_id here
errs = {}

# generate the shots XML
shots_root = E.shots()
for row in rows:
  shot_id = row["Shot"]
  art_size = row["Art Size"]
  try:
    width, height = map(int, art_size.split("x"))
  except ValueError:
    errs[shot_id] = "couldn't parse art size"
    continue

  params = {
    'width': width,
    'height': height,
  }
  # copy the verbatim headings
  for heading in copy_headings:
    params[heading.lower().replace(" ", "_")] = row[heading]
  
  shots_root.append(E.shot(
    *[E(k,str(v)) for k,v in params.items()],
    shot_id=shot_id
  ))

# group rows into seq_elems
seq_elems = []

cur_multi = None
for row in rows:
  #shot_id = row["Shot"]
  #if shot_id in errs: continue

  if row["Multipanel"].lower() == "first":
    # starting a multipanel
    cur_multi = []
  if cur_multi is not None:
    # we are building a multi
    cur_multi.append(row)
    if row["Multipanel"].lower() == "last":
      # done building a multi
      seq_elems.append(cur_multi)
      cur_multi = None
  else:
    seq_elems.append([row])

# group seq_elems into sequences
sequences = []
cur_sequence = None
for seq_elem in seq_elems:
  sequence_id = seq_elem[0]["Sequence"]
  if sequence_id:
    # we're starting a new sequence, so push the previous one
    if cur_sequence is not None:
      sequences.append(cur_sequence)
    cur_sequence = dict(id=sequence_id, seq_elems=[])
  cur_sequence["seq_elems"].append(seq_elem)

# build XML for sequences
sequences_root = E.sequences()
for sequence in sequences:
  sequence_node = E.sequence(id=sequence["id"])
  for seq_elem in sequence["seq_elems"]:
    if len(seq_elem) == 1:
      # this is a single
      shot_id = seq_elem[0]["Shot"]
      sequence_node.append(E.single(id=shot_id))
    else:
      # this is a multi
      sequence_node.append(E.multi(*[E.shot(id=shot["Shot"]) for shot in seq_elem]))
  sequences_root.append(sequence_node)


pprint.pprint(errs)
print ET.tostring(shots_root, pretty_print=True)
print ET.tostring(sequences_root, pretty_print=True)






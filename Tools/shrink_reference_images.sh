#!/bin/bash

# we resize the raw images by 50% and shrink them

cd `dirname $0`

tempdir=`mktemp -d -t /tmp`

for fn in `ls ../Raw/ReferenceImages`; do
  convert ../Raw/ReferenceImages/$fn -resize 50% $tempdir/$fn
  jpegoptim -o -m50 -d ../Assets/ReferenceImages $tempdir/$fn
done

rm -rf $tempdir



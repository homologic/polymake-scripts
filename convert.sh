#!/bin/sh

# convert the regina signatures into polymake files
r2m="../Census6Pentachora/ReginaToPolymake.py";


censusfile="../Census6Pentachora/6Pentachora/not_spheres.sig";

mkdir -p xml

parallel --progress regina-python $r2m {} xml/{}.xml < $censusfile

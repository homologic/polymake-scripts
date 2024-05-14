#!/bin/sh

# Perform bistellar flip simplification

#censusfile="unique.sig";
censusfile="../Census6Pentachora/6Pentachora/not_spheres.sig"
mkdir -p xml

parallel --progress ./$1 {} < $censusfile

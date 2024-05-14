#!/bin/sh

# Perform bistellar flip simplification

censusfile="unique.sig";

mkdir -p ../../researchdata/fundamentalgroups_simp

parallel --progress --timeout 1200 'gap -q --nointeract ../../researchdata/fundamentalgroups/{}.gap >/dev/null' < $censusfile

#!/usr/local/bin/polymake --script

#  Produce a presentation of the fundamental group to feed into GAP

use application "topaz";
use strict;
use warnings;

require "./lib.pl"; # load common functions

my $basepath="../../researchdata";

my $outpath="$basepath/fundamentalgroups";

if (! -d $outpath ) { 
	mkdir $outpath;
}

my $regdesc=shift;


my $infile = "$basepath/json_simp_lex_bistellar_flat/$regdesc.poly";
my $q= load_data($infile); #gen_simp_comp($regdesc);


$q->fundamental2gap("$outpath/$regdesc.gap");

open my $fd, ">>", "$outpath/$regdesc.gap";

my $simp_prog = "H:=SimplifiedFpGroup(G); PrintTo(\"$basepath/fundamentalgroups_simp/$regdesc\", H, RelatorsOfFpGroup(H));\n";
print $fd $simp_prog;

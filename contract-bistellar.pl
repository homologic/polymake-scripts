#!/usr/local/bin/polymake --script

# Simplify simplicial complex using edge contractions and bistellar flips

use application "topaz";
use strict;
use warnings;

require "./lib.pl"; # load common functions


my $outpath="json_simp_CP^2";

if (! -d $outpath ) { 
	mkdir $outpath;
}

my $regdesc=shift;



my $q=gen_simp_comp($regdesc);


#$q=edge_contraction($q);

$q=bistellar_simplification($q, rounds=>10000, obj=>0);
$q=bistellar_simplification($q, rounds=>1000000, obj=>0, allow_rev_move=>1, heat=>10000);

my $vert = @{$q->F_VECTOR}[0];

if (! -d "$outpath/$vert") {
	mkdir "$outpath/$vert";
}

save($q, "$outpath/$vert/$regdesc.poly");

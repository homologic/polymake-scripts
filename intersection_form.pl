#!/usr/local/bin/polymake --script

# Compute the intersection form of triangulations

use application "topaz";
use strict;
use warnings;

use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET inter_form = (?) WHERE signature = (?);");

require "./lib.pl"; # load common functions


my $inpath="json_simp_flat";


my $regdesc=shift;



my $q=load_data("$inpath/$regdesc.poly");



my $vert = @{$q->F_VECTOR}[0];

my $h=$q->HOMOLOGY;
$h =~ s/\n/;/g;
$h =~ s/ /,/g;
$h =~ s/[()]//g;
$h =~ s/\{\},//g;
$h =~ s/;$//g;


$sth->execute("@{$q->INTERSECTION_FORM}", $regdesc);
$dbh->commit;

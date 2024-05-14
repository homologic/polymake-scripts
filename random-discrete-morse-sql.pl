#!/usr/local/bin/polymake --script

# Attempt to find a spherical discrete morse vector

use application "topaz";
use strict;
use warnings;


use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET type = 'S^4', recognized = true, remark = 'discrete_morse' WHERE signature = (?);");
my $fetch = $dbh->prepare("SELECT type, recognized FROM complexes  WHERE signature = (?);");


require "./lib.pl"; # load common functions

my $basepath="../../researchdata";

my $regdesc=shift;

$fetch->execute($regdesc);
my @row = $fetch->fetchrow_array;
if ( ! ($row[1]) ) {
	my $infile = "$basepath/json_simp_lex_bistellar_flat4/$regdesc.poly";
	my $q= load_data($infile); #gen_simp_comp($regdesc);

	my $p = random_discrete_morse($q, rounds => 50000, strategy=>1, try_until_reached=>[1, 0, 0, 0, 1]);


	my $sph = $p->{[1,0,0,0,1]};
	if ($sph) {
		$sth->execute($regdesc);
	}
}

$dbh->commit;

#!/usr/bin/env -S polymake --script 

### Attempt to classify the simplicial complexes by combinatorial isomorphism


use application "topaz";
use strict;
use warnings;


use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET type = (?), remark = 'isomorphism_check' WHERE signature = (?);");
my $fetch = $dbh->prepare("SELECT type, recognized FROM complexes  WHERE signature = (?);");
my $overwrite = $dbh->prepare("UPDATE complexes SET type = (?), recognized = (?), remark = 'isomorphism_check' WHERE signature = (?) OR type = (SELECT type FROM complexes WHERE signature = (?)) AND type <> ''");
#my $regdesc = shift;
#$sth->execute($regdesc);
#my @row = $sth->fetchrow_array;


## input: feed a directory of triangulations of the same number of simplices

my $dir=shift;

my @files=<$dir/*>;

my %complexes = ();

foreach (@files) {
	my $basename = $_ =~ s,.*/([^/]*).poly$,$1,r;
	$complexes{$basename} = load_data($_);
}

my $outdir="comb_iso_classes";

if (! -d $outdir ) {
	mkdir $outdir;
}

my @ck = keys %complexes;

foreach (keys %complexes) {
	my $c = shift @ck;
	foreach (@ck) {
		if (defined $complexes{$_} and defined $complexes{$c} and isomorphic($complexes{$c}, $complexes{$_})) {
			$fetch->execute($_);
			my @row = $fetch->fetchrow_array;
			$fetch->execute($c);
			my @crow = $fetch->fetchrow_array;
			if ( $row[1] and $crow[1] ) {
				next;
			}
			if ( $row[1] ) {
				$overwrite->execute($row[0],$row[1],$c,$c);
			} elsif ($crow[1]) {
				$overwrite->execute($crow[0],$crow[1],$_,$_);
			} elsif (! $row[0] eq '') {
				$overwrite->execute($row[0],$row[1],$c,$c);
			} elsif (! $crow[0] eq '') {
				$overwrite->execute($crow[0],$crow[1],$_,$_);
			} else {
				$overwrite->execute($_,0,$c,$c);
			}
			if (! -d "$outdir/$c" ) {
				mkdir "$outdir/$c";
			}
#			$sth->execute($c,$_);
#			$sth->execute($c,$c);
			save($complexes{$_}, "$outdir/$c/$_.poly");
			print "$c $_ \n";
			delete($complexes{$_});
	   }
	}
}


$dbh->commit;

#!/usr/bin/env -S polymake --script 

### Attempt to classify the simplicial complexes by combinatorial isomorphism


use application "topaz";
use strict;
use warnings;


use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET type = (?), remark = 'isomorphism_check' WHERE signature = (?);");


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
			if (! -d "$outdir/$c" ) {
				mkdir "$outdir/$c";
			}
			$sth->execute($c,$_);
			$sth->execute($c,$c);
			save($complexes{$_}, "$outdir/$c/$_.poly");
			print "$c $_ \n";
			delete($complexes{$_});
	   }
	}
}


$dbh->commit;

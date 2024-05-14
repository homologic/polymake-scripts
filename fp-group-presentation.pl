#!/usr/bin/perl

use strict;
use warnings;


use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET fundamental = (?) WHERE signature = (?);");
my $stt = $dbh->prepare("UPDATE complexes SET fundamental = (?) WHERE type = (SELECT type FROM complexes WHERE signature = (?) AND type <> '' );");


my $sig = shift;
my $basedir = "../../researchdata";
open(my $fh, "<", "$basedir/fundamentalgroups_simp/$sig");
my $repr = <$fh>;

$repr =~ m/Group\( \[ (.*) \] \)\[ (.*) \]/;

my $group = "< | >";
if (defined $1) {
	my @gens = split(/, /, $1);
	my $expr = $2;
	
	my $letter = "a";
	my $gen = "";
	
	foreach (@gens) {
		$expr =~ s/$_/$letter/g;
		$gen .= "$letter,";
		$letter++;
	}
	$gen =~ s/,$//;
	$expr =~ s/\*//g;
	$group = "< $gen | $expr >";
}

if ($group eq "< | >") {
	$group = "0";
}
if ($group eq "< a |  >") {
	$group = "Z";
}
if ($group eq "< a b |  >") {
	$group = "Z*Z";
}



$sth->execute($group,$sig);
$stt->execute($group,$sig);
$dbh->commit;

if (! -d "$basedir/groups/$group" ) {
	`mkdir -p "$basedir/groups/$group"`;
}

`touch "$basedir/groups/$group/$sig"`;

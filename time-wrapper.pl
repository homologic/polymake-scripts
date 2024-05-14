#!/usr/bin/perl


use DBI;

use Time::HiRes qw( time );


my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("INSERT INTO log VALUES (DEFAULT, ?, ?, ?, current_timestamp);");

my $script = shift;
my $arg = shift;
my $begin_time = time();

system($script, $arg);
my $end_time = time();
$sth->execute($arg, $script, $end_time-$begin_time);
$dbh->commit();

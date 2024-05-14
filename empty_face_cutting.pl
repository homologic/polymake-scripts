#!/usr/local/bin/polymake --script

# Cut simplicial complexes along empty 4-simplex faces.

use application "topaz";
use strict;
use warnings;

use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=researchdata_test", '', '', {AutoCommit => 0});
my $sth = $dbh->prepare("UPDATE complexes SET type = 'CP^2#S^3xS^1', recognized = true, remark = 'empty_face_cutting' WHERE signature = (?);");


my $regdesc = shift;
my $infile = "homology-comp/0;1;1;1;1/14/$regdesc.poly";

my $q = load_data($infile);

my $graph = $q->GRAPH;
my $edges = $graph->EDGES();

my $nodes = range(0,$graph->N_NODES-1);

my @subsets = @{all_subsets_of_k($nodes, 5)};

# print $q->F_VECTOR, "\n";

sub relabel_facets_arr {
	my $arr = shift;
	my $facet = shift;
	my $new = new Set();
	foreach my $k (@{$facet}) {
		$new->collect(int($arr->[$k]));
	}
	return $new;
}

sub relabel_facets {
	# relabel a facet according to sane labels.
	my $q = shift;
	my $facet = shift;
	return relabel_facets_arr($q->VERTEX_LABELS,$facet);
}

sub is_simplex_face {
	my $face = shift;
	my $simplex = shift;
	return (($simplex * $face)->size() == 4)
}


sub gather {
	my $st_facets = shift;
	my $red = shift;
	my $red_f = shift;
	my $c = shift;
	while (@$red_f) {
		my $bf = shift @$red_f;
		my @match = grep { is_simplex_face($bf,$_) } @$st_facets;
		foreach my $m (@match) {
			push @$red, $m;
			push @$red_f, grep { !is_simplex_face($_,$c) } @{all_subsets_of_k($m,4)};
		}
		@$st_facets = grep { !is_simplex_face($bf,$_) } @$st_facets;
	}
}


foreach my $c ( @subsets) {

	my $subcomplex = induced_subcomplex($q, $c);
	if (isomorphic($subcomplex, simplex(4)->BOUNDARY)) {
#		print $c, "\n";
		#print $q->FACETS;
		my $s = $q;

		my $i = 0;
		my $star;
		foreach my $k (@{$c}) {
			if ($i == 0) {
				$star = star_subcomplex($q, [$k]);
			} else {
				$star = union($star, star_subcomplex($q, [$k]));
			}
			$i++;
		}
		my $first = @{all_subsets_of_k($c,4)}[0];
#		print $first, "\n";
		#		print star_subcomplex($q, $first)->FACETS;
		my $st = star_subcomplex($q, $first);
		my @ff = @{star_subcomplex($q, $first)->FACETS};
		#		print @ff, "\n";
#		print $star->VERTEX_LABELS;
		my @red = (relabel_facets($st,$ff[0]));
		my @blue = (relabel_facets($st,$ff[1]));
#		print "@red, @blue\n";
		my @red_f = grep { !is_simplex_face($_,$c) } @{all_subsets_of_k($red[0],4)};
		my @blue_f = grep { !is_simplex_face($_,$c) }  @{all_subsets_of_k($blue[0],4)};
#		print "@red_f, @blue_f\n";
#		$star->VISUAL_DUAL_GRAPH;
#		$star->VISUAL_GRAPH;
		my @st_facets = map { relabel_facets($star, $_) } grep { ! (($_ eq $red[0]) or $_ eq $blue[0])  } @{$star->FACETS}; # make sure facets have proper labels for embedding
		gather(\@st_facets,\@red,\@red_f, $c);
		gather(\@st_facets,\@blue,\@blue_f, $c);
#		print "Red: @red\n";
#		print "Blue: @blue\n";
#		print "Leftover: @st_facets\n";

		### Now replace the simplex vertices in the facets
		my @rep_table = @{$nodes};
		$i = $#rep_table + 1;
		foreach (@{$c}) {
			@rep_table[$_] = $i;
			$i++;
		}
#		print "@rep_table";
		my @q_facets = ();
		for my $k (@{$q->FACETS}) {
			push @q_facets, $k;
		}

		foreach my $f (@red) {
			my @m = grep { $q_facets[$_] eq $f } 0..$#q_facets;
#			print "@m\n";
			my $new = relabel_facets_arr(\@rep_table, $f);
			$q_facets[$m[0]] = $new;
		}
		push @q_facets, $c;
		push @q_facets, relabel_facets_arr(\@rep_table, $c);
		my $qf = new Array<Set<Int>>(@q_facets);
		my $qn = new SimplicialComplex(INPUT_FACES=>$qf);
#		print $qn->F_VECTOR, "\n";
		eval {
			my $qns = bistellar_simplification($qn);
#			print $qns->F_VECTOR, "\n";
			if ( $qns->F_VECTOR eq new Array<Int>(9,36,84,90,36) ) {
				$sth->execute($regdesc);
				$dbh->commit();
				exit;
			}
			1;
		} or do {
#			print "Error!\n";
			next;
		}
	}
}



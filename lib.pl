use application "topaz";

## Common functions

my $r2m = "ReginaToPolymake.py";


my $censusfile = "../Census6Pentachora/4Pentachora/no_spheres.sig";


my $outpath = "output";
my $xmlpath = "xml";
if (! -d $outpath ) { 
	mkdir $outpath;
}
if (! -d $xmlpath ) { 
	mkdir $xmlpath;
}


sub is_m_sequence {
	my $h0 = shift;
	$h0 == 1 or return 0;
	my $prev = shift;
	my $counter = 1;
	foreach (@_) {
		$_ >= 0 or return 0;
		if ($_ > 0 and $_ > polytope::pseudopower($prev,$counter)) {
			return 0;
		}
		$prev = $_;
		$counter++;
	}
	return 1;
}

sub g_vector {
	## calculates g-vector from supplied h-vector
	my @hv =  @{shift @_};
	my @g;
	my $size = $#hv / 2;
	my $prev = shift @hv;
	push (@g, $prev);
	foreach (@hv) {
		if ($#g > $size - 1) {
			last;
		}				
		push(@g, $_ - $prev);
		$prev = $_;
	}
	return @g;
}

sub gen_simp_comp {
	my $regdesc = shift;
	my $out = "$xmlpath/$regdesc.xml";
	
	if (! -e $out) {
		system("regina-python $r2m $regdesc $out");
	}
	my $p=load_data($out);
	my $q=new SimplicialComplex(INPUT_FACES=>$p);
	return $q;
}

1;

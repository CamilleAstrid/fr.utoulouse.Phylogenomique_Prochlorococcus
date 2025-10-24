#!/usr/bin/perl -w

use strict;
use Getopt::Long;

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};
my $node = '';

if ( defined $ENV{'SLURMD_NODENAME'} ) {
	$node = $ENV{'SLURMD_NODENAME'};
}
if ( $node !~ /node/  ) {
	print STDERR "Error: log on $node, change for a node.\n";
	exit(1);
}

print "user: $user hostname: $hostname\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'alignment=s',
	'gap=f',
	'identity=f',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'gap'}      = 70  if ( not defined $pt_parameters->{'gap'} ); 
$pt_parameters->{'identity'} = 0.4  if ( not defined $pt_parameters->{'identity'} ); 
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

if ( $pt_parameters->{'gap'} < 0 || $pt_parameters->{'gap'} > 100 ) {
	print STDERR "Error: --gap $pt_parameters->{'gap'} is not in {0, 100}\n";
	exit(1);
}
if ( $pt_parameters->{'identity'} <= 0 || $pt_parameters->{'identity'} >= 1 ) {
	print STDERR "Error: --identity $pt_parameters->{'identity'} is not in {0, 1}\n";
	exit(1);
}
print "gap $pt_parameters->{'gap'} and identity: $pt_parameters->{'identity'}\n";

if ( not defined $pt_parameters->{'alignment'} ) {
	print "--alignment is not defined\n" if ( not defined $pt_parameters->{'alignment'} );
	print STDERR "
usage:\n
$0 
	--alignment directory with alignments
	--gap       minimum % of alignment positions without gap ($pt_parameters->{'gap'})
	--identity  minimum global Average Identity ($pt_parameters->{'identity'})
	--verbose   [0,1]
	--erase     [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'alignment'} ) {
	print STDERR "Error: --alignment $pt_parameters->{'alignment'} is not found\n";
	exit(1);
}

########################################################################
# look for alignments
my $pattern = 'ali_dna_OG_.+.fas';
print "$pattern\n";
opendir(my $adir, $pt_parameters->{'alignment'}) or die "Cannot open $pt_parameters->{'alignment'}: $!";
my @file_list = grep /^$pattern$/, sort(readdir $adir);
closedir $adir;
print scalar @file_list, " entries\n";

my($alignment, $prefix, $alifile, $cmd, $trimali, $data);
my($residues, $percent, $averageidentity);
my $results = '';
my @retained = ();
$cmd  = "module load bioinfo/trimal-1.4.1;";
print "$cmd\n";
system($cmd);

foreach $alignment ( @file_list ) {
	($prefix) = $alignment =~ /^(.+)\.[a-z]{3}/;
	$alifile = $pt_parameters->{'alignment'} . '/' . $alignment;
	print "$prefix $alifile\n" if ( $pt_parameters->{'verbose'} > 0 );
	
	$trimali = $pt_parameters->{'alignment'} . '/' . $prefix . '.trim.aln';
	$data    = $pt_parameters->{'alignment'} . '/' . $prefix . '.trim.txt';
	if ( !-e $trimali or !-e $data or $pt_parameters->{'erase'} == 1 ) {
		$cmd  = "trimal -gt 0.5 -in $alifile -out $trimali -sident -sgt > $data\n";
		print "$cmd\n";
		`$cmd`;
	} else {
		print "skip: $trimali is found!\n" if ( $pt_parameters->{'verbose'} > 0 );
	}
	
	####################################################################
	if ( -e $data ) {
		$residues = 0;
		$percent = 0;
		$averageidentity = 0;
		my $test = 0;
		open(my $tfil, "$data") || die "Error, cannot open $data file\n";
		while(<$tfil>) {
			if ( /^\## AverageIdentity\s+(\d+\.\d+)/ ) {
				$averageidentity = $1;
				last
			}
			if ( $test ) {
				if ( /^\s+(\d+)\s+(\d+\.*\d*)/ ) {
					$residues = $1;
					$percent = $2;
					$test = 0;
				}
			}
			$test = 1if ( /^\+------/ );
		}
		close ($tfil);
		if ( $averageidentity < $pt_parameters->{'identity'} or $percent < $pt_parameters->{'gap'} ) {
			$results .= "$prefix\t$residues\t$percent\t$averageidentity\n";
		} else {
			push(@retained, $trimali);
		}
	} else {
		print "warning: $data is not found!\n";
	}
}
if ( $results ne '' ) {
	print "\nAlignments below thresholds:\n";
	print "File      \tsize\t% gap      \taverage identity\n";
	print $results, "\n";
}
print scalar @retained, " alignments retained\n";
if ( @retained > 0 ) {
	my $outfile = $pt_parameters->{'alignment'} . '/' . 'alignment_' . $pt_parameters->{'identity'} . '_' . $pt_parameters->{'gap'} . '.lst';
	open(my $opt, ">$outfile") || die "Error, cannot open $outfile file\n";
	print $opt join("\n", @retained), "\n"; 
	close($opt);
	print "\nlist: $outfile\n";
}
	

#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Bio::SeqIO;
use Bio::AlignIO;

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};
my $node = '';

if ( defined $ENV{'SLURMD_NODENAME'} ) {
	$node = $ENV{'SLURMD_NODENAME'};
}
if ( $node !~ /n/  ) {
	print STDERR "Error: log on $node, change for a node.\n";
	exit(1);
}

print "user: $user hostname: $hostname\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'alignments=s',
	'outfile=s',
	'nb_ali=i',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 
$pt_parameters->{'nb_ali'}   = 0  if ( not defined $pt_parameters->{'nb_ali'} );
 
if ( not defined $pt_parameters->{'alignments'} or not defined $pt_parameters->{'outfile'} ) {
	print "--alignments is not defined\n" if ( not defined $pt_parameters->{'alignments'} );
	print "--outfile is not defined\n" if ( not defined $pt_parameters->{'outfile'} );
	print STDERR "
usage:\n
$0 
	--alignments file with list of alignments
	--outfile    file name with the concatenated alignments
	--nb_ali     nombre d'alignements à sélectioner (0 pour tous les alignements)
	--verbose    [0,1]
	--erase      [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'alignments'} ) {
	print STDERR "Error: --alignments $pt_parameters->{'alignments'} is not found\n";
	exit(1);
}
open(my $inf, "$pt_parameters->{'alignments'}") or die "Cannot open $pt_parameters->{'alignments'}: $!";
my @list = ();
while(<$inf>) {
	chomp();
	push(@list, $_);
}
close($inf);
print scalar @list, " alignments\n"; 

########################################################################
# concatenation (simple!)
my $outputfilename = $pt_parameters->{'outfile'};
my $seq_out = Bio::SeqIO->new( -file   => ">$outputfilename", -format => 'fasta');

my($file, $inseq, $strain, $seqobj);
my %concatenate = ();
my $num = 0;
my @retained = ();
my $pos = 1;

foreach $file ( @list ) {
	$inseq = Bio::SeqIO->new(-file => $file);
	my $len = 0;
	while (my $seq = $inseq->next_seq) {
		$strain = substr($seq->id, 0, 4);
                my $cleanseq = $seq->seq;
                $len = $seq->length();
		# masquer les codons stops
		if ( $cleanseq =~ /(\-+)$/ ) {
			my $gap = $1;
			$cleanseq =~ s/TAA-+$|taa-+$|TGA-+$|tga-+$|TAG-+$|tag-+$/NNN/og;
			$cleanseq .= $gap;
		} else {
                        $cleanseq =~ s/TAA$|taa$|TGA$|tga$|TAG$|tag$/NNN/og;
		}
		if ( length($cleanseq) != $len ) {
			print $len, "\t", $seq->seq, "\n", length($cleanseq), "\t", $cleanseq, "\n";
			exit(1);
		}
		# $concatenate{$strain}.= $seq->seq;
		$concatenate{$strain}.= $cleanseq;
	}
	push(@retained, $file);
	print $file, "\t", $pos, "\t", $pos+$len-1, "\n";
	$pos = $pos + $len;
	last if ( $pt_parameters->{'nb_ali'} > 0 && $num >= $pt_parameters->{'nb_ali'}); 
	$num++;
}
print "$num alignments\n";
foreach $strain ( sort keys %concatenate ) {
	$seqobj = Bio::PrimarySeq->new (-seq=>$concatenate{$strain}, -id=>$strain);
	$seq_out->write_seq($seqobj);
}

if ( @retained > 0 ) {
	my $outfile = $pt_parameters->{'outfile'} . '.lst';
	open(my $opt, ">$outfile") || die "Error, cannot open $outfile file\n";
	print $opt join("\n", @retained), "\n"; 
	close($opt);
	print "\nlist: $outfile\n";
}

exit;




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
#~ my @retained = ();

foreach $alignment ( @file_list ) {
	($prefix) = $alignment =~ /^(.+)\.[a-z]{3}/;
	$alifile = $pt_parameters->{'alignment'} . '/' . $alignment;
	print "$prefix $alifile\n" if ( $pt_parameters->{'verbose'} > 0 );
	
	$trimali = $pt_parameters->{'alignment'} . '/' . $prefix . '.trim.aln';
	$data    = $pt_parameters->{'alignment'} . '/' . $prefix . '.trim.txt';
	if ( !-e $trimali or !-e $data or $pt_parameters->{'erase'} == 1 ) {
		$cmd  = "/usr/local/bioinfo/bin/trimal -automated1 -in $alifile -out $trimali -sident -sgt > $data\n";
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
			push(@retained, $alifile);
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
	

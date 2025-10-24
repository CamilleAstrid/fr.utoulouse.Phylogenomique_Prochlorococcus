#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};
my $node = '';

if ( defined $ENV{'SLURMD_NODENAME'} ) {
	$node = $ENV{'SLURMD_NODENAME'};
}
if ( $node !~ /node/ ) {
	print STDERR "Error: log on $node, change for node.\n";
	exit(1);
}
print "user: $user hostname: $hostname\t$node\n\n";
########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'fasta=s',
	'list=s',
	'outname=s',
	'quorum=i',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 
$pt_parameters->{'quorum'}   = 4  if ( not defined $pt_parameters->{'quorum'} ); 

if ( not defined $pt_parameters->{'fasta'} or  not defined $pt_parameters->{'list'} or  not defined $pt_parameters->{'outname'} ) {
	print "--fasta is not defined\n" if ( not defined $pt_parameters->{'fasta'} );
	print "--list is not defined\n" if ( not defined $pt_parameters->{'list'} );
	print "--outname is not defined\n" if ( not defined $pt_parameters->{'outname'} );
	print STDERR "
usage:\n
$0 
	--fasta      fasta directory with sequences from the matchtable
	--list       file with a list of genes
	--outname    output file
	--verbose [0,1]
	--erase   [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'fasta'} ) {
	print STDERR "Error: --fasta $pt_parameters->{'fasta'} is not found\n";
	exit(1);
}
if ( !-e $pt_parameters->{'list'} ) {
	print STDERR "Error: --list $pt_parameters->{'list'} is not found\n";
	exit(1);
}
#~ if ( !-e $pt_parameters->{'outdir'} ) {
	#~ print STDERR "Error: --outdir $pt_parameters->{'outdir'} is not found\n";
	#~ exit(1);
#~ }

########################################################################
# read list
print "Read list\n";

my $pt_og = {};
my $num = 0;
my @members = ();

	@members = ();
open(my $fin, "$pt_parameters->{'list'}") or die "Error while opening $pt_parameters->{'list'}: $0\n";
while (<$fin>) {
	chomp();
	push(@members, split(/\s+/));
}
close($fin);
print join("\n", @members), "\n";
#~ print Dumper $pt_og;

########################################################################
# Make an index for one or more fasta files
print "Make an index for fasta files\n";
my($db, $member, $seq, $outname, $outfile);
$db = Bio::DB::Fasta->new($pt_parameters->{'fasta'});

print "Extract sequences\n";
my @ids      = $db->get_all_primary_ids;
$outname = $pt_parameters->{'outname'};
$outfile = Bio::SeqIO->new(-file => ">$outname", '-format' => 'Fasta');
foreach $member ( @members ) {
	$seq = $db->get_Seq_by_id($member);
	if ( not defined $seq ) {
		print STDERR "Error: $member is not found!\n";
		exit;
	}
	my $length  = $seq->length;
	print "$member $length\n" if ( $pt_parameters->{'verbose'} > 0 );
	$outfile->write_seq($seq);
}
$outfile->close();
print "$outname\n";


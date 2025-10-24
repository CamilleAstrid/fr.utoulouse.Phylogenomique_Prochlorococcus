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
	'matchtable=s',
	'outdir=s',
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

if ( not defined $pt_parameters->{'fasta'} or  not defined $pt_parameters->{'matchtable'} or  not defined $pt_parameters->{'outdir'} ) {
	print "--fasta is not defined\n" if ( not defined $pt_parameters->{'fasta'} );
	print "--matchtable is not defined\n" if ( not defined $pt_parameters->{'matchtable'} );
	print "--outdir is not defined\n" if ( not defined $pt_parameters->{'outdir'} );
	print STDERR "
usage:\n
$0 
	--fasta      fasta directory with sequences from the matchtable
	--matchtable matchtable file obtained with panoct
	--outdir     directory for the output files
	--quorum     nombre de membre minimal par GO
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
if ( !-e $pt_parameters->{'matchtable'} ) {
	print STDERR "Error: --matchtable $pt_parameters->{'matchtable'} is not found\n";
	exit(1);
}
if ( !-e $pt_parameters->{'outdir'} ) {
	print STDERR "Error: --outdir $pt_parameters->{'outdir'} is not found\n";
	exit(1);
}

########################################################################
# read matchetable
print "Read matchetable\n";

my $pt_og = {};
my @tmp = ();
my $num = 0;
my @members = ();

open(my $fin, "$pt_parameters->{'matchtable'}") or die "Error while opening $pt_parameters->{'matchtable'}: $0\n";
while (<$fin>) {
	chomp();
	@tmp = split(/\t/);
	$num = shift(@tmp);
	@members = ();
	foreach (@tmp) {
		next if ( /-/ );
		push(@members, $_);
	}
	if ( scalar @members >= $pt_parameters->{'quorum'} ) {
		push(@{$pt_og->{$num}}, @members);
	}
}
close($fin);

#~ print Dumper $pt_og;

########################################################################
# Make an index for one or more fasta files
print "Make an index for fasta files\n";
my($db, $member, $seq, $outname, $outfile);
$db = Bio::DB::Fasta->new($pt_parameters->{'fasta'});

print "Extract sequences\n";
my @ids      = $db->get_all_primary_ids;
foreach $num ( sort {$a<=>$b} keys %$pt_og ) {
	$outname = $pt_parameters->{'outdir'} . '/OG_' . $num . '.fas';
	$outfile = Bio::SeqIO->new(-file => ">$outname", '-format' => 'Fasta');
	foreach $member ( @{$pt_og->{$num}} ) {
		$seq = $db->get_Seq_by_id($member);
		my $length  = $seq->length;
		print "$member $length\n" if ( $pt_parameters->{'verbose'} > 0 );
		$outfile->write_seq($seq);
	}
	$outfile->close();
	print "$outname\n";
}

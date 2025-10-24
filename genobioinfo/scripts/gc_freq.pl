#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Bio::SeqIO;
use Bio::Tools::SeqStats;

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};

#~ if ( $hostname !~ /node/) {
	#~ print STDERR "Error: log on $hostname, change for genotoul node (qlogin).\n";
	#~ exit(1);
#~ }

print STDERR "user: $user hostname: $hostname\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'file=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

if ( not defined $pt_parameters->{'file'} ) {
	print "--file is not defined\n" if ( not defined $pt_parameters->{'file'} );
	print STDERR "
usage:\n
$0 
	--file      DNA sequence file(s) in fasta format
	--verbose   [0,1]
	--erase     [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'file'} ) {
	print STDERR "Error: --file $pt_parameters->{'file'} is not found\n";
	exit(1);
}
my($seqin, $seq, $seq_stats, $hash_ref, $total_base, $strain);
$seqin = new Bio::SeqIO(-format => 'fasta',	-file => $pt_parameters->{'file'});
while( $seq = $seqin->next_seq ) {
	next if( $seq->length == 0 );
	if( $seq->alphabet eq 'protein' ) {
		warn("amino acid sequences ...skipping this seq");
		next;
	}
	$seq_stats = Bio::Tools::SeqStats->new('-seq'=>$seq);
	$hash_ref = $seq_stats->count_monomers();
	($strain) = $seq->display_id =~ /gnl\|Prokka\|(\w{4})/;
	
	printf "%s\t%d\t%.4f\n", $strain, $seq->length, ($hash_ref->{'G'} + $hash_ref->{'C'}) /$seq->length();
}

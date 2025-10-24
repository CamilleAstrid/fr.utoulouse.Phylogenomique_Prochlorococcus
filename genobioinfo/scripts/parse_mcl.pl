#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::SeqIO;
use Bio::SearchIO;
use Bio::AlignIO;
use Getopt::Long;

use Data::Dumper;

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'mcloutput=s',
	'fasta_dir=s',
	'quorum=i',
	'I=f',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
#~ print Dumper $pt_parameters;

my $usage = "usage:\n
$0 
    --mcloutput      str     mcl output file 
    --fasta_dir      str     directory with fasta files
    --quorum         int     minimum class size
    --IF             flt     IF used
\n";
########################################################################
$pt_parameters->{'verbose'}        = 0  if ( not defined  $pt_parameters->{'verbose'});
$pt_parameters->{'erase'}          = 0  if ( not defined  $pt_parameters->{'erase'});
my $error = 0;
if ( not defined $pt_parameters->{'mcloutput'} ) {
	print STDERR " --mcloutput not defined\n";
	$error++;
} else {
	if ( !-e $pt_parameters->{'mcloutput'} ) {
		print STDERR "Error: --mcloutput $pt_parameters->{'mcloutput'} not found\n";
		$error++;
	}
}
if ( not defined $pt_parameters->{'fasta_dir'} ) {
	print STDERR " --taxonlist not defined\n";
	$error++;
} else {
	if ( !-e $pt_parameters->{'taxonlist'} ) {
		print STDERR "Error: --taxonlist $pt_parameters->{'taxonlist'} not found\n";
		$error++;
	}
}
if ( not defined $pt_parameters->{'quorum'} ) {
	print STDERR " --quorum not defined\n";
	$error++;
}
if ( not defined $pt_parameters->{'IF'} ) {
	print STDERR " --IF not defined\n";
	$error++;
}
if ( $error > 0  ) {
	print $usage;
	exit(1);
}

if ( !-e $pt_parameters->{'out_dir'} ) {
	print STDERR "Error: --out_dir $pt_parameters->{'out_dir'} not found\n";
	mkdir($pt_parameters->{'out_dir'});
}

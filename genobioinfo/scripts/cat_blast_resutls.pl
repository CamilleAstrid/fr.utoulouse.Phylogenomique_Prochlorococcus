#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'query=s',
	'taxonlist=s',
	'blast_dir=s',
	'out_dir=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
#~ print Dumper $pt_parameters;

my $usage = "usage:\n
$0 
	--query     strain query
	--taxonlist A single column file containing the list of taxon to work with
	--blast_dir directory with parsed pairwise blast results
	--out_dir   output directory to save the ss files
\n";
########################################################################
$pt_parameters->{'verbose'}        = 0  if ( not defined  $pt_parameters->{'verbose'});
$pt_parameters->{'erase'}          = 0  if ( not defined  $pt_parameters->{'erase'});
my $error = 0;
if ( not defined $pt_parameters->{'query'} ) {
	print STDERR " --query not defined\n";
	$error++;
}
if ( not defined $pt_parameters->{'taxonlist'} ) {
	print STDERR " --taxonlist not defined\n";
	$error++;
} else {
	if ( !-e $pt_parameters->{'taxonlist'} ) {
		print STDERR "Error: --taxonlist $pt_parameters->{'taxonlist'} not found\n";
		$error++;
	}
}
if ( not defined $pt_parameters->{'blast_dir'} ) {
	print STDERR " --blast_dir not defined\n";
	$error++;
} else {
	if ( !-e $pt_parameters->{'blast_dir'} ) {
		print STDERR "Error: --blast_dir $pt_parameters->{'blast_dir'} not found\n";
		$error++;
	}
}
if ( $error > 0  ) {
	print $usage;
	exit(1);
}

if ( !-e $pt_parameters->{'out_dir'} ) {
	print STDERR "Error: --out_dir $pt_parameters->{'out_dir'} not found\n";
	mkdir($pt_parameters->{'out_dir'});
}
########################################################################
open(my $LST, "$pt_parameters->{'taxonlist'}") || die "Error: cannt open $pt_parameters->{'taxonlist'}\n";
my @taxon_list = ();
while(<$LST>) {
	chomp();
	push(@taxon_list, $_);
}
close($LST);
if ( !grep(/$pt_parameters->{'query'}/, @taxon_list )) {
	print STDERR "Error: $pt_parameters->{'query'} is not found in taxon list!\n";
	exit;
}
print join("\n", @taxon_list), "\n" if ( $pt_parameters->{'verbose'} > 0 );

########################################################################
my($db, $bast_file, $ss_file);
$ss_file = $pt_parameters->{'out_dir'} . '/' . $pt_parameters->{'query'} . '.tab';
if ( -e $ss_file && $pt_parameters->{'erase'} == 0 ) {
	print STDERR "skip $ss_file is found\n";
} else  {

	unlink  $ss_file if ( -e $ss_file);
	foreach $db (@taxon_list) {
		$bast_file = $pt_parameters->{'blast_dir'} . '/' . $pt_parameters->{'query'} . '_' . $db .'.tab';
		if ( !-e $bast_file ) {
			print STDERR "Error: $bast_file not found\n";
			unlink  $ss_file;
			exit;
		}
		`cat $bast_file >> $ss_file`;
	}
	print STDERR "$ss_file\n";
}




#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Data::Dumper;

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'annotation=s',
	'index=s',
	'verbose=i',
	'erase',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 

if ( not defined $pt_parameters->{'annotation'} or  not defined $pt_parameters->{'index'} ) {
	print "--annotation is not defined\n" if ( not defined $pt_parameters->{'annotation'} );
	print "--index is not defined\n" if ( not defined $pt_parameters->{'index'} );
	print STDERR "
usage:\n
$0 
	--annotation  EggNog annotation files (<prefix>.emapper.annotations)
	--index       index file
	--verbose     [0,1]
	--erase
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'annotation'} ) {
	print STDERR "Error: --annotation $pt_parameters->{'annotation'} is not found\n";
	exit(1);
}

########################################################################
# read annotations
print "Read annotations\n";

my @tmp = ();
my $pos = 0;

open(my $fin, "$pt_parameters->{'annotation'}") or die "Error while opening $pt_parameters->{'annotation'}: $0\n";
open(my $fou, ">$pt_parameters->{'index'}") or die "Error while opening $pt_parameters->{'index'}: $0\n";
while (<$fin>) {
	if ( ! /^#/ ) {
		@tmp = split(/\t/);
		if ( $tmp[0] ) {
			print $fou "$tmp[0]\t$pos\n";
		}
	}
	$pos += length($_);
}
close($fin);
close($fou);

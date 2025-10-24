#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Data::Dumper;

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'query=s',
	'annotation=s',
	'index=s',
	'verbose=i',
	'erase',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 

if ( not defined $pt_parameters->{'query'} or  not defined $pt_parameters->{'annotation'} or  not defined $pt_parameters->{'index'} ) {
	print "--query is not defined\n" if ( not defined $pt_parameters->{'query'} );
	print "--annotation is not defined\n" if ( not defined $pt_parameters->{'annotation'} );
	print "--index is not defined\n" if ( not defined $pt_parameters->{'index'} );
	print STDERR "
usage:\n
$0 
	--query       protein name
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
my($index) = get_index($pt_parameters);
if ( $index >= 0 ) {
 	open(my $fse,"< $pt_parameters->{'annotation'}") || die "Couldn't open $pt_parameters->{'annotation'} as input - died: $0";
	seek ($fse, $index, 0);
	my $entry = <$fse>;
	print $entry;
} else {
	print STDERR "Error: $pt_parameters->{'query'} is not found in $pt_parameters->{'index'}.\n";
}

########################################################################
sub get_index {
	my($pt_parameters) = @_;
	
	my($name);	
	my $index = -1;
	open(my $fin,"< $pt_parameters->{'index'}") || die "Couldn't open $pt_parameters->{'index'} as input - died: $0";
		while (<$fin>) {
			chop;
			($name, $index)= split(/\t/);
			last if ( $pt_parameters->{'query'} eq $name);
		}
	close($fin);
	print "$name\t$index\n";
	return($index);
}

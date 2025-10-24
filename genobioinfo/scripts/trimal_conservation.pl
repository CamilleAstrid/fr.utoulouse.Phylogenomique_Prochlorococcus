#!/usr/bin/perl -w

use strict;
use Getopt::Long;

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};

if ( $hostname !~ /genotoul/ ) {
	print STDERR "Error: log on $hostname, change for genotoul server.\n";
	exit(1);
}

print "user: $user hostname: $hostname\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'alignment=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

if ( not defined $pt_parameters->{'alignment'} ) {
	print "--alignment is not defined\n" if ( not defined $pt_parameters->{'alignment'} );
	print STDERR "
usage:\n
$0 
	--alignment alignment to trim
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
my @tmp = split(/\//, $pt_parameters->{'alignment'});
($pt_parameters->{'trimali'}) = $pt_parameters->{'alignment'} =~ /(.+)\.[a-z]{3}/;
$pt_parameters->{'trimali'} .= '_trim.aln';
$pt_parameters->{'data'} = $pt_parameters->{'trimali'} . '_trim.txt';
if ( -e $pt_parameters->{'trimali'} && $pt_parameters->{'erase'} != 1 ) {
	print "skip: $pt_parameters->{'trimali'} is found!\n";
	exit(0);
}
unlink  $pt_parameters->{'data'} if ( -e $pt_parameters->{'data'} );
my $name = 'trimal_' . $tmp[-1];
print "$pt_parameters->{'trimali'}\n";
my $cmd  = "/usr/local/bioinfo/bin/trimal -automated1 -in $pt_parameters->{'alignment'} -out $pt_parameters->{'trimali'} -sident -sgt > $pt_parameters->{'data'}\n";
print "$cmd\n";
`$cmd`;

# peptide alignment ####################################################
#~ $cmd = "module load bioinfo/muscle3.8.31\n"; 
#~ $cmd .= "muscle -in $pt_parameters->{'pep'} -out $pt_parameters->{'ali_pep'} -quiet";
#~ `$cmd`;
#~ print "$pt_parameters->{'ali_pep'}\n" if ( $pt_parameters->{'verbose'} > 0 );
 #~ 
#~ # peptide to dna alignment #############################################
#~ my($alignio, $aa_aln);
#~ my $alignio = Bio::AlignIO->new(-format => 'fasta', -file => $pt_parameters->{'ali_pep'});
#~ my $aa_aln  = $alignio->next_aln;
#~ my $dna_aln = aa_to_dna_aln($aa_aln, $seqs);
#~ 
#~ my $out = Bio::AlignIO->new(-file => ">$pt_parameters->{'ali_dna'}" , '-format' => 'fasta');
#~ $out ->write_aln($dna_aln);
#~ print "$pt_parameters->{'ali_dna'}\n" if ( $pt_parameters->{'verbose'} > 0 );


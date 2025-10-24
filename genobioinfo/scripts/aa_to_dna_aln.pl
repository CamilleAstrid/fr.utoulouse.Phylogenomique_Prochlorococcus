#!/usr/bin/perl -w

# Will convert an AA alignment to DNA space given the 
# corresponding DNA sequences.  Note that this method expects 
# the DNA sequences to be in frame +1 

use strict;
use Getopt::Long;
use Bio::SeqIO;
use Bio::AlignIO;
use Bio::Align::Utilities qw(aa_to_dna_aln);

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

print "user: $user hostname: $hostname\t$node\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'dna=s',
	'outdir=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

if ( not defined $pt_parameters->{'dna'} ) {
	print "--dna is not defined\n" if ( not defined $pt_parameters->{'dna'} );
	print STDERR "
usage:\n
$0 
	--dna        file with dna sequences in fasta format
	--outdir     directory for the output files
	--verbose [0,1]
	--erase   [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'dna'} ) {
	print STDERR "Error: --dna $pt_parameters->{'directory'} is not found\n";
	exit(1);
}
if ( !-e $pt_parameters->{'outdir'} ) {
	print STDERR "Error: --outdir $pt_parameters->{'outdir'} is not found\n";
	exit(1);
}
my @tmp = split(/\//, $pt_parameters->{'dna'});
$pt_parameters->{'pep'} = $pt_parameters->{'outdir'} . '/pep_' . $tmp[-1];
$pt_parameters->{'ali_pep'} = $pt_parameters->{'outdir'} . '/ali_pep_' . $tmp[-1];
$pt_parameters->{'ali_dna'} = $pt_parameters->{'outdir'} . '/ali_dna_' . $tmp[-1];

if ( -e $pt_parameters->{'ali_dna'} && $pt_parameters->{'erase'} != 1 ) {
	print "skip: $pt_parameters->{'ali_dna'} is found!\n";
	exit(0);
}

########################################################################
my($dnaio_obj, $pepio_obj, $dna_obj, $pep_obj, $cmd);
$dnaio_obj = Bio::SeqIO->new(-file => $pt_parameters->{'dna'}, -format => "fasta" );
$pepio_obj = Bio::SeqIO->new(-file => ">$pt_parameters->{'pep'}", -format => 'fasta' );

# translate dna ########################################################
print "translate dna\n" if ( $pt_parameters->{'verbose'} > 0 );
my $seqs = {};
while ($dna_obj = $dnaio_obj->next_seq){   
	$seqs->{$dna_obj->display_id} = $dna_obj;
	$pep_obj = $dna_obj->translate;
    $pepio_obj->write_seq($pep_obj);
}
$pepio_obj->close();
print "$pt_parameters->{'pep'}\n" if ( $pt_parameters->{'verbose'} > 0 ); 

# peptide alignment ####################################################
print "peptide alignment" if ( $pt_parameters->{'verbose'} > 0 );

$cmd = "module load bioinfo/MUSCLE/5.1.0;\n"; 
$cmd .= "muscle -align $pt_parameters->{'pep'} -output $pt_parameters->{'ali_pep'} -quiet";
`$cmd`;
print "$cmd\n" if ( $pt_parameters->{'verbose'} > 0 );
print "$pt_parameters->{'ali_pep'}\n" if ( $pt_parameters->{'verbose'} > 0 );
 
# peptide to dna alignment #############################################
my $alignio = Bio::AlignIO->new(-format => 'fasta', -file => $pt_parameters->{'ali_pep'});
my $aa_aln  = $alignio->next_aln;
my $dna_aln = aa_to_dna_aln($aa_aln, $seqs);

my $out = Bio::AlignIO->new(-file => ">$pt_parameters->{'ali_dna'}" , '-format' => 'fasta');
$out ->write_aln($dna_aln);
print "$pt_parameters->{'ali_dna'}\n" if ( $pt_parameters->{'verbose'} > 0 );


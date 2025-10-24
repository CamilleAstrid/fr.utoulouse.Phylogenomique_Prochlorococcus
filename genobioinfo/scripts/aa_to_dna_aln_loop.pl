#!/usr/bin/perl -w

# Will convert an AA alignment to DNA space given the 
# corresponding DNA sequences.  Note that this method expects 
# the DNA sequences to be in frame +1 

use strict;
use Getopt::Long;
use List::Util qw(shuffle);

my $user = $ENV{'USER'};
my $hostname = $ENV{'HOSTNAME'};
my $node = '';

if ( defined $ENV{'SLURMD_NODENAME'} ) {
	$node = $ENV{'SLURMD_NODENAME'};
}
if ( $hostname !~ /genologin/ || $node ne '' ) {
	print STDERR "Error: log on $node, change for genologin server.\n";
	exit(1);
}

print "user: $user hostname: $hostname\t$node\n\n";

########################################################################

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'directory=s',
	'outdir=s',
	'sample=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

if ( not defined $pt_parameters->{'directory'} or  not defined $pt_parameters->{'sample'} or  not defined $pt_parameters->{'outdir'} ) {
	print "--directory is not defined\n" if ( not defined $pt_parameters->{'directory'} );
	print "--sample is not defined\n" if ( not defined $pt_parameters->{'sample'} );
	print "--outdir is not defined\n" if ( not defined $pt_parameters->{'outdir'} );
	print STDERR "
usage:\n
$0 
	--directory  directory with peptide alignments
	--outdir     directory for the output files
	--sample     number of files to sample
	--verbose [0,1]
	--erase   [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'directory'} ) {
	print STDERR "Error: --directory $pt_parameters->{'directory'} is not found\n";
	exit(1);
}
if ( !-e $pt_parameters->{'outdir'} ) {
	print STDERR "Error: --outdir $pt_parameters->{'outdir'} is not found\n";
	exit(1);
}

########################################################################
# look for alignment files 
my $pattern = '.fas';
opendir(my $rdir, $pt_parameters->{'directory'}) or die "Cannot open $pt_parameters->{'directory'}: $!";
my @file_list = grep /$pattern/, sort(readdir $rdir);
closedir $rdir;
if ( scalar @file_list == 0 ) {
	print STDERR "Error: no file $pattern found in  $pt_parameters->{'directory'}!\n";
	exit(1);
}
my $nb = scalar @file_list;
print $nb, " entries with $pattern suffix are found in $pt_parameters->{'directory'}\n";
my @shuffled_list = shuffle(@file_list);

########################################################################
# read alignments
my($alignment, $fasta, $prefix, $cmd, $workname, $sbatch_file, $sbatch_out, $sbatch_err);
my $num = 0;
while ( $num < $pt_parameters->{'sample'} ) {
	$alignment = $shuffled_list[$num];
	$fasta = $pt_parameters->{'directory'} . '/' . $alignment;
	($prefix) = $alignment =~ /(.+)\./;
	if ( !-e $fasta ) {
		print STDERR "Error; $fasta is not found\n";
		exit(1);
	}
	$pt_parameters->{'ali_dna'} = $pt_parameters->{'outdir'} . '/ali_dna_' . $alignment;
	
	print "$pt_parameters->{'ali_dna'}\n" if ( $pt_parameters->{'verbose'} > 0 );
	if ( -e $pt_parameters->{'ali_dna'} && $pt_parameters->{'erase'} != 1 ) {
		print "skip: $pt_parameters->{'ali_dna'} is found!\n";
		next;
	}
	$num++;
	
	$cmd = "/home/formation/public_html/M2_Phylogenomique/scripts/aa_to_dna_aln.pl";
	$cmd .= " -dna $fasta --outdir $pt_parameters->{'outdir'}";
	print "$cmd\n" if ($pt_parameters->{'verbose'} > 0 );
	$workname = 'aa_to_dna_aln_' . $prefix;
	$sbatch_file = $pt_parameters->{'outdir'} . '/' . $prefix . '.sh';
	$sbatch_out  = $pt_parameters->{'outdir'} . '/' . $prefix . '.out';
	$sbatch_err  = $pt_parameters->{'outdir'} . '/' . $prefix . '.err';
	run_script($sbatch_file, $workname, $sbatch_out, $sbatch_err, $cmd);
	print "$sbatch_file\n" if ($pt_parameters->{'verbose'} > 0 );
	`sbatch $sbatch_file`;
	
}
print "squeue -l -u $user";
$cmd = `squeue -l -u $user`;
print $cmd;
########################################################################
sub run_script {
	my($script_file, $workname, $out, $err, $cmd) = @_;
	
	open (my $SCRTFILE, ">$script_file") || die "Blast Error Unable to create temporary file: $script_file: $!";

	print $SCRTFILE '#!/bin/bash' . "\n";
	print $SCRTFILE '#SBATCH -J ' . "$workname\n";
	print $SCRTFILE '#SBATCH -o ' .  "$out\n";
	print $SCRTFILE '#SBATCH -o ' .  "$err\n";
	print $SCRTFILE '#SBATCH --time=00:5:00' .  "\n";
	print $SCRTFILE '#SBATCH --cpus-per-task=1' .  "\n";
	print $SCRTFILE "module purge\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}

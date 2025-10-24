#!/usr/bin/perl -w

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
	'sample=s',
	'outdir=s',
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
	--directory  directory with fasta files
	--sample     number of files to sample
	--outdir     directory for the output files
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
if ( $pt_parameters->{'sample'} > 100 ) {
	print STDERR "Error: --sample $pt_parameters->{'sample'} > 100\n";
	exit(1);
}

########################################################################
# look for fasta files 
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

my($fasta, $outfile, $prefix, $cmd, $workname, $sbatch_file, $sbatch_out, $sbatch_err);
my $num = 0;
while ( $num < $pt_parameters->{'sample'} ) {
	print "$shuffled_list[$num]\n";
	($prefix) = $shuffled_list[$num] =~ /(.+)\.fas$/;
	$num++;
	$fasta = $pt_parameters->{'directory'} . '/' . $shuffled_list[$num];
	if ( !-e $fasta ) {
		print STDERR "Error; $fasta is not found\n";
		exit(1);
	}
	$outfile  = $pt_parameters->{'outdir'} . '/' . $prefix . '.aln';
	if ( -e $outfile && $pt_parameters->{'erase'} == 0) {
		print "skip: $outfile is found.\n";
		next;
	}
	$cmd = "muscle -in $fasta -out $outfile";
	print "$cmd\n";
	$workname = 'muscle_' . $prefix;
	$sbatch_file = $pt_parameters->{'outdir'} . '/' . $prefix . '.sh';
	$sbatch_out  = $pt_parameters->{'outdir'} . '/' . $prefix . '.out';
	$sbatch_err  = $pt_parameters->{'outdir'} . '/' . $prefix . '.err';
	run_script($sbatch_file, $workname, $sbatch_out, $sbatch_err, $cmd);
	print "$sbatch_file\n";
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
	print $SCRTFILE "module load bioinfo/muscle3.8.31\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}

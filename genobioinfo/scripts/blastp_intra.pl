#!/usr/bin/perl -w

use strict;
use Cwd;

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

my $cwd = cwd();
if ( !-e 'BlastP' ){
	print STDERR "Error BlastP sub directory is expected!\n";
	exit;
}
print "user: $user hostname: $hostname\t$node\ncurrent directory: $cwd\n\n";

########################################################################
# parameters
my $pattern = '.faa$';
my $evalue = 1e-5;

# look for peptides files in peptide
my $pep_dir = $cwd . '/peptide';

# look for files in the current directory
opendir(my $rdir, $pep_dir) or die "Cannot open $pep_dir: $!";
my @file_list = grep /$pattern/, sort(readdir $rdir);
closedir $rdir;
if ( scalar @file_list == 0 ) {
	print STDERR "Error: no file $pattern found in  $pep_dir!\n";
	exit(1);
}
print scalar @file_list, " $pattern entries in $pep_dir\n";

########################################################################
my($cmd, $prefix, $outfile, $workname, $sbatch_file, $sbatch_out, $sbatch_err);
foreach my $file (@file_list ) {
	print "$file\n";
	if ( $file =~ /(\w+)$pattern/ ) {
		$prefix = $1;
		my $outfile = 'BlastP/'. $prefix . '_' . $prefix . '.tab';
		if ( -e $outfile ) {
			print "skip: $outfile\n";
		} else {
			$cmd = "blastp -query peptide/$file -db peptide/$file -seg yes -dbsize 100000000  -evalue $evalue -outfmt 6 -num_threads 1 -out $outfile";
			print "$cmd\n";
			$workname = 'blastp_' . $prefix;
			$sbatch_file = $prefix . '.sh';
			$sbatch_out  = $prefix . '.out';
			$sbatch_err  = $prefix . '.err';
			run_script($sbatch_file, $workname, $sbatch_out, $sbatch_err, $cmd);
			print "$sbatch_file\n";
			`sbatch $sbatch_file`;
		}
	} 
}
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
	print $SCRTFILE "module load bioinfo/ncbi-blast-2.6.0+\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}



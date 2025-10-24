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
if ( !-e 'BlastN' ){
	print STDERR "Error BlastN is expected!\n";
	exit;
}
print "user: $user hostname: $hostname\t$node\ncurrent directory: $cwd\n\n";

# parameters
my $pattern = '.fas$';
my $evalue = 1e-5;

# look for DNA files in dna_dir
my $dna_dir = '/home/formation/public_html/M2_Phylogenomique/data/Prochlorococcus/DNA';

opendir(my $rdir, $dna_dir) or die "Cannot open $dna_dir: $!";
my @file_list = grep /$pattern/, sort(readdir $rdir);
closedir $rdir;
if ( scalar @file_list == 0 ) {
	print STDERR "Error: no file $pattern found in  $dna_dir!\n";
	exit(1);
}
print scalar @file_list, " entries with $pattern suffix are found in $dna_dir\n";

my @ordered_genome = ('Aaab', 'Aaag', 'Aaaj', 'Aaaf', 'Aaak', 'Aaae', 'Aaai', 'Aaad', 'Aaaa', 'Aaah', 'Aaal', 'Aaac');
my $nb_genomes = scalar(@ordered_genome);

my($i, $query, $qfasta, $hit, $hfasta, $prefix, $outfile);
my($cmd, $workname, $sbatch_file, $sbatch_out, $sbatch_err);


foreach ($i=0;$i<$nb_genomes-1;$i++) {
	$query = $ordered_genome[$i];
	$qfasta = '/home/formation/public_html/M2_Phylogenomique/data/Prochlorococcus/DNA/' . $query . '.fas';
	if ( !-e $qfasta ) {
		print STDERR "Error; $qfasta is not found\n";
		exit(1);
	}
	$hit = $ordered_genome[$i+1];
	$hfasta = '/home/formation/public_html/M2_Phylogenomique/data/Prochlorococcus/DNA/' . $hit . '.fas';
	if ( !-e $hfasta ) {
		print STDERR "Error; $hfasta is not found\n";
		exit(1);
	}
	$prefix = $query . '_vs_' . $hit;
	print "$i $query vs $hit\n";
	$outfile  = 'BlastN/' . $prefix . '.tab';
	if ( -e $outfile ) {
		print "skip: $outfile is found.\n";
		next;
	}
	$cmd = "blastn -query $qfasta -subject $hfasta -evalue $evalue -outfmt 6 -num_threads 1 -out $outfile";
	print "$cmd\n";
	$workname = 'blastn_' . $prefix;
	$sbatch_file = $prefix . '.sh';
	$sbatch_out  = $prefix . '.out';
	$sbatch_err  = $prefix . '.err';
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
	print $SCRTFILE "module load bioinfo/ncbi-blast-2.6.0+\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}



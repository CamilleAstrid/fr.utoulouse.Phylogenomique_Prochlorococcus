#!/usr/bin/perl -w
# run prokka over a list of files

use strict;
use Cwd;

use Getopt::Long;

my $dna_dir_default = '/home/formation/public_html/M2_Phylogenomique/data/Prochlorococcus/DNA';
my %opts;
GetOptions( \%opts,
    'sample=s'
) || die "Error getting options! $!";

if ( scalar keys  %opts == 0 ) {
	print STDERR "Please provide a --sample Prochlorococcus\n";
	exit;
}
# look for DNA files in dna_dir
my $dna_dir = 'DNA';
if ( !-e $dna_dir ) {
	print STDERR "warning, $dna_dir is not found\n";
	$dna_dir = '/home/formation/public_html/M2_Phylogenomique/data/'.$opts{ sample }.'/DNA';
	if ( !-e $dna_dir ) {
		print STDERR "Error, $dna_dir is not found\n";
		exit(0);
	}
}
my $info_file = 'NCBI/species_strain_names.txt';
if ( !-e $info_file ) {
	print STDERR "warning, $info_file is not found\n";
	$info_file = '/home/formation/public_html/M2_Phylogenomique/data/'.$opts{ sample }.'/NCBI/species_strain_names.txt';
	if ( !-e $info_file ) {
		print STDERR "Error, $info_file is not found\n";
		exit(0);
	}
}

########################################################################
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
if ( !-e 'prokka' ){
	print STDERR "Error prokka subdirectory is expected!\n";
	exit;
}
print "user: $user hostname: $hostname\t$node\ncurrent directory: $cwd\n\n";


########################################################################
# DNA dir 

# parameters
my $pattern = '.fas$';
opendir(my $rdir, $dna_dir) or die "Cannot open $dna_dir: $!";
my @file_list = grep /$pattern/, sort(readdir $rdir);
closedir $rdir;
if ( scalar @file_list == 0 ) {
	print STDERR "Error: no file $pattern found in  $dna_dir!\n";
	exit(1);
}
print scalar @file_list, " entries with $pattern suffix are found in $dna_dir\n";

########################################################################
# file with code	kingdom genus	species	strain
open(my $fin, "$info_file") or die "Cannot open $info_file: $!";
my(@tmp);
my %info_dic =();
while(<$fin>) {
	chomp();
	@tmp = split("\t");
	$info_dic{$tmp[0]}{'kingdom'} = $tmp[1];
	$info_dic{$tmp[0]}{'genus'} = $tmp[2];
	$info_dic{$tmp[0]}{'species'} = $tmp[3];
	$info_dic{$tmp[0]}{'strain'} = $tmp[4];
}
close($fin);

# genome loop ##########################################################
my($query, $qprefix, $fasta, $outdir, $prokkadir, $locustag);
my($cmd, $prefix, $workname, $sbatch_file, $sbatch_out, $sbatch_err);

foreach $query (@file_list ) {
	if ( $query =~ /(\w+)$pattern/ ) {
		$qprefix = $1;
	} else {
		next;
	}
	
	$fasta = $dna_dir . '/' . $qprefix . '.fas';
	if ( !-e $fasta ) {
		print STDERR "Warning: $fasta is not found\n";
		$fasta = '/home/formation/public_html/M2_Phylogenomique/data/'.$opts{ sample }.'/DNA/' . $qprefix . '.fas';
		if ( !-e $fasta ) {
			print STDERR "Error: $fasta is not found\n";
			exit(1);
		}
	}
	print "genome: $qprefix\n";
	$outdir = 'prokka/'. $qprefix;
	if ( -e $outdir ) {
		print "skip: $outdir is found\n";
	} else {
		$prokkadir = 'prokka/' . $qprefix;
		$locustag  = $qprefix . '.g';
		if ( not defined $info_dic{$qprefix} ) {
			print STDERR "Error info not found for $qprefix!\n";
			exit(1);
		}
		print "$info_dic{$qprefix}{'species'}\n";
		
		$cmd = "prokka $fasta --outdir $prokkadir --compliant --addgenes --prefix $qprefix --locustag $locustag --genus $info_dic{$qprefix}{'genus'} --species '$info_dic{$qprefix}{'species'}' --strain '$info_dic{$qprefix}{'strain'}' --kingdom $info_dic{$qprefix}{'kingdom'} --cpus 1";
		print "$cmd\n";
		$prefix = 'prokka_' . $qprefix;
		$workname    = $prefix;
		$sbatch_file = $prefix . '.sh';
		$sbatch_out  = $prefix . '.out';
		$sbatch_err  = $prefix . '.err';
		run_script($sbatch_file, $workname, $sbatch_out, $sbatch_err, $cmd);
		print "sbatch file: $sbatch_file\n";
		`sbatch $sbatch_file`; 
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
	print $SCRTFILE '#SBATCH --time=00:20:00' .  "\n";
	print $SCRTFILE '#SBATCH --cpus-per-task=1' .  "\n";
	print $SCRTFILE "module purge\n";	 
	print $SCRTFILE "module load bioinfo/prokka-1.14.5\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}



#!/usr/bin/perl -w

use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'prokka_dir=s',
	'model=s',
	'verbose=i',
	'erase=i',
);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

print Dumper $pt_parameters if ( $pt_parameters->{'verbose'} > 1);
if ( not defined $pt_parameters->{'prokka_dir'} or not defined $pt_parameters->{'model'} ) {
	print STDERR "Error:\n";
	print STDERR "\t--prokka_dir not defined\n" if ( not defined $pt_parameters->{'prokka_dir'} );
	print STDERR "\t--model not defined\n" if ( not defined $pt_parameters->{'model'} );
	print STDERR "
usage:
$0 
	--prokka_dir  prokka directory with fna files
	--model       model(s) to search (ex. lsu,ssu,tsu)
	--verbose [0,1]
	--erase   [0,1]
\n";
	exit;
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

########################################################################
if ( !-e $pt_parameters->{'prokka_dir'} ) {
	print STDERR "Error: $pt_parameters->{'prokka_dir'} is not found: $!\n";
	exit(1);
}
print "user: $user hostname: $hostname\t$node\nprokka directory:$pt_parameters->{'prokka_dir'}\n\n";

# look for files in the current directory
opendir(my $rdir, $pt_parameters->{'prokka_dir'}) or die "Cannot open $pt_parameters->{'prokka_dir'}: $!";
my @file_list = grep /^[A-Z][a-z]{3}$/, sort(readdir $rdir);
closedir $rdir;
print scalar @file_list, " entries\n";

########################################################################

my($genome, $fasfile, $rnafile, $cmd, $prefix, $outfile, $workname, $sbatch_file, $sbatch_out, $sbatch_err);
foreach $genome (@file_list ) {
	print "$genome\n";
	$fasfile = $pt_parameters->{'prokka_dir'} . '/' . $genome . '/'. $genome . '.fna';
	if ( !-e $fasfile ) {
		print "skip: $fasfile is not found\n";
		next;
	}
	
	$rnafile = $pt_parameters->{'prokka_dir'} . '/' . $genome . '/'. $genome . '_' . $pt_parameters->{'model'} . '.rrna';
	if ( -e $rnafile && $pt_parameters->{'erase'} == 0) {
		print "skip: $rnafile\n";
	} else {
		$cmd = "rnammer -S bac -m $pt_parameters->{'model'} -f $rnafile < $fasfile";
		print "$cmd\n";
		$workname = 'rnammer_' . $genome;
		$sbatch_file = $pt_parameters->{'prokka_dir'} . '/' . $genome . '.sh';
		$sbatch_out  = $pt_parameters->{'prokka_dir'} . '/' . $genome . '.out';
		$sbatch_err  = $pt_parameters->{'prokka_dir'} . '/' . $genome . '.err';
		run_script($sbatch_file, $workname, $sbatch_out, $sbatch_err, $cmd);
		print "$sbatch_file\n";
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
	print $SCRTFILE '#SBATCH --time=00:5:00' .  "\n";
	print $SCRTFILE '#SBATCH --cpus-per-task=1' .  "\n";
	print $SCRTFILE "module purge\n";	 
	print $SCRTFILE "module load bioinfo/rnammer-1.2\n";	 
	print $SCRTFILE "$cmd\n";	 
	close($SCRTFILE);
}



#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my %command_line_parameters;
GetOptions(\%command_line_parameters,
	'gffdir=s',
	'output=s',
	'verbose=i',
	'erase=i',
	);
	
# parameters ###########################################################
my $pt_parameters = {} ;
$pt_parameters = \%command_line_parameters ;
$pt_parameters->{'verbose'}  = 0  if ( not defined $pt_parameters->{'verbose'} ); 
$pt_parameters->{'erase'}    = 0  if ( not defined $pt_parameters->{'erase'} ); 

print Dumper $pt_parameters if ( $pt_parameters->{'verbose'} > 1);
if ( not defined $pt_parameters->{'gffdir'} ) {
	print "--gffdir not defined\n" if ( not defined $pt_parameters->{'gffdir'} );
	print STDERR "\n
parse gff file created by prokka.
	
usage:\n
$0 
	--gffdir      directory with gff file
	--output      output file
	--verbose [0,1]
	--erase   [0,1]
\n";
	exit;
}
########################################################################
if ( !-e $pt_parameters->{'gffdir'} ) {
	print STDERR "Error: --gffdir $pt_parameters->{'gffdir'} is not found\n";
	exit(1);
}
my @tmp = split(/\//, $pt_parameters->{'gffdir'});
$pt_parameters->{'strain'} = $tmp[-1];
print "strain: $pt_parameters->{'strain'}\n";

my @gff_files = list_gff_files($pt_parameters->{'gffdir'}, $pt_parameters->{'strain'});
if (scalar @gff_files == 0 ) {
	print STDERR "Error: no gff file found\n";
	exit(1);
}

# read gff file ########################################################
my($gff, $file, @line, @info, $key, $label, $start);
my $pt_annotation = {};

my $strain = $pt_parameters->{'strain'};
my $chr = 1;
foreach $gff ( @gff_files ) {
	$file = $pt_parameters->{'gffdir'} . '/' . $gff;
	print "file $file\n";
	open(my $in, "$file") || die "Error, cannot open $file, $1\n";
	while(<$in>) {
		last if ( /^##FASTA/);
		next if ( /^##/);
		chomp();
		@line = split(/\t/);
		print "$line[0] $line[2] $line[3] $line[4] $line[6] $line[8]\n" if ( $pt_parameters->{'verbose'} > 1);
		if ( $line[2] eq 'CDS' ) {
			$start = $line[3];
			$pt_annotation->{$strain}{$chr}{$start}{'Type'}  = $line[2];
			$pt_annotation->{$strain}{$chr}{$start}{'Start'} = $line[3];
			$pt_annotation->{$strain}{$chr}{$start}{'End'}   = $line[4];
			$pt_annotation->{$strain}{$chr}{$start}{'Ori'}   = $line[6];
			@info = split(/;/, $line[8]);
			foreach (@info) {
				($key, $label) = split(/=/);
				$pt_annotation->{$strain}{$chr}{$start}{$key} = $label;
			}
		}
	}
	close($in);
	$chr++;
}
#~ print Dumper $pt_annotation;
my $data = '';
foreach $strain ( keys %$pt_annotation ) {
	foreach $chr ( sort{$pt_annotation->{$strain}{$a}<=>$pt_annotation->{$strain}{$b}} keys %{$pt_annotation->{$strain}} ) {
		print "$strain $chr\n";
		foreach $start ( sort{$pt_annotation->{$strain}{$chr}{$a}<=>$pt_annotation->{$strain}{$chr}{$b}} keys %{$pt_annotation->{$strain}{$chr}} ) {
			$data .= "$chr\t";
			$pt_annotation->{$strain}{$chr}{$start}{'locus_tag'} =~ s/^(\w{4})(\w{3}\.)/$1|$2/;
			#~ print "$pt_annotation->{$strain}{$chr}{$start}{'locus_tag'}\n";
			$data .= "$pt_annotation->{$strain}{$chr}{$start}{'locus_tag'}\t";
			$data .= "$pt_annotation->{$strain}{$chr}{$start}{'Start'}\t";
			$data .= "$pt_annotation->{$strain}{$chr}{$start}{'End'}\t";
			$data .= "$pt_annotation->{$strain}{$chr}{$start}{'Name'} " if ( defined $pt_annotation->{$strain}{$chr}{$start}{'Name'});
			$data .= "$pt_annotation->{$strain}{$chr}{$start}{'product'}\t";
			$data .= "$strain\n";
		}
	}
}
if ( defined $pt_parameters->{'output'} ) {
	open(my $out, ">$pt_parameters->{'output'}") || die "Error, cannot open $pt_parameters->{'output'}\n";
	print $out $data;
	close($out);
} else {
	print $data;
}
########################################################################
sub list_gff_files {
	my($chemin, $prefix) = @_;
	
	print "$chemin: $prefix\n";
	opendir(C, $chemin) or warn "Cannot open $chemin: $!";
	my @liste = grep /^$prefix.*\.gff$/, sort(readdir C);
	closedir C;
	(@liste);
}

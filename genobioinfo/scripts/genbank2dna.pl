#!/share/gsi2/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Bio::Species;
use Bio::Perl;
use Bio::SeqIO;
use Bio::Seq;
use Bio::DB::GenBank;
use Bio::Range;
use Bio::SeqIO::genbank;
use Bio::SeqFeature::Generic;
use Bio::DB::Query::GenBank;

########################################################################
use lib '/share/gsi2/perllib';
use GCA;

my $pt_options = [];
my ($filename)  = filename($pt_options);

my $usage = 
"\nExtract DNA from GenBank files. 

$filename
";

my($pt_parameters);
%$pt_parameters = ();

GetOptions($pt_parameters, @$pt_options);
if ($pt_parameters->{'help'} || scalar( keys %$pt_parameters) == 0 ) {
	usage($usage);
	exit;
}

if ($pt_parameters->{'help'} || scalar( keys %$pt_parameters) == 0 ) {
	usage($usage);
	exit;
}

if ( $pt_parameters->{'file'} eq '' ) {
	print $usage;
	exit;
}

########################################################################
$pt_parameters->{'verbose'} = 0;

########################################################################
my($nb_contig, $gbk_file, $gzip_gbk_file, $dna_file, $nsq_file, $seqio_object, $seq_object, $comd, $d1, $d2, $torun, $name);

# GenBank/DNA directory ################################################
($pt_parameters->{'gbkdir'}, $pt_parameters->{'prefix'}) = $pt_parameters->{'file'} =~ /^(.+)\/([\w\.]+)\.gbff\.gz$/;
;
if ( not defined $pt_parameters->{'gbkdir'} ) {
	print STDERR "$pt_parameters->{'file'}\n";
	print STDERR "Error: gbkdir not defined!\n";
	exit(1);
}
print "$pt_parameters->{'gbkdir'} $pt_parameters->{'prefix'}\n" if ( $pt_parameters->{'verbose'} > 0 );

$pt_parameters->{'dnadir'} = $pt_parameters->{'gbkdir'};
$pt_parameters->{'dnadir'} =~ s/GenBank/DNA/;

if ( !-e $pt_parameters->{'dnadir'} ) {
	print "$pt_parameters->{'dnadir'} is not found, mkdir $pt_parameters->{'dnadir'}\n" if ( $pt_parameters->{'verbose'} > 0 );
	if ( `mkdir -p $pt_parameters->{'dnadir'}` ) {
		print STDERR "Error: cannot create $pt_parameters->{'dnadir'}!\n";
		exit;
	}
} else {
	print "$pt_parameters->{'dnadir'} is found\n" if ( $pt_parameters->{'verbose'} > 0 );
}

# GenBank file #########################################################

$gbk_file = $pt_parameters->{'gbkdir'} . '/' . $pt_parameters->{'prefix'} . '.gbff';
if ( !-e $pt_parameters->{'file'} ) {
	print STDERR "Error: $pt_parameters->{'file'} not found\n";
	exit;
}
`gzip -fd $pt_parameters->{'file'}`;
		
# test number of contigs ###########################################
$nb_contig = `grep -c LOCUS $gbk_file`;
chomp($nb_contig);
print "nb contigs: ", $nb_contig, "\n" if ( $pt_parameters->{'verbose'} > 0 );

if ( $nb_contig > 2600) {
	print STDERR "Error: number of contigs $nb_contig > 2600\n";
	`gzip -f $gbk_file`;
	exit;
}

my $concat_dna_file = $pt_parameters->{'dnadir'} . '/' . $pt_parameters->{'prefix'} . '.fas';
print "concat_dna_file\n" if ( $pt_parameters->{'verbose'} > 0 );
my $genome_dna_dir = $pt_parameters->{'dnadir'} . '/' . $pt_parameters->{'prefix'};
if ( !-e $genome_dna_dir ) {
	print "$genome_dna_dir not found, mkdir $genome_dna_dir\n" if ( $pt_parameters->{'verbose'} > 0 );
	mkdir($genome_dna_dir);
}
print "genome dna dir: $genome_dna_dir\n" if ( $pt_parameters->{'verbose'} > 0 );

print "$pt_parameters->{'prefix'} $gbk_file\n" if ( $pt_parameters->{'verbose'} > 0 );
$seqio_object = Bio::SeqIO->new(-file => "$gbk_file",
	-format => 'Genbank', -verbose => -1);
	  
my($num, $step, $id_contig, $car, $suffix, $dna_out);
my $pt_maj =[];
@$pt_maj = ("A" .. "Z");
$num = 0;
unlink($concat_dna_file) if ( -e $concat_dna_file);

#~ # contig loop ##################################################
while ($seq_object = $seqio_object->next_seq ) {
	my @definition = $seq_object->desc();
	if ( grep(/plasmid/, @definition) ) { #plasmid
		print "warning : @definition\n";
	}
	$id_contig = $seq_object->accession_number() . '.' . $seq_object->seq_version;
	$step = $num%100;
	$car = $pt_maj->[int($num/100)] if ( $step == 0 );
	$suffix = sprintf("$car%02s", $step+1);
	$name = $pt_parameters->{'prefix'} . $suffix;

	print "$num\t$name\t$id_contig\n"  if ( $pt_parameters->{'verbose'} > 0 );
	
	$dna_file = $genome_dna_dir . '/' . $name . '.fas';
	$dna_out = Bio::SeqIO->new(
		-file=>">$dna_file",
		-format=>'fasta');
	$seq_object->display_id($name);
	$dna_out->write_seq($seq_object);
	print "dna_file $dna_file\n" if ( $pt_parameters->{'verbose'} > 0 );
	$num++;
	`cat $dna_file >> $concat_dna_file`;
	if ( $num > 2600) {
		print STDERR "Error: $num > 2600\n";
		`gzip -f $gbk_file`;
		exit;
	}
	
}

# makeblastdb ##################################################
#~ if ( -e $concat_dna_file ) {
	#~ $nsq_file = $concat_dna_file . '.nsq';
	#~ $comd = "/share/gsi2/bin/formatdb -i $concat_dna_file -p F -o T";
	#~ $comd = "/share/gsi2/bin/makeblastdb -in $concat_dna_file -dbtype nucl -title $name";
	#~ print "$comd\n" if ( $pt_parameters->{'verbose'} > 0 );
	#~ system ($comd);
#~ }	
`gzip -f $gbk_file`;


########################################################################
sub filename {
	my($pt_options) = @_;

	my $usage = " 
      --file     str     GB file 
    ";
	push(@$pt_options, ('file=s'));
	($usage);
}

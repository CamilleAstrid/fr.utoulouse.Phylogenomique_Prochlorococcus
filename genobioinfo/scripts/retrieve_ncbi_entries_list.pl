#!/usr/bin/perl -w

use strict;

use DateTime;
use DateTime::Format::Strptime;
use Bio::DB::Taxonomy;
use Bio::Tree::Tree;

my $pt_options = [];
my ($retrieve_entries_list)  = retrieve_entries_list($pt_options);
my ($erase_verbose)          = erase_verbose($pt_options);

my $usage = 
"\nList available strains at NCBI ftp server. 

$retrieve_entries_list
$erase_verbose

$0 --directory /var/www/html/soap-data/REP/Pseudomonas --database  REPPseudo --entries NC_007492.2 --parameters /var/www/html/soap-data/REP/Pseudomonas/annot_w_blast_PF.par --erase 0 -verbose 1
";

my($pt_parameters) = REP::init_parameters($usage, @$pt_options);
$pt_parameters->{'NCBI_genome_reports'} = '/share/gsi2/data/www/soap-data/NCBI_genome_reports';
$pt_parameters->{'group'}    = '' if ( not defined $pt_parameters->{'group'} );
$pt_parameters->{'subgroup'} = '' if ( not defined $pt_parameters->{'subgroup'} );
$pt_parameters->{'organism'} = '' if ( not defined $pt_parameters->{'organism'} );
$pt_parameters->{'species'}  = '' if ( not defined $pt_parameters->{'species'} );
$pt_parameters->{'status'}   = '' if ( not defined $pt_parameters->{'status'} );
$pt_parameters->{'rank'}     = '' if ( not defined $pt_parameters->{'rank'} );
$pt_parameters->{'accession'}= '' if ( not defined $pt_parameters->{'accession'} );

my $analyseur = DateTime::Format::Strptime->new( pattern => '%Y/%m/%d' );
my $today = DateTime->today(); 

# test parameters ######################################################
if ( ( $pt_parameters->{'species'} eq '' && $pt_parameters->{'organism'} eq '' && $pt_parameters->{'group'} eq ''  && $pt_parameters->{'subgroup'} eq '' && $pt_parameters->{'accession'} eq '' ) || $pt_parameters->{'directory'} eq '' || $pt_parameters->{'erase'} !~ /[01]/ ) {
	print $usage;
	exit;
}

# $pt_parameters->{'ncbidir'} is defined in REP.pm as $pt_parameters->{'directory'} . '/GenBank';
my($prokaryote_list, $prokaryote_log);
if ( !-e $pt_parameters->{'ncbidir'} ) {
	mkdir($pt_parameters->{'ncbidir'});
}
chdir($pt_parameters->{'ncbidir'});

my $pt_labels = genome_labels();
my @labels =  sort keys %$pt_labels;
#~ print join(' ', @labels), "\n";
my $prefix = '';
if ( $pt_parameters->{'accession'}) {
	 $prefix = 'accession';
 } else {
	my @prefix = split(/\W+/, $pt_parameters->{'group'});
	push(@prefix, split(/\W+/, $pt_parameters->{'subgroup'})) if ( defined $pt_parameters->{'subgroup'} );
	push(@prefix, split(/\W+/, $pt_parameters->{'rank'}))     if ( defined $pt_parameters->{'rank'} );
	push(@prefix, split(/\W+/, $pt_parameters->{'species'})) if ( defined $pt_parameters->{'species'} );
	push(@prefix, split(/\W+/, $pt_parameters->{'status'}))   if ( defined $pt_parameters->{'status'} );
	$prefix = join('_', @prefix);
}
print "prefix of the outfile: $prefix\n";
my $unchange_file = $pt_parameters->{'ncbidir'} . '/' . $prefix . '_labels_file.lst';
my $update_file   = $pt_parameters->{'ncbidir'} . '/' . $prefix . '_update_file.lst';
my $new_file      = $pt_parameters->{'ncbidir'} . '/' . $prefix . '_new_file.lst';

$prokaryote_list = $pt_parameters->{'NCBI_genome_reports'} . '/prokaryotes.txt';
$prokaryote_log  = $pt_parameters->{'NCBI_genome_reports'} . '/prokaryotes.log';

# ftp the strain table #################################################
#unlink($prokaryote_list);
#~ if ( !-e $prokaryote_list || $pt_parameters->{'erase'} == 1 ) {
	#~ unlink($prokaryote_list);
	#~ my $cmd = `wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt -O $prokaryote_list -o $prokaryote_log -nv -r`;
#~ }

if ( !-e $prokaryote_list ) {
	print STDERR "Error in download, $prokaryote_list not found\n";
	exit;
}
print "$prokaryote_list OK\n" if ( $pt_parameters->{'verbose'} > 1 );
open(FILE, "$prokaryote_list") || die "Error: cannot open $prokaryote_list\n";

my(@columns, $ftp_filegz, $gbk_file, $gbk_filegz, $date, $NCBIdt, $cmp, $LOCALdt);
my($update, $unchange, $new, $short, $found, $hit);
$unchange = 0;
$update = 0;
$found = 0;
$short = 0;
$new = 0;

my(@local_list, %hit);

(@local_list) = REP::list_files($pt_parameters->{'ncbidir'}, 'gbk');
foreach (@local_list) {
		$hit{$_} = 0;
}

my @group_list    = ();
my @subgroup_list = ();
my @organism_list = ();
my @species_list  = ();
my @status_list   = ();
my @rank_list     = ();
my @accession     = ();
@group_list    = split(/\W+/, $pt_parameters->{'group'})       if ( defined $pt_parameters->{'group'} );
@subgroup_list = split(/\W+/, $pt_parameters->{'subgroup'})    if ( defined $pt_parameters->{'subgroup'} );
@organism_list = split(/, */, $pt_parameters->{'organism'})    if ( defined $pt_parameters->{'organism'} );
@species_list  = split(/, */, $pt_parameters->{'species'})     if ( defined $pt_parameters->{'species'} );
@status_list   = split(/, */, $pt_parameters->{'status'})      if ( defined $pt_parameters->{'status'} );
@rank_list     = split(/, */, $pt_parameters->{'rank'})        if ( defined $pt_parameters->{'rank'} );
@accession     = split(/, */, $pt_parameters->{'accession'})   if ( defined $pt_parameters->{'accession'} );
print "read $prokaryote_list\n";
print join(',', @group_list), "\n";

#0 Organism/Name	1 TaxID	2 BioProject Accession	3 BioProject ID	4 Group	5 SubGroup	6 Size (Mb)	7 GC%	8 Chromosomes/RefSeq	9 Chromosomes/INSDC	10 Plasmids/RefSeq	11 Plasmids/INSDC	12 WGS	13 Scaffolds	14 Genes	15 Proteins	16 Release Date	17 Modify Date	18 Status	20 Center	21 BioSample 22 Accession	23 Assembly 24 Accession	25 Reference

#0 Organism/Name	1 TTaxID	2 BioProject Accession	3 BioProject ID	4 Group	5 SubGroup	6 Size (Mb)	7 GC%	8 Replicons	9 WGS	10 Scaffolds	11 Genes	12 Proteins	13 Release Date	14 Modify Date	15 Status	16 Center	17 BioSample Accession	18 Assembly Accession	19 Reference	20 FTP Path	21 Pubmed ID	22 Strain

# http://0-www.ncbi.nlm.nih.gov.elis.tmu.edu.tw/Traces/wgs/?download=AXUO01.gbff.1.gz
my %genome_label = ();
my %label_genome = ();
my $nextlabel = 0;
if ( -e $unchange_file && -s $unchange_file > 0 ) {
	open('UNCHANGE', "$unchange_file") || die "Error cannot open $unchange_file\n";
	while(<UNCHANGE>) {
		my @tmp = split(/\s+/);
		if ( defined $label_genome{$tmp[1]} ) {
			print STDERR "$tmp[1] $label_genome{$tmp[1]} not unique!\n";
			exit;
		}
		$genome_label{$tmp[0]} = $tmp[1] if ( $tmp[1]);
		$label_genome{$tmp[1]} = $tmp[0] if ( $tmp[1]);
	}
	close(UNCHANGE);
	my @tmp = sort keys %label_genome;
	my @index_containing_o = grep { $labels[$_] =~ $tmp[-1] } 0..$#labels;
	print @index_containing_o, "\n";
	$nextlabel = $index_containing_o[-1];
}

open('UNCHANGE', ">$unchange_file") || die "Error cannot open $unchange_file\n";
open('UPDATE', ">$update_file") || die "Error cannot open $update_file\n";
open('NEW', ">$new_file") || die "Error cannot open $new_file\n";

my $db = Bio::DB::Taxonomy->new(-source => 'entrez');
my $pt_rank_passed = {};

while(<FILE>) {
		chomp();
		next if (/^\#/);
		@columns = split(/\t+/);

		$found = 0;
		foreach ( @group_list ) {
			#~ print "$columns[0]\t$columns[18]\tRefSeq $columns[8]\tWGS $columns[12]\n" if ( index($columns[0], $_, 0 ) >= 0 );
			$found = 1 if ( index($columns[4], $_, 0 ) >= 0 ) ;
		}
		foreach ( @subgroup_list ) {
			#~ print "$columns[0]\t$columns[18]\tRefSeq $columns[8]\tWGS $columns[12]\n" if ( index($columns[0], $_, 0 ) >= 0 );
			$found = 1 if ( index($columns[5], $_, 0 ) >= 0 ) ;
		}
		foreach ( @organism_list ) {
			#~ print "$columns[0]\t$columns[18]\tRefSeq $columns[8]\tWGS $columns[12]\n" if ( index($columns[0], $_, 0 ) >= 0 );
			$found = 1 if ( index($columns[0], $_, 0 ) >= 0 ) ;
		}
		foreach ( @species_list ) {
			#~ print "$columns[0]\t$columns[18]\tRefSeq $columns[8]\tWGS $columns[12]\n" if ( index($columns[0], $_, 0 ) >= 0 );
			$found = 1 if ( index($columns[0], $_, 0 ) >= 0 ) ;
		}
		foreach ( @accession ) {
			#~ print "$columns[0]\t$columns[18]\tRefSeq $columns[8]\tWGS $columns[12]\n" if ( index($columns[0], $_, 0 ) >= 0 );
			$found = 1 if ( index($columns[8], $_, 0 ) >= 0 ) ;
		}
		#~ print "$columns[9]\n";
		# line is selected #############################################
		if ( $found ) {
			$hit = 1;
			
			if ( scalar @status_list > 0 ) {
				$hit = 0; 
				foreach (@status_list) { 
					#~ print "$columns[15] $_\n";
					$hit = 1 if ( index($columns[15], $_, 0 ) >= 0 );
				}
			}
			
			# line has expected status #################################
			if( $hit ) {
				print "$columns[0]\t\|\t$columns[1]\t$columns[4]\t$columns[5]\t$columns[15]\n" if ( $pt_parameters->{'verbose'} > 0 );
				#~ print join("\t", @columns), "\n" if ( $pt_parameters->{'verbose'} > 1 );
				#~ # use NCBI Entrez over HTTP
								
				# Modify Date
				if ( $columns[17] =~ /^(\w+)/ ) {
  					$NCBIdt = $analyseur->parse_datetime($columns[14]);
  					print "\tNCBI ", $NCBIdt->ymd,  "\n" if ( $pt_parameters->{'verbose'} > 1 );
  				}
  				
   				# FTP Path #############################################
  				$gbk_file = '';
  				$ftp_filegz = '';
  				if ( $columns[20] =~ /ftp/ ) {
					my @tmp = split('/', $columns[20]);
					$ftp_filegz = $columns[20] . '/' . $tmp[-1] . '_genomic.gbff.gz';
					$gbk_file = $tmp[-1] . '_genomic.gbff';
					$gbk_filegz = $gbk_file . '.gz';
					print "FTP Path: $gbk_filegz\n" if ( $pt_parameters->{'verbose'} > 1 );
				}
				
				# or alternative format  ###############################
				if ( $gbk_file eq '') {
					# RefSeq
					if ( $columns[8] =~ /[A-Zaz]/ ) {
						$gbk_file = $pt_parameters->{'ncbidir'} . '/' . $columns[8] . '.gbk';
						$short = $columns[8];
						if ( $short eq 'NC_004337.1' ) {
							$short = 'NC_004337.2';
							$gbk_file = $pt_parameters->{'ncbidir'} . '/' . $short . '.gbk';
						}
						$gbk_filegz = $gbk_file . '.gz';
					}
					# INSDC
					if ( ( $gbk_file eq '' || (!-e $gbk_file && !-e $gbk_filegz) ) && $columns[9] =~ /^(\w+)/ ) { 
						($short) = $columns[9] =~ /^(\S+)/;
						$gbk_file = $pt_parameters->{'ncbidir'} . '/' . $short . '.gbk';
						$gbk_filegz = $gbk_file . '.gz';
					}
					# WGS
					if ( ( $gbk_file eq '' || (!-e $gbk_file && !-e $gbk_filegz) ) && $columns[12] =~ /^(\w+)/ ) { 
						($short) = $columns[12] =~ /^(\S+)/;
						$gbk_file = $pt_parameters->{'ncbidir'} . '/' . $short . '.gbff.1';
						$gbk_filegz = $gbk_file . '.gz';
					}
				}
				next if ( $gbk_file eq '');
				
				# tester si le fichier exist dans le repertoire local ##
				# si oui tester, si c'est une update
				if ( -e $gbk_file || -e $gbk_filegz ) { 
					$gbk_file = $gbk_filegz if ( -e $gbk_filegz );
					#print "$columns[0]\t$columns[7]\t$columns[8]\t$columns[15]\t$columns[16]\t$columns[17]\n";
					$hit{"$short.gbk"} = 1;
					print "$gbk_file is found\n" if ( $pt_parameters->{'verbose'} > 0 );
					my (@info) = stat($gbk_file);
					my $LOCALdt = DateTime->from_epoch( epoch => $info[10] );
					if ( ($columns[8] =~ /\w+/ || $columns[9] =~ /\w+/ || $columns[12] =~ /\w+/) && $NCBIdt ) {
 						$cmp = DateTime->compare($NCBIdt, $LOCALdt);
 						if ( $cmp > 0 ) {
 							print "\tUPDATE available" if ( $pt_parameters->{'verbose'} > 1 );
  							print "\tLOCAL date (", $LOCALdt->ymd,  ")" if ( $pt_parameters->{'verbose'} > 1 );
  							print "\tNCBI date (", $NCBIdt->ymd,  ")" if ( $pt_parameters->{'verbose'} > 1 );
  							$update++;
							if ( $columns[20] =~ /ftp/ ) {
								print UPDATE "$ftp_filegz\n";
							} elsif ( $columns[8] =~ /\w+/ ) {
								print UPDATE "$columns[8]\n";
							} elsif ( $columns[9] =~ /\w+/ ) {
								print UPDATE "$columns[9]\n";
							} else {
								print UPDATE "$columns[12]\n";
							}
						} else {
							$unchange++;
						}
						if ( $columns[20] =~ /ftp/ ) {
							my $label = '';
							if ( defined $genome_label{$gbk_filegz} ) {
								$label = $genome_label{$gbk_filegz};
							} else {
								$label = $labels[$nextlabel];
								$nextlabel++;
							}
							print UNCHANGE "$gbk_filegz\t$label\t$pt_labels->{$label}\n";
						}
					} else {
						print "8$columns[8]\t9$columns[9]\tNCBIdt$NCBIdt\n";
						
					}
					print "\n" if ( $pt_parameters->{'verbose'} > 1 );
				} else {
					
					my $ok = 1; 
					if ( $pt_parameters->{'rank'} ne "" ) {
						my(@tmp) = split(" ", $columns[0]);
						my $name = $tmp[0] . ' ' . $tmp[1];
						$name = $tmp[0] . ' ' . $tmp[1];
						$name =~ s/[^A-Za-z ]//g;
						if ( not defined $pt_rank_passed->{$name} ) {
							$ok = 0; 
							my $taxonid = $db->get_taxonid($name);
							if ( $taxonid =~ /\d+/ ) {
								#~ my @taxonids = ("515482", "515474");
								my $taxon = $db->get_taxon(-taxonid => $taxonid);
								my $tree = Bio::Tree::Tree->new(-node => $taxon);
								my @taxa = $tree->get_nodes;
								my @tids = ();
								foreach my $t (@taxa) {
									push(@tids, $t->scientific_name());
								}
								foreach my $rank ( @rank_list ) {
									$ok = 1 if ( grep /$rank/, @tids );
								}
								print $ok, "\t", $taxonid, "\t|\t", $taxon->scientific_name(), join("\t", @tids), "\n" if ( $pt_parameters->{'verbose'} > 0 );
								$pt_rank_passed->{$name}= 1;
							} else {
								print STDERR "Error: $name Not hit in entrez\n";
							}
							print "get_taxonid of: $name retained:$ok\n";
						}
					}
					next if ( $ok == 0 );
					print "$pt_parameters->{'ncbidir'}/$gbk_file not found!\n" if ( $pt_parameters->{'verbose'} > 0 );
					if ( $columns[8] =~ /\w+/ || $columns[9] =~ /\w+/ || $columns[12] =~ /^(\w+)/) {
 						print ">>>NEW $columns[0]\t$columns[8]\t$columns[9]\t$columns[16]\t$columns[17]\t$columns[18]\n" if ( $pt_parameters->{'verbose'} > 1 );
 						$new++;
   						if ( $columns[20] =~ /ftp/ ) {
 							print NEW "$ftp_filegz\n";
						} elsif ( $columns[8] =~ /\w+/ ) {
 							print NEW "$columns[8]\n";
						} elsif ( $columns[9] =~ /\w+/ ) {
 							print NEW "$columns[9]\n";
						} elsif ( $columns[12] =~ /\w+/ )  {
 							print NEW "$columns[12]\n";
						} else {
							print STDERR "error: with @columns\n";
							exit;
						}
						
						if ( $columns[20] =~ /ftp/ ) {
							my $label = '';
							if ( defined $genome_label{$gbk_filegz} ) {
								$label = $genome_label{$gbk_filegz};
							} else {
								$label = $labels[$nextlabel];
								$nextlabel++;
							}
							print UNCHANGE "$gbk_filegz\t$label\t$pt_labels->{$label}\n";
						}
					}
				}
			} else {
				#~ print "skip: not expected status, look at status syntax!\n";
			}
		}
}
close(FILE);
close(UPDATE);
close(UNCHANGE);
close(NEW);

print STDERR "\nunchange $unchange\tupdate $update\tnew $new\n";
if ( $pt_parameters->{'verbose'} > 1 ) {
	print STDERR "\nlocal list\n";
	if ( scalar ( keys %hit) > 0 ) {
		print STDERR "\nNot found any more!\n";
		foreach (sort keys %hit) {
			print STDERR "$_\n" if ( $hit{$_} == 0);
		}
	}
}
print "$unchange_file\n";
print "$update_file\n";
print "$new_file\n";

########################################################################
sub genome_labels {
	
	my @maj = ("A" .. "Z");
	my @min = ("a" .. "z");
	my $pt_prefix = {};
	my $num = 1;
	for (my $i=0; $i<26; $i++ ) {
		for (my $j1=0; $j1<26; $j1++ ) {
			for (my $j2=0; $j2<26; $j2++ ) {
				for (my $j3=0; $j3<26; $j3++ ) {
					$pt_prefix->{"$maj[$i]$min[$j1]$min[$j2]$min[$j3]"} = $num;
					$num++;
				}
			}
		}
	}
	($pt_prefix);
}
#########################################################################
sub retrieve_entries_list {
	my($pt_options) = @_;

	my $usage = " 
      --directory    str     root directory of the project,
      --group        str     list of groups (Euryarchaeota, Crenarchaeota, TACK, DPANN, Asgard, Archaea)
      --subgroup     str     list of subgroups (rchae)
      --rank         str     optional, list of tanonomy rank (Enterobacterales)
      --organism     str     list of organisms (Pseudomonas)
      --species      str     list of species (Pseudomonas)
      --status       str     list of sequencing status (Complete, Scaffolds or contigs) 
      --accession    str     list of accession 
    ";
	push(@$pt_options, ('directory=s', 'group=s', 'subgroup=s', 'rank=s', 'organism=s', 'species=s', 'status=s', 'accession=s'));
	($usage);
}
#########################################################################
sub erase_verbose {
	my($pt_options) = @_;

	my $usage = "      
      --verbose      int     toggle [01] print messages
      --erase        int     toggle [01] erase previous run results
    ";
	push(@$pt_options, ('verbose=i', 'erase=i', 'help'));
	($usage);
}

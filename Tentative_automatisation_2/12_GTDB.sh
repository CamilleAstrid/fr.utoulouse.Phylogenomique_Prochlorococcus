#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# GTDB

wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_taxonomy.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz
gzip -d ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz

# Recouper la taxonomie avec les groupes obtenus avec grrasp.
awk '{
for (i = 4; i <= NF; i++) {
  split($4, a, ",")
  for (j in a) {
  printf "%s\t%s\t%i\n", substr(a[j],2,10), a[j], $2
  }
}
}' ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.table.txt > ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.groups_ACsuffix.txt

awk '{print substr($1,7,10)"\t"$_}' ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv > ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix.txt

join -t $'\t' -1 1 -2 1 -o auto <(sort ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.groups_ACsuffix.txt) <(sort  ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix.txt) > ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt

sed s'/;/\t/g' -i ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt

# Compilation des associations
cut -f3,10 ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt | sort -k2 | uniq -c

wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_metadata.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

gzip -d ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

tail -n+2 ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv | sort -t $'\t' -k 53  > ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv 

cut -f3 ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst

sort -t $'\t' -k 1  ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst 

join -t $'\t' -1 53 -2 1 -o 1.1,2.1,1.16 1.17 1.18 1.19 1.20 ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst > ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

sed s'/;/\t/g' -i ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

awk 'BEGIN {printf "DATASET_COLORSTRIP\nSEPARATOR TAB\n"
printf "DATASET_LABEL\tGenera\nLEGEND_COLORS\t#990000\t#bf9000\t#38761d\t#0b5394\t#c27ba0\t#e06666\t#f4cccc\t#fff2cc\t#d0e0e3\t#d9d2e9\n"
printf "LEGEND_SHAPES\t1\t1\t1\t1\t1\t1\t1\t1\t1\t1\n"
printf "LEGEND_LABELS\tg__Prochlorococcus\tg__Prochlorococcus_A\tg__Prochlorococcus_B\tg__Prochlorococcus_C\tg__Prochlorococcus_D\tg__Prochlorococcus_E\tg__MIT-1300\tg__AG-402-N21\tg__AG-363-P08\tg__AG-363-K07\nDATA\n"}
{
COL="#ffffff"
if($10=="g__Prochlorococcus") COL="#990000"
if($10=="g__Prochlorococcus_A") COL="#bf9000"
if($10=="g__Prochlorococcus_B") COL="#38761d"
if($10=="g__Prochlorococcus_C") COL="#0b5394"
if($10=="g__Prochlorococcus_D") COL="#c27ba0"
if($10=="g__Prochlorococcus_E") COL="#e06666"
if($10=="g__MIT-1300") COL="#f4cccc"
if($10=="g__AG-402-N21") COL="#fff2cc"
if($10=="g__AG-363-P08") COL="#d0e0e3"
if($10=="g__AG-363-K07") COL="#d9d2e9"
printf "%s\t%s\t%s\n",  $2, COL, $15
}' ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt > ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group_genera_iTOL.txt

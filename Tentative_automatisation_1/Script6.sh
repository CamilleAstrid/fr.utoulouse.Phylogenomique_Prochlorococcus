#!/bin/bash

module load bioinfo/Mash/2.3
cpu=10

mash dist  -p $cpu ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh > ~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt

R --slave <<-EOF
library(tidyverse)
library(ggplot2)

Prochlo.Mash.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt"
Mash.colnames <- c("Query", "Hit", "Distance", "Pvalue", "Ratio")
Prochlo.Mash <- read.table(Prochlo.Mash.file, sep = "\t", quote = "", header = F, col.names=Mash.colnames, stringsAsFactors = T, skipNul=T)

## Mash_id_distribution
pdf_file <- '~/work/Prochlorococcus/RefSeq/MashProchlo/Mash_id_distribution.pdf'
pdf(file=pdf_file, paper="a4r")

Prochlo.Mash %>%
  ggplot( aes(x=(1-Distance)*100)) +
    geom_histogram(binwidth=1, fill="coral", col="coral", alpha=0.8) +
    ggtitle("Bin size = 1 %") +
    geom_vline(xintercept=95, col="red", alpha=0.5) + 
    theme_bw() +
    theme(
      plot.title = element_text(size=15)
    )
dev.off()


Prochlo.Mash.matrix <- Prochlo.Mash %>% 
  mutate(Query=substr(Query,55, 67)) %>% 
  mutate(Hit=substr(Hit,55, 67)) %>% 
  pivot_wider(id_cols=Query, names_from=Hit, values_from = "Distance")

Prochlo.Mash.matrix.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt"

write.table(Prochlo.Mash.matrix, file=Prochlo.Mash.matrix.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = TRUE)

q()
y

EOF

head -n 2 ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt

cd ~/work
git clone https://github.com/JCVenterInstitute/GGRaSP.git

R --slave <<-EOF
install.packages("getopt")
33
install.packages("ggrasp")
33
q()
y

EOF

~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp --writetable --writeitol --writetree --plothist --plotgmm --plotclus


R --slave <<-EOF
if (!require('kableExtra')) {install.packages('kableExtra')}
33
if (!require('tidyverse')) {install.packages('tidyverse')}
33
if (!require('ggplot2')) {install.packages('ggplot2')}
33

library(kableExtra)
library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 3,15))

medoids.file <- "~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.txt"

medoids <- read.table(medoids.file, sep = "\t", quote = "", col.names=c("Medoid"))

medoids.properties <- left_join(medoids, prochlo.refseq.genomes.clean, by = join_by(Medoid == assembly_accession))

kable(medoids.properties %>% 
  select(c(Medoid, infraspecific_name, assembly_level, scaffold_count)), 
  caption="Table 1 : Propriétés des médoïdes") %>%
  save_kable("~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.properties.txt")


Prochlo.CheckM.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv"
Prochlo.CheckM <- read.table(Prochlo.CheckM.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

Prochlo.CheckM <- Prochlo.CheckM %>% 
  mutate(Name=substr(Name, 3,15))

Prochlo.IQ <- Prochlo.CheckM %>% 
  filter(Completeness>99) %>%
  filter(Contamination<0.7)

Prochlo.CheckM.Quality <- Prochlo.IQ %>% 
  mutate(Quality = round(sqrt( (1 - Completeness/100)^2 + (Contamination)^2),  digits = 4 )) %>% 
  arrange(Quality) %>% 
  select(Name, Quality)

Prochlo.CheckM.Quality.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt"

write.table(Prochlo.CheckM.Quality, file=Prochlo.CheckM.Quality.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = FALSE)

q()
y

EOF

~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ --writetable --writeitol --writetree --plothist --plotgmm --plotclus  -r ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt

R --slave <<-EOF

library(kableExtra)
library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)
prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 3,15))
  
medoids.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.medoids.txt"
medoids <- read.table(medoids.file, sep = "\t", quote = "", col.names=c("Medoid"))

medoids.properties <- left_join(medoids, prochlo.refseq.genomes.clean, by = join_by(Medoid == assembly_accession))
table <- kable(medoids.properties %>% 
  select(c(Medoid, infraspecific_name, assembly_level, scaffold_count)), 
      caption="Table 2 : Propriétés des médoïdes filtrés en fonction de leur qualité de séquençage")
table %>%
    save_kable("~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.properties.quality-sort.txt")

q()
y

EOF

wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_taxonomy.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz
gzip -d ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz

awk '{
for (i = 4; i <= NF; i++) {
  split($4, a, ",")
  for (j in a) {
  printf "%s\t%s\t%i\n", substr(a[j],2,10), a[j], $2
  }
}
}' ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.table.txt > ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.groups_ACsuffix.txt
wc -l ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.groups_ACsuffix.txt

awk '{print substr($1,7,10)"\t"$_}' ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv > ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix.txt

join -t $'\t' -1 1 -2 1 -o auto <(sort ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.groups_ACsuffix.txt) <(sort  ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix.txt) > ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt
wc -l ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt

sed s'/;/\t/g' -i ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt

cut -f3,10 ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt | sort -k2 | uniq -c

wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_metadata.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

gzip -d ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

tail -n+2 ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv | sort -t $'\t' -k 53  > ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv 

cut -f3 ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst

sort -t $'\t' -k 1  ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst 

join -t $'\t' -1 53 -2 1 -o 1.1,2.1,1.16 1.17 1.18 1.19 1.20 ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst > ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

wc -l ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

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


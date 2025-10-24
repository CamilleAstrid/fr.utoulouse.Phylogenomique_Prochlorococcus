# Atelier Phylogénomique
# Introduction

Yves Quentin & Gwennaele Fichant

2025-10-07

## Références
* Kettler et al., PLoS Genet. 2007 Dec;3(12):e231 Patterns and implications of gene gain and loss in the evolution of ‘’Prochlorococcus’’.
* Sun and Blanchard, 2014 Strong Genome-Wide Selection Early in the Evolution of Prochlorococcus Resulted in a Reduced Genome through the Loss of a Large Number of Small Effect Genes
* Yan et al., Appl Environ Microbiol. 2018 Genome rearrangement shapes ‘’Prochlorococcus’’ ecological adaptation.
* Yan et al., mBio 2022 Diverse Subclade Differentiation Attributed to the Ubiquity of Prochlorococcus High-Light-Adapted Clade II
* Biller et al., Nat. Rev. Microbiol. 2015 13(1) 13-27 ‘’Prochlorococcus’’: the structure and function of collective diversity.
* Partensky and Laurence Garczarek Annual Review of Marine Science 2010 Prochlorococcus: Advantages and Limits of Minimalism.
* Tschoeke et al., 2020 Unlocking the Genomic Taxonomy of the Prochlorococcus Collective.
* Zhang et al., 2021 Snowball Earth, population bottleneck and Prochlorococcus evolution.
* Yan et al., 2022 Diverse Subclade Differentiation Attributed to the Ubiquity of Prochlorococcus High-Light-Adapted Clade II.
* Ribalet et al., 2025 Future ocean warming may cause large reductions in Prochlorococcus biomass and productivity
* [Prochlorococcus](https://www.cell.com/current-biology/fulltext/S0960-9822(17)30213-0?code=cell-site) ‘’Prochlorococcus’’.
* [Cyanorak Information system](http://application.sb-roscoff.fr/cyanorak/welcome.html)

## Logiciels à installer sur vos postes de travail
* [seaview](http://doua.prabi.fr/software/seaview) : Multiplatform GUI for molecular phylogeny
* [mauve](http://darlinglab.org/mauve/mauve.html) : Multiple genome alignment
* [splitstree](https://software-ab.cs.uni-tuebingen.de/download/splitstree4/welcome.html) The aim of SplitsTree4 is to provide a framework for evolutionary analysis using both trees and networks.
* [FigTree](http://tree.bio.ed.ac.uk/software/figtree/) is designed as a graphical viewer of phylogenetic trees and as a program for producing publication-ready figures.

"Mauve", "mauveAligner" et "progressiveMauve" peuvent être installés avec "conda" mais une erreur peut survenir avec Mauve. En effet, vous pouvez avoir une version trop récente de java (https://edwards.sdsu.edu/research/running-mauve-with-java-10/). Pour y remédier, chercher une “vieille” version de java et remplacer “java” par le chemin de cette version dans le fichier Mauve (ligne JAVA_CMD=java).

[Master Bioinfo Workstation Setup](https://src.koda.cnrs.fr/bioinfo/mbioinfo.workstation.setup)

## Ressources informatiques

Nous allons utiliser les ressources de GenoToul.

### Login genobioinfo

```bash
ssh -Y <USER>@genobioinfo.toulouse.inrae.fr
```

# Création d’un jeu de données

modified 2025-10-15

## Introduction

La sélection des génomes à analyser dans le cadre d’une analyse phylogénétique est une étape essentielle. Ceci est particulièrement vrai pour l’étude des génomes de bactéries ou d’archées, car le nombre de données disponibles croît de manière exponentielle, mais avec une qualité très variable et la possibilité d’un biais d’échantillonnage.

Dans cet atelier, nous aborderons étape par étape l’obtention d’un ensemble de génomes de haute qualité et représentatifs de la diversité des *Prochlorococcus*.

Cet atelier s’inspire de l’article de Tschoeke et al., 2020 “Unlocking the Genomic Taxonomy of the *Prochlorococcus* Collective”.

En effet nous avons vu que *Prochlorococcus* est le procaryote photosynthétique le plus abondant sur notre planète. L’abondante littérature écologique sur le collectif *Prochlorococcus* (PC) repose sur l’hypothèse qu’il s’agit d’un **genre** unique comprenant l’espèce *Prochlorococcus marinus*, qui contient elle-même un collectif **d’écotypes**. Les écologistes adoptent l’hypothèse du génome distribué d’un pan-génome ouvert pour expliquer la diversité génomique observée et les schémas d’évolution des écotypes au sein du PC. De nouvelles données génomiques concernant le PC ont incités les auteurs à réexaminer ce groupe, en appliquant les méthodes actuelles utilisées en taxonomie génomique. Ils ont ainsi pu distinguer les cinq genres suivants : *Prochlorococcus, Eurycolium, Prolificoccus, Thaumococcus* et *Riococcus*. Les nouveaux genres ont des attributs génomiques et écologiques distincts.

Electronic supplementary material [Table S1](https://static-content.springer.com/esm/art%3A10.1007%2Fs00248-020-01526-5/MediaObjects/248_2020_1526_MOESM1_ESM.csv)

## Création d’un jeu de données

### RefSeq au NCBI

https://ftp.ncbi.nlm.nih.gov/genomes/refseq/README.txt 

ASSEMBLY_REPORTS : le contenu consiste en quatre fichiers qui comprennent les détails des métadonnées de tous les derniers assemblages GenBank, de tous les derniers assemblages RefSeq, des assemblages GenBank historiques ou des assemblages RefSeq historiques. Ces fichiers fournissent un lien ftp qui peut être utilisé pour récupérer les données de séquence et d’annotation.
* assembly_summary_genbank.txt
* assembly_summary_genbank_historical.txt
* assembly_summary_refseq.txt
* assembly_summary_refseq_historical.tx

[README_assembly_summary.txt](https://ftp.ncbi.nlm.nih.gov/genomes/README_assembly_summary.txt)

```bash
mkdir -p ~/work/Prochlorococcus/RefSeq
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt -O ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt
```

### Filtrer les génomes de *Prochlorococcus*

```bash
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Prochlorococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt

grep -v '#' -c ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt
```
Supprimer le # devant `assembly_accession` pour avoir le nom des colonnes.

```bash
sed '1s/^.//' Prochlo_assembly_summary_refseq.txt > foo.txt
rm Prochlo_assembly_summary_refseq.txt
mv foo.txt Prochlo_assembly_summary_refseq.txt
```

### Filtrer les génomes de *Synechococcus*

Le génome de la souche *WH 7803* a été retiré de RefSeq.
* [GCA_000063505.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000063505.1/)

Trois génomes ne sont pas des *Synechococcus* : *Cyanobium gracile, Cyanobium sp., Parasynechococcus marenigrum*

```bash
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Synecho/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Cyanobium/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Parasynechococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
```

```bash
sed '1s/^.//' Synecho_assembly_summary_refseq.txt > foo.txt
rm Synecho_assembly_summary_refseq.txt
mv foo.txt Synecho_assembly_summary_refseq.txt
```
```bash
grep -v '#' -c ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
```

### Propriétés des génomes

Nous allons utiliser le R du clusteur en nous connectant sur un nœud avec `srun`.

```bash
search_module statistics/R

srun --pty bash
module load statistics/R/4.3.0
R
#install.packages("tidyverse")
#install.packages("ggplot2")

library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt"
prochlo.refseq.genomes <- read.table(prochlo.refseq.genomes.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes <- prochlo.refseq.genomes %>% 
  mutate(assembly_accession=substr(assembly_accession, 1,13))

## Genome_and_scaffold_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/Genome_and_scaffold_size.pdf'
pdf(file=pdf_file, paper="a4r")

prochlo.refseq.genomes %>%
ggplot(aes(y=genome_size, x=scaffold_count, color=assembly_level)) + 
    geom_point(size=2, alpha=0.5) +
    theme_bw()
dev.off()

## Genome_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/Genome_size_ori.pdf'
pdf(file=pdf_file, paper="a4r")

prochlo.refseq.genomes %>%
  ggplot( aes(x=genome_size, fill=assembly_level)) +
    geom_histogram( binwidth=100000, color="#e9ecef", alpha=0.8) +
    ggtitle("Bin size = 100000 bp") +
    theme_bw() +
    theme(
      plot.title = element_text(size=15)
    )
dev.off()
```

>[!NOTE]
> Pour quitter R et retourner en bash, il faut faire `q()`.

On **actualise** les informations du dossier de travail depuis le serveur sur notre pc :
```bash
rsync --archive --itemize-changes --stats -h -e ssh <USER>@genobioinfo.toulouse.inrae.fr:/home/<USER>/work/Prochlorococcus /home/rodrigues/Bureau/fr.univ-tlse3_M2_BBS_S9/Phylogenomique/Atelier
```

On observe que les génomes sont répartis en trois distributions, nous allons identifier les génomes de petites tailles et nous les analyserons afin de savoir s'il faut les sortir de l'analyse.
La petite distribution commence aux alentours de 1e+6 (1 000 000).
```bash
# NR permet de garder la ligne d'en-tête
# NF correspond au nombre de colonne du fichier
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col < 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt
```

*Nom des colonnes et de leur numéro* :
```bash
head -n 1 Prochlo_assembly_summary_refseq_small_genome.txt  | sed 's/\t/\n/g' | nl > numero_colonne.txt
```

Nous allons regarder à quoi correspondent ces génomes :
```bash
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="organism_name") col=i; next}; !seen[$col]++ {print $col}' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt | sort -u > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome_type.txt
```

>[!NOTE]   
> On observe que l'ensemble de ces génomes correspondent à des génomes de phages.

Nous allons écarter ces séquences de l’analyse :
```bash
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col > 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt
```

*Vous pouvez exécuter les codes R sur votre ordinateur, si vous avez fait un `rsync` pour synchroniser vos répertoires et en modifiant les chemins des fichiers.*

Tracer le taux G+C `gc_percent` en fonction de la taille des génomes `genome_size`.

```bash
module load statistics/R/4.3.0
R

library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 1,13))

## GC_percent_and_Genome_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/GC_percent_and_Genome_size.pdf'
pdf(file=pdf_file, paper="a4r")

### Tracer la régression linéaire
mod <- lm(gc_percent ~ genome_size, data=prochlo.refseq.genomes.clean)

prochlo.refseq.genomes.clean %>%
ggplot(aes(y=gc_percent, x=genome_size, color=assembly_level)) + 
    geom_point(size=2, alpha=0.5) +
    geom_abline(
        intercept = mod$coefficients[1],
        slope = mod$coefficients[2],
        linewidth = 1,
        colour = "red"
    ) +
    theme_bw()
dev.off()
```

>[!INFO]
> Nous pouvons observer une tendance linéaire à l'aide de la droite de régression linéaire. Nous pouvons observer une variabilité dans la taille du génome pour un même taux de GC.
> Nous pouvons également remarquer que le taux de GC ne dépasse pas les 50%.

## Téléchargement des fichiers contenant l’ADN des génomes

Nous allons utiliser les fichiers *assembly_summary_refseq.txt* pour télécharger les fichiers des séquences d’ADN des génomes (*genomic.fna.gz*).
Le lien FTP est trouvé dans la colonne 20 du fichier.
On extrait l’accession du génome avec `basename` et on construit le nom du fichier de sortie en lui ajoutant le répertoire et le suffixe.
Le fichier est téléchargé avec `wget`. Les noms des fichiers sont simplifiés en utilisant le préfixe des 13 premiers caractères.

Nous allons retenir que les génomes avec une taille (colonne 26) > 1e+6 nucléotides.

### Génomes de *Prochlorococcus*
```bash
srun --pty bash
suffix=_genomic.fna.gz

if [[ ! -d ~/work/Prochlorococcus/RefSeq/DNAProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/DNAProchlo
fi

for ftp_path in $(awk -F "\t" '{if($26>1e+6) print $20}' ~/work/Prochlorococcus/RefSeq/Prochlo"_assembly_summary_refseq.txt")
do
  genome=$(basename -- "$ftp_path")
  echo $genome
  file=~/work/Prochlorococcus/RefSeq/DNAProchlo/$genome$suffix
  if [[ ! -e $file ]] || [[ ! -s $file ]]; then
    wget $ftp_path/$genome$suffix -O $file
  fi
done

rm ~/work/Prochlorococcus/RefSeq/DNAProchlo/ftp_path_genomic.fna.gz
gzip -d ~/work/Prochlorococcus/RefSeq/DNAProchlo/*.gz

ls ~/work/Prochlorococcus/RefSeq/DNAProchlo/*fna | wc -l
```

## Evaluation de la qualité des génomes avec CheckM

* [CheckM](https://ecogenomics.github.io/CheckM/)
* [CheckM2](https://www-nature-com.insb.bib.cnrs.fr/articles/s41592-023-01940-w)

```bash
search_module CheckM
```

**CheckM** inclus un ensemble de méthodes permettant d’évaluer la qualité des génomes. Il fournit des estimations robustes de l’exhaustivité (complétude) et de la contamination des génomes en utilisant des ensembles de gènes de références qui sont ubiquitaires et à copie unique à l’intérieur d’une lignée phylogénétique.

L’évaluation de la qualité du génome peut également être examinée à l’aide de graphiques décrivant les principales caractéristiques génomiques (par exemple : GC, densité de codage) qui mettent en évidence les séquences en dehors des distributions attendues d’un génome typique.

CheckM propose également des méthodes permettant d’identifier les segments de génome susceptibles d’être fusionnés sur la base de la compatibilité des marqueurs, de la similarité des caractéristiques génomiques et de la proximité au sein d’un arbre génomique de référence.

* PATH: /usr/local/bioinfo/src/CheckM/
* Test: see /usr/local/bioinfo/src/CheckM/example_on_cluster (en cours)
* How to use: see [How_to_use_SLURM_CheckM](https://moodle.utoulouse.fr/usr/local/bioinfo/src/CheckM/How_to_use_SLURM_CheckM)

```bash
srun --pty bash
module load devel/Miniconda/Miniconda3
module load bioinfo/CheckM/1.2.2
checkm taxon_list | grep Synechococcus > CheckM_taxon-list_Synechococcus.txt
checkm taxon_list | grep Prochlorococcus > CheckM_taxon-list_Prochlorococcus.txt

module unload bioinfo/CheckM/1.2.2
module unload devel/Miniconda/Miniconda3
```

[Taxonomy/Browser](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=1218&lvl=3&lin=f&keep=1&srchmode=1&unlock)

Unlike CheckM, CheckM2 has **universally** trained machine learning models it applies regardless of taxonomic lineage to predict the completeness and contamination of genomic bins.

```bash
mkdir ~/work/Prochlorococcus/script

cp /usr/local/bioinfo/src/CheckM2/example_on_cluster/test_CheckM2-v1.0.2.sh ~/work/Prochlorococcus/script/CheckM2-v1.0.2.sh
```

Editer le fichier *~/work/Prochlorococcus/script/CheckM2-v1.0.2.sh* pour l’accommoder à vos besoins et lancer le script avec `sbatch`.

```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Need Miniconda
module load devel/Miniconda/Miniconda3

module load bioinfo/CheckM2/1.0.2

checkm2 predict --threads 8 -i ~/work/Prochlorococcus/RefSeq/DNAProchlo -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder --database_path /usr/local/bioinfo/src/CheckM2/CheckM2-v1.0.2/databases/CheckM2_database/uniref100.KO.1.dmnd --force
```

Les résultats sont résumés dans le fichier : *~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv*. Vérifiez que vous avez le nombre de lignes attendues.

Création du graphique Contamination_vs_Contamination :
```bash
srun --pty bash
module load statistics/R/4.3.0
R

library(tidyverse)
library(ggplot2)

Prochlo.CheckM.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv"
Prochlo.CheckM <- read.table(Prochlo.CheckM.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

## Contamination vs Contamination
pdf_file <- '~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Contamination_vs_Contamination.pdf'
pdf(file=pdf_file, paper="a4r")

Prochlo.CheckM %>%
ggplot(aes(y=Contamination, x=Completeness, col="coral")) + 
    geom_point(size=2, alpha=0.5) +
    geom_vline(xintercept=99, col="purple", alpha=0.5) + 
    geom_hline(yintercept=0.7, col="purple", alpha=0.5) + 
    theme_bw()

dev.off()
```

>[!INFO]
> La qualité des génomes semblent majoritairement correcte à l'exception d'un génome complet avec une forte contamination et quelques génomes qui sont peu contaminés mais incomplets.

## Comparaison des génomes avec Mash

[Mash](https://mash.readthedocs.io/en/latest/)

### Introduction à Mash

La distance **Mash** estime le taux de mutation entre deux séquences directement à partir de leurs sketches [MinHash](https://kamimrcht.github.io/webpage/sketch.html).
La distance Mash est fortement corrélée avec les mesures basées sur l’alignement telles que l’identité nucléotidique moyenne (ANI).

$D≈1−ANI$

En utilisant uniquement les *sketches*, qui peuvent être des milliers de fois plus petits,
la similarité des séquences originales peut être rapidement estimée avec une erreur limitée.
Il est important de noter que l’erreur de ce calcul ne dépend que de la taille des sketches et est indépendante de la taille du génome.

**Principe** : les séquences de deux ensembles de données sont décomposées en leurs *k-mers* constitutifs
chaque *k-mer* est passé à une fonction de hachage pour obtenir un hachage de 32 ou 64 bits, en fonction de la taille du *k-mer* d’entrée.
Les ensembles de hachage résultants, A et B, contiennent chacun |A| et |B| hachages distincts.
L’indice de *Jaccard* est la fraction de hachages partagés sur l’ensemble des hachages distincts dans A et B.

### Paramètres recommandés pour mash
* [PGG_User_Manual.docx](https://github.com/JCVenterInstitute/PanGenomePipeline/blob/master/PGG_User_Manual.docx)
* `-j` specifies the size of the MASH sketch (recommended 10000).
* `-k` specifies the *k-mer* size for MASH (recommended 16 for bacterial genomes).

### Comparaison des génomes avec Mash
```bash
search_module mash
```

* PATH: /usr/local/bioinfo/src/Mash/
* Test: see /usr/local/bioinfo/src/Mash/example_on_cluster
* How to use: see /usr/local/bioinfo/src/Mash/How_to_use_SLURM_Mash
```bash
more /usr/local/bioinfo/src/Mash/How_to_use_SLURM_Mash
```

```bash
more /usr/local/bioinfo/src/Mash/example_on_cluster/test_mash-v2.3.sh
```

Les calculs peuvent être décomposés en trois étapes.

#### mash sketch : calculer les sketches pour chaque génome

Nous utilisons `sarray` pour lancer `mash sketch` sur les génomes qui ont plus de 99% de complétion et moins de 0.8 contamination.

```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Load modules
module load bioinfo/Mash/2.3

#Code
if [[ ! -d ~/work/Prochlorococcus/RefSeq/MashProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/MashProchlo
fi

size=10000
kmer=16
for entry in $(awk -F "\t" '{if($2>99 && $3<0.8) print $0}' ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv | cut -f 1)
do
 genome=$entry.fna
 echo "module load bioinfo/Mash/2.3; mash sketch -s $size -k $kmer ~/work/Prochlorococcus/RefSeq/DNAProchlo/$genome"
done > ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh

sarray -J mash -o %j.out -e %j.err -t 01:00:00 ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh
```

>[!NOTE]
> Il y a 12 génomes qui ne sont pas dans les critères : 99% de complétion et moins de 0.8 de contamination.
> Il y a 158 génomes après avoir retiré les génomes de phages. Nous obtenons bien 146 génomes.

#### mash paste : compiler les sketchs

```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Load modules
module load bioinfo/Mash/2.3

#Code
if [[ ! -e ~/work/Prochlorococcus/RefSeq/MashProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/MashProchlo
fi

srun --pty bash
module load bioinfo/Mash/2.3

mash paste ~/work/Prochlorococcus/RefSeq/MashProchlo/mash ~/work/Prochlorococcus/RefSeq/DNAProchlo/*.msh
```

#### mash dist : calcule des pairs de distances

```bash
srun -c 10 --pty bash
module load bioinfo/Mash/2.3
cpu=10

mash dist  -p $cpu ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh > ~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt
```

### Tracé des résultats
```bash
module load statistics/R/4.3.0
R
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
```

### Les résultats sont transformés en matrix de distance avec R

Les noms des génomes correspondent au chemin complet des fichiers. Nous allons extraire le préfixe de l’accession des génomes.
```text plain
          Query           Hit Distance      Pvalue       Ratio
1 GCF_000007925 GCF_000007925 0.000000 0.00000e+00 10000/10000
2 GCF_000011465 GCF_000007925 0.261316 5.65209e-92    77/10000
...
```
```bash
module load statistics/R/4.3.0
R
library(tidyverse)

Prochlo.Mash.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt"
Mash.colnames <- c("Query", "Hit", "Distance", "Pvalue", "Ratio")
Prochlo.Mash <- read.table(Prochlo.Mash.file, sep = "\t", quote = "", header = F, col.names=Mash.colnames, stringsAsFactors = T, skipNul=T)

Prochlo.Mash.matrix <- Prochlo.Mash %>% 
  mutate(Query=substr(Query,55, 67)) %>% 
  mutate(Hit=substr(Hit,55, 67)) %>% 
  pivot_wider(id_cols=Query, names_from=Hit, values_from = "Distance")

Prochlo.Mash.matrix.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt"

write.table(Prochlo.Mash.matrix, file=Prochlo.Mash.matrix.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = TRUE)

q() #permet de quitter R et la ligne suivante d'enregistrer le travail effectue
y
head -n 2 ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt
```

#### Sélection des représentants

* [GGRaSP](https://github.com/JCVenterInstitute/ggrasp/)

**GGRaSP** (Gaussian Genome Representative Selector with Prioritization) est un package R qui permet de générer
et de renvoyer un ensemble représentatif de génomes à partir d’un grand nombre de génomes ayant une relation définie.
L’ensemble représentatif est sélectionné :
* soit en utilisant un niveau de coupure d’une hiérarchie ou le nombre de groupes définis par l’utilisateur,
* soit en calculant des groupes de novo sur la base d’une modélisation des relations entre les génomes à l’aide d’un modèle de mélange gaussien. La valeur par défaut renvoyée est la liste des génomes représentatifs, mais le logiciel fournit également plusieurs sorties, notamment des fichiers texte, des graphiques et des arbres.

Pour permettre une analyse à haut débit, un fichier *Rscript* est disponible.
Il peut exécuter GGRaSP à partir de la ligne de commande (il nécessite que **ggrasp.R** soit lancé dans un shel avec chargement de `module load statistics/R/4.3.0`).

L’option de télécharger le fichier *ggrasp_1.0.tar.gz* depuis github et d’installer *ggrasp* à partir de ce fichier dans R fonctionne !
```bash
cd ~/work
git clone https://github.com/JCVenterInstitute/GGRaSP.git
```
* `-i, –input` input file name for tab delimited distance matrix with row and column headers, newick file, or aligned multiple fasta file
* `-m, –method` optional method to use for hclust such as complete, single or average or nj to perform neighbor-joining
* `-r, –ranks` optional input file with ranks of the genes for medoid selection. Ranks should be from 1 (best) to n (worst) in two columns with the genome ID in the first
* `-c, –clusters` optional number of clusters to generate
* `-h, –threshold` optional threshold to use to cluster the genomes
* `-a, –metadata` optional input file containing metadata for the genomes. It should be tab-deleniated

```bash
~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp --writetable --writeitol --writetree --plothist --plotgmm --plotclus
```

>[!WARNING]
>Error in library(getopt) : there is no package called ‘getopt’
>Execution halted

>[!INFO]
> Lors de l'installation d'un package R, il faut sélectionner le CRAN de France-Lyon (33).

Comme la commande précédente ne fonctionne pas, il faut d'abord installer les packages R manquants :
```bash
R
install.packages("getopt")
33
install.packages("ggrasp")
33
q()
y
~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp --writetable --writeitol --writetree --plothist --plotgmm --plotclus
```

Fichier créés par ggrasp.R :
```bash
ls ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp*
```

Propriétés des médoïdes
```bash
R
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

q()
y
```

### Choix des référence en fonction de leur qualité de séquençage

Le fichier *Prochlorococcus_Quality.txt* renferme la liste des génome avec leur qualité définit comme suit:

$Quality=\sqrt{(1-\frac{Completeness}{100})^2+(Contamination)^2}$

Construction du fichier
```bash
module load statistics/R/4.3.0
R

if (!require('kableExtra')) {install.packages('kableExtra')}
33
if (!require('tidyverse')) {install.packages('tidyverse')}
33
if (!require('ggplot2')) {install.packages('ggplot2')}
33

library(kableExtra)
library(tidyverse)
library(ggplot2)

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

more ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt
```

Il est utilisé pour la sélection des médoides de chaque classe.
```bash
~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ --writetable --writeitol --writetree --plothist --plotgmm --plotclus  -r ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt
```

Propriétés des médoïdes
```bash
R

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
```

Vous pouvez utiliser [iTOL](https://itol.embl.de/) pour obtenir un arbre annoté de qualité.
* ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.tree.txt
* ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.itol.txt

Cet arbre peut être enrichi d’autres annotations, comme la taille des génomes, la complétude, le taux de GC, et d’autres métadonnées (cf. le [help d’iTOL](https://itol.embl.de/help.cgi)).

## GTDB

La base de données sur la taxonomie des génomes (GTDB) a pour but d’établir une **taxonomie microbienne standardisée** basée sur la phylogénie des génomes.
Les génomes utilisés pour construire la phylogénie proviennent de **RefSeq** et de **GenBank**.
La taxonomie GTDB est basée sur des arbres espèces inférés à l’aide de *FastTree* à partir d’un ensemble concaténé aligné de 120 protéines marqueurs
à copie unique chez les bactéries.

[GTDB](https://gtdb.ecogenomic.org/)

Nous allons utiliser cette taxonomie pour vérifier la cohérence de nos résultats.
Pour cela, nous allons télécharger le fichier contenant, pour chaque génome, les métadonnées de GTDB (*bac120_metadata.tsv.gz*).
Nous allons faire une jointure entre notre fichier de génomes de *Prochlorococcus* (*~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt*).

La jointure peut se faire sur *ncbi_biosample/biosample*.

Nous pouvons conserver les colonnes
* 1 accession
* 16 gc_percentage
* 17 genome_size
* 18 gtdb_genome_representative
* 19 gtdb_representative
* 20 gtdb_taxonomy (Domains, Phyla, Classes, Orders, Families, Genera, Species) du fichier de métadonnées.

Nous pouvons remplacer les séparateurs “;” par une tabulation dans la taxonomy de GTDB pour la séparer en colonnes.
```bash
wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_taxonomy.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz
gzip -d ~/work/Prochlorococcus/RefSeq/bac120_taxonomy.tsv.gz
```

Nous allons recouper la taxonomie avec les groupes obtenus à l’aide de grrasp.
Une difficulté réside dans le fait que les numéros d’accès au génome n’ont pas le même préfixe dans les deux ensembles de données.
Nous devons effectuer une jointure sur les suffixes.
```bash
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
```

Compilation des associations :
```bash
cut -f3,10 ~/work/Prochlorococcus/RefSeq/bac120_taxonomy_ACsuffix_group.txt | sort -k2 | uniq -c
```
```bash
wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_metadata.tsv.gz -O ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

gzip -d ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv.gz

# 1 accession
# 16 gc_percentage
# 17 genome_size
# 18 gtdb_genome_representative
# 19 gtdb_representative
# 20 gtdb_taxonomy (Domains, Phyla, Classes, Orders, Families, Genera, Species) 
# 53 ncbi_biosample
# 58 ncbi_genbank_assembly_accession

tail -n+2 ~/work/Prochlorococcus/RefSeq/bac120_metadata.tsv | sort -t $'\t' -k 53  > ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv 

cut -f3 ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst

sort -t $'\t' -k 1  ~/work/Prochlorococcus/RefSeq/Prochlo_biosample.lst   > ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst 

join -t $'\t' -1 53 -2 1 -o 1.1,2.1,1.16 1.17 1.18 1.19 1.20 ~/work/Prochlorococcus/RefSeq/bac120_metadata_sort.tsv ~/work/Prochlorococcus/RefSeq/Prochlo_biosample_sort.lst > ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

wc -l ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt

sed s'/;/\t/g' -i ~/work/Prochlorococcus/RefSeq/Prochlo_GTDB_taxo.txt
```
```bash
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
```

Vous pouvez annoter votre distribution du taux de GC en fonction de la taille des génomes avec le genre des génomes.

Utilisez l’option LABEL d’iTOL (https://itol.embl.de/help/labels_template.txt) pour remplacer les noms de génomes par des noms d’espèces.

---

But : chercher les groupes orthologues pour retracer l'évolution

First step : filtrer pour ne garder que l'espèce d'intérêt (Prochlorococcus)
* ceux qui sont classés comme tel
* retirer ceux qui sont abérants
	* vérifier les tailles de génomes
	* vérifier les taux de GC
	* vérifier le nombre de gènes

Second step : retirer les génomes incomplets  et ceux qui sont contaminés
* vérifier le nombre de *scaffold* (1 par chromosome attendu)
* vérifier les taux de contamination (séquence inconnue au génome d'intérêt) et de complétude (ensemble de gènes caractéristiques de l'espèce à retrouver)
	* limitation dans le cas de problème d'annotation (manque de métadata) qui impliquerait un retrait de séquences d'intérêt dont la complétude n'est pas parfaite suite à des évènements évolutifs

Third step : s'assurer de la représentativité de l'échantillonage sur la population réelle
* on calcule les différentes distances entre les génomes : on conservera les génomes éloignés les uns des autres
* on peut notamment utiliser l'ANI : identité moyenne entre deux séquences d'ADN, corrélée à la distance entre les séquences
* on utilise un taux d'identité à 95% chez les bactéries pour savoir si elles font parties de la même espèce
* on utilise Mash qui utilise une table de hashage pour calculer l'ANI

Fourth step : clustering des séquences et identification de représentants par classe
* permet de vérifier si les classes sont équilibrées en nombre
* si ce n'est pas le cas, on conserve les représentants pour l'analyse
	* cependant, perte d'information. Il pourrait être utile de générer un consensus du génome, mais la majorité des outils développés ont besoin d'un génome et ne fonctionne pas avec un consensus

Fifth step : savoir si les classes obtenues ont un sens en taxonomie
* lors de l'utilisation de GTDB, il faut donner le numéro de la dernière release dont on se sert puisqu'elle change et que la nomenclature et la taxonomie changent alors
* GTDB est en retard face à RefSeq, on peut donc avoir des séquences dans RefSeq qui n'apparaissent pas suite à l'analyse avec GTDB

Les écologistes ont parlés d'écotypes : il n'existe qu'une espèce de Prochlorococcus mais différents géno-phénotypes selon les zones écologiques.
Cependant, on va vérifier si la taxonomie actuelle ne peut pas être revue.

**INFO**   
L'enrichissement en GC d'un génome est issu d'un biais mutationnel qui implique une "préférence" en G et C lors de la mutation et/ou la réparation lors de dommages.

**Suite**   
On va sélectionner des sous-échantillons et effectuer une nouvelle annotation avec Prokka (elles sont déjà bien annotées avec RefSeq). Cela permet d'avoir une autre approche.

---

# Échantillon de Zhang

modified 2025-10-16

## Introduction

Dans la suite de l’atelier, nous travaillerons sur un sous-ensemble de génomes. Nous avons choisi de ne pas utiliser ceux sélectionnés à l’étape précédente, afin de pouvoir comparer nos résultats avec ceux obtenus dans trois études différentes :
* Kettler et al., PLoS Genet. 2007 Dec;3(12):e231 Patterns and implications of gene gain and loss in the evolution of Prochlorococcus.
* Yan et al., Appl Environ Microbiol. 2018 Genome rearrangement shapes Prochlorococcus ecological adaptation.
* Zhang et al., Proceedings of the Royal Society B: Biological Sciences 2021 Snowball Earth, population bottleneck and Prochlorococcus evolution.

Les génomes utilisés dans les deux premiers articles sont inclus dans ceux de l’article de Zhang et al. 2021.

## Échantillon de Zhang

Fichier avec les Accession Number des génomes utilisés dans Zhang : `Zhang_Supplementary_Data.csv`

Copie du fichier dans votre répertoire :
```bash
mkdir ~/work/Zhang
cp /home/formation/public_html/M2_Phylogenomique/data/Zhang/Zhang_Supplementary_Data.csv ~/work/Zhang/Zhang_Supplementary_Data.csv
```

Nous allons utiliser des scripts R pour préparer les fichiers utilisés pour télécharger les génomes.

Les prefix des NCBI_Accession_ID contenus dans ce fichier sont différents de ceux présents dans RefSeq. Ils sont supprimés.
```bash
srun --pty bash
module load statistics/R/4.3.0
R
```
```R
library(tidyverse)

supdata.file <- "~/work/Zhang/Zhang_Supplementary_Data.csv"
supdata.genomes <- read.table(supdata.file, sep = "\t", quote = "", header = T, stringsAsFactors = F)
supdata.genomes <- supdata.genomes %>%
    mutate(NCBI_Accession_ID=substr(NCBI_Accession_ID, 4,13))
```
Nous allons utiliser un code à quatre lettres pour identifier les génomes.
```R
four_letters_code <- function(prefix=Aa, max=26) {
  lc_alpha <- strsplit(intToUtf8(c(97:122)),"") 
  uc_alpha <- strsplit(intToUtf8(c(65:90)),"")
  code.list <- c()
  
  for ( i in 0:(max-1) ) {
    i1 <- floor(i/26)+1
    i2 <- i%%26+1
    code <- paste(prefix, lc_alpha[[1]][i1],lc_alpha[[1]][i2], sep="")
    code.list <- append(code.list, code)
  }
  return(code.list)
}
```

## Prochlorococcus accession

Lecture du fichier Prochlo_assembly_summary_refseq.txt créé lors du TP “Création d’un jeu de données” et
modification des assembly_accession pour qu’il soit compatible avec celui du fichier Zhang_Supplementary_Data.csv modifié..
```bash
prochlo.refseq.genomes.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt"
prochlo.refseq.genomes <- read.table(prochlo.refseq.genomes.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes <- prochlo.refseq.genomes %>% 
  mutate(assembly_accession=substr(assembly_accession, 4,13))
```

Intersection entre ce fichier et la liste des génomes de Prochlorococcus utilisés dans Zhang (jointure de supdata.genomes et prochlo.refseq.genomes.
```bash
Prochlo_Zhang <- inner_join(supdata.genomes, prochlo.refseq.genomes, by = join_by(NCBI_Accession_ID == assembly_accession))
```

Ajout du code à quatre lettres et écriture du fichier avec le préfixe ‘Pr’ pour Prochlorococcus.
```bash
Prochlo_prefix <- "Pr"
Prochlo_max <- nrow(Prochlo_Zhang)
Code <- four_letters_code(Prochlo_prefix, Prochlo_max)
Prochlo_Code <- as.data.frame(Code)
Prochlo_Zhang.Code <- cbind(Prochlo_Code, Prochlo_Zhang)

Prochlo_Zhang.Code.file <- "~/work/Zhang/Prochlorococcus_Zhang_Code.txt"

write.table(Prochlo_Zhang.Code, file=Prochlo_Zhang.Code.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = FALSE)
```

### Synechococcus accession

Note: GCA_000063505.1 a été supprimé de RefSeq.

[GCA_000063505.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000063505.1/)

GCF_000063505.1 (suppressed)

```bash
synecho.refseq.genomes.file <- "~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt"
synecho.refseq.genomes <- read.table(synecho.refseq.genomes.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

synecho.refseq.genomes <- synecho.refseq.genomes %>% 
  mutate(assembly_accession=substr(assembly_accession, 4,13))
```

Si vous avez une erreur assembly_accession not found, vérifiez que vous avez bien supprimé la première ligne et le # devant assembly_accession.
```bash
Synecho_Zhang <- inner_join(supdata.genomes, synecho.refseq.genomes, by = join_by(NCBI_Accession_ID == assembly_accession))
```

Vérifiez que vous avez 20 génomes sélectionnés.
```bash
Synecho_prefix <- "Sy"
Synecho_max <- nrow(Synecho_Zhang)
Code <- four_letters_code(Synecho_prefix, Synecho_max)
Synecho_Code <- as.data.frame(Code)
Synecho_Code
Synecho_Zhang.Code <- cbind(Synecho_Code, Synecho_Zhang)
ncol(Synecho_Zhang.Code)

Synecho_Zhang.Code.file <- "~/work/Zhang/Synechococcus_Zhang_Code.txt"

write.table(Synecho_Zhang.Code, file=Synecho_Zhang.Code.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = FALSE)
```

## Échantillon de Kettler

Caractéristiques des souches étudiées

Table modifiée à partir de la Table 1 de (Kettler et al., 2007).
|Cyanobacterium |Isolate |Light Adap. |Length(bp) |GC% |Number Genes |Isol. Depth |Region |Date |Accession |Code|
|---------------|--------|------------|-----------|----|-------------|------------|-------|-----|----------|----|
|Prochlorococcus |MED4 |HL(I) |1,657,990 |30.8 |1,929 |5m |Med. Sea |Jan. 1989 |BX548174 |Prab|
|Prochlorococcus |MIT9515 |HL(I) |1,704,176 |30.8 |1,908 |15m |Eq. Pacific |Jun. 1995 |CP000552 |Prai|
|Prochlorococcus |MIT9301 |HL(II) |1,642,773 |31.4 |1,907 |90m |Sargasso Sea |Jul. 1993 |CP000576 |Prae|
|Prochlorococcus |AS9601 |HL(II) |1,669,886 |31.3 |1,926 |50m |Arabian Sea |Nov. 1995 |CP000551 |Praa|
|Prochlorococcus |MIT9215 |HL(II) |1,738,790 |31.1 |1,989 |5m |Eq. Pacific |Oct. 1992 |CP000825 |Prau|
|Prochlorococcus |MIT9312 |HL(II) |1,709,204 |31.2 |1,962 |135m |Gulf Stream |Jul. 1993 |CP000111 |Prag|
|Prochlorococcus |NATL1A |LL(I) |1,864,731 |35.1 |2,201 |30m |N. Atlantic |Apr. 1990 |CP000553 |Prbb|
|Prochlorococcus |NATL2A |LL(I) |1,842,899 |35 |2,158 |10m |N. Atlantic |Apr. 1990 |CP000095 |Praj|
|Prochlorococcus |CCMP1375 SS120 |LL(II) |1,751,080 |36.4 |1,925 |120m |Sargasso Sea |May. 1988 |AE017126 |Prak|
|Prochlorococcus |MIT9211 |LL(III) |1,688,963 |38 |1,855 |83m |Eq. Pacific |Apr. 1992 |CP000878 |Prat|
|Prochlorococcus |MIT9303 |LL(IV) |2,682,807 |50.1 |3,022 |100m |Sargasso Sea |Jul. 1992 |CP000554 |Praf|
|Prochlorococcus |MIT9313 |LL(IV) |2,410,873 |50.7 |2,843 |135m |Gulf Stream |Jul. 1992 |BX548175 |Prah|

Les génomes de Prochlorococcus de Kettler sont inclus dans l’échantillon de Zhang.
```bash
for strain in MED4 'MIT 9515' 'MIT 9301' AS9601 'MIT 9215' 'MIT 9312' NATL1A NATL2A SS120 'MIT 9211' 'MIT 9303' 'MIT 9313';  
do
  printf "%s " $(grep "$strain" ~/work/Zhang/Prochlorococcus_Zhang_Code.txt | cut -f 1);
done
```

# Annotation des génomes

modified 2025-10-16

## Introduction

Les génomes proviennent de RefSeq et ont été annotés par les auteurs et ré-annotés par le NCBI.
Il est donc possible de télécharger ces annotations pour le reste de l’atelier.
Cependant, pour se placer dans un contexte plus général, où les génomes ne sont pas toujours annotés ou le sont de manière incorrecte,
nous allons refaire l’annotation avec le logiciel **Prokka**.
* [Prokka](http://www.vicbioinformatics.com/software.prokka.shtml)

Prokka s’appuie sur des logiciels externes de prédiction des caractéristiques pour identifier les coordonnées des caractéristiques génomiques dans les contigs.
Ces outils sont listés dans le Tableau 1 et tous, à l’exception de Prodigal, fournissent des coordonnées et des étiquettes appropriées pour décrire l’objet annoté.

**Tableau 1.**

Logiciels de prédiction utilisés par Prokka

|Tool (reference) |Features predicted|
|---|---|
|Prodigal ( Hyatt 2010 ) |Coding sequence (CDS)|
|RNAmmer ( Lagesen et al. , 2007 ) |Ribosomal RNA genes (rRNA)|
|Aragorn ( Laslett and Canback, 2004 ) |Transfer RNA genes|
|SignalP ( Petersen et al. , 2011 ) |Signal leader peptides|
|Infernal ( Kolbe and Eddy, 2011 ) |Non-coding RNA|

Les gènes codant pour les protéines sont annotés en deux étapes.
Prodigal identifie les coordonnées des gènes candidats, mais ne décrit pas le produit putatif du gène.

Pour prédire la fonction, Prokka utilise une approche hiérarchique, en commençant par une petite base de données de confiance,
en passant à des bases de données de taille moyenne mais spécifiques à un domaine, et enfin à des modèles de familles de protéines.
Par défaut, un seuil de valeur de 1e^10-6 est utilisé avec la série suivante de bases de données incluses :
* Un ensemble facultatif de protéines annotées fourni par l’utilisateur. Elles sont recherchées à l’aide de BLAST+ (blastp) ( Camacho et al. , 2009 ).
* Toutes les protéines bactériennes de UniProt qui ont une preuve réelle de protéine ou de transcription et qui ne sont pas un fragment. BLAST+ est utilisé pour la recherche.
* Toutes les protéines des génomes bactériens complets présentes dans RefSeq pour un genre donné. BLAST+ est utilisé pour cela et est optionnel.
* Un ensemble de bases de données de profils de modèles de Markov cachés, y compris Pfam et TIGRFAMs. Cette opération est réalisée à l’aide de hmmscan du progiciel HMMER 3.1.
* Si aucune correspondance ne peut être trouvée, la séquence est étiquetée comme “protéine hypothétique”.

## Télécharger les génomes

Téléchargement des séquences ADN en format Fasta des génomes.

Préparer la commande pour tous les génomes puis on utilise sarray pour exécuter tous les téléchargements :
```bash
srun --pty bash

#preparation
dnadir=~/work/Zhang/DNA
table=~/work/Zhang/Prochlorococcus_Zhang_Code.txt
 
awk -F "\t"  -v DIR=$dnadir '
{
 code=$1;
 ftplink=$26
 n=split(ftplink, a, "/")
 genome=a[n]
 printf("wget %s/%s_genomic.fna.gz -O %s/%s.fna.gz\n", ftplink, genome, DIR, code)
}' $table > ~/work/Zhang/downloadfna.sh

#sarray
if [[ ! -d $dnadir ]]; then
  mkdir $dnadir
fi
 
sarray -J downloadfna -o %j.out -e %j.err -t 01:00:00 ~/work/Zhang/downloadfna.sh
 
gzip -d $dnadir/*.gz
```

Recommencer les mêmes commandes avec `table=~/work/Zhang/Synechococcus_Zhang_Code.txt.`
```bash
srun --pty bash

dnadir=~/work/Zhang/DNA
table=~/work/Zhang/Synechococcus_Zhang_Code.txt
 
awk -F "\t"  -v DIR=$dnadir '
{
 code=$1;
 ftplink=$26
 n=split(ftplink, a, "/")
 genome=a[n]
 printf("wget %s/%s_genomic.fna.gz -O %s/%s.fna.gz\n", ftplink, genome, DIR, code)
}' $table > ~/work/Zhang/downloadfna.sh

if [[ ! -d $dnadir ]]; then
  mkdir $dnadir
fi
 
sarray -J downloadfna -o %j.out -e %j.err -t 01:00:00 ~/work/Zhang/downloadfna.sh
 
gzip -d $dnadir/*.gz
```

## Exemple d’utilisation

Nous allons créer un répertoire pour les résultats de Prokka et chercher la dernière version disponible de Prokka sur le serveur.
```bash
prkdir=~/work/Zhang/Prokka
if [[ ! -d $prkdir ]]; then
  mkdir -p $prkdir
fi
```

Recherchez le module Prokka.
```bash
search_module prokka
```

Lancement de Prokka avec le génome Praa.
```bash
srun -c 2 --pty bash
module load bioinfo/PROKKA/1.14.5
prokka  ~/work/Zhang/DNA/Praa.fna  --outdir ~/work/Zhang/Prokka/Praa --compliant --addgenes --prefix Praa  --locustag Praa.g --genus Prochlorococcus --species 'Prochlorococcus marinus' --strain AS9601 --kingdom Bacteria --cpus 2
```

À la fin du programme, déconnectez-vous du nœud (exit) pour revenir au frontal.

Le programme génère plusieurs fichiers pour chaque réplicon (~/work/Zhang/Prokka/Praa), dont:
* annotation en format GenBank (gbk)
* annotation en format gff
* les peptides (faa)
* les séquences des CDS (ffn)

N’oubliez pas de synchroniser (rsync) les répertoires de genotoul et de votre poste de travail.

## Automatisation des annotations Prokka sur l’ensemble des génomes

Comme nous venons de le voir, Prokka nécessite plusieurs informations sur les génomes :
* le code,
* le nom de genre (genus),
* le nom d’espèce (species),
* le nom de souches (strain).

Ces informations sont disponibles dans le fichier Prochlorococcus_Zhang_Code.txt. Nous pouvons donc les extraire et construire la commande pour chaque génome.
```bash
table=~/work/Zhang/Prochlorococcus_Zhang_Code.txt
genus=Prochlorococcus
 
awk -F "\t" -v genus=$genus '
{
 code=$1;
 split($14, s, " ");
 species=sprintf("%s %s", s[1], s[2])
 strain=substr($15, 8,20);
 printf("module load bioinfo/PROKKA/1.14.5; prokka  ~/work/Zhang/DNA/%s.fna  --outdir ~/work/Zhang/Prokka/%s --compliant --addgenes --prefix %s --locustag %s.g --genus %s --species \"%s\" --strain \"%s\" --kingdom Bacteria --cpus 1\n", code, code, code, code, genus, species, strain)
}' $table > ~/work/Zhang/prokka.sh

sarray -J prokkaProchlo -o %j.out -e %j.err -t 01:00:00 ~/work/Zhang/prokka.sh
```

Une fois les jobs terminés, vérifiez que les fichiers de sortie du logiciel Prokka existent et ne sont pas vides.
```bash
ls -l ~/work/Zhang/Prokka/Pr*/*.txt
```

Refaire le même traitement pour les génomes de Synechococcus.
```bash
table=~/work/Zhang/Synechococcus_Zhang_Code.txt
genus=Synechococcus

awk -F "\t" -v genus=$genus '
{
 code=$1;
 split($14, s, " ");
 species=sprintf("%s %s", s[1], s[2])
 strain=substr($15, 8,20);
 printf("module load bioinfo/PROKKA/1.14.5; prokka  ~/work/Zhang/DNA/%s.fna  --outdir ~/work/Zhang/Prokka/%s --compliant --addgenes --prefix %s --locustag %s.g --genus %s --species \"%s\" --strain \"%s\" --kingdom Bacteria --cpus 1\n", code, code, code, code, genus, species, strain)
}' $table > ~/work/Zhang/prokka_syn.sh

sarray -J prokkaSynecho -o %j.out -e %j.err -t 01:00:00 ~/work/Zhang/prokka_syn.sh
```

Les fichiers avec le suffixe .err renferment la sortie standard de Prokka. Si tout s’est bien passé, vous pouvez supprimer les fichiers .err et .out.
* Comparez le nombre de gènes obtenus avec ceux reportés dans le fichier RefSeq (~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt, colonne protein_coding_gene_count) et commentez les différences observées.
* Comment faire pour comparer les annotations de Prokka avec celles des fichiers GenBank de RefSeq?
* Pensez-vous que Prokka soit la meilleure méthode d’annotation?
* Comment pourriez-vous faire pour évaluer les performances des différentes méthodes d’annotation des génomes?

>[!WARNING]
> La section suivante n'est plus à faire (jusqu'à **Annotation des génomes**).

[BEACON](https://www.cbrc.kaust.edu.sa/BEACON/index.html) - automated tool for Bacterial gEnome Annotation ComparisON

Remplacer Praa.g_1 par NC_008816 dans le fichier Praa.gbk.

Dans cette dernière partie, nous faisons appel à votre créativité.
Nous vous demandons d’écrire un programme dans le langage de votre choix pour comparer les résultats des annotations de Prokka avec ceux de RefSeq.

Nous vous suggérons de vous concentrer sur l’annotation des gènes codant pour les protéines,
et de faire l’inventaire des différences que vous pouvez attendre entre l’annotation de ces gènes par les deux logiciels d’annotation.

Exécutez votre programme sur un ensemble de génomes afin d’obtenir des statistiques sur des comparaisons indépendantes.

Analysez les résultats et proposez des pistes pour améliorer l’annotation des gènes bactériens.

Les fichiers GFF peuvent être utiles.

## Visualisation des annotations

Nous pouvons utiliser le logiciel art (Artemis) pour visualiser les annotations des génomes (fichiers .gbk).

Il est fortement recommandé d’utiliser ce logiciel en local sur votre poste de travail.

# Annotation des génomes

modified 2025-10-16

## Introduction

* [eggnog-mapper](https://github.com/eggnogdb/eggnog-mapper)
* [eggNOG-mapper-v2.0.0-v2.0.1](https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.0.0-v2.0.1)

EggNOG-mapper est un logiciel d’annotation fonctionnelle de nouvelles séquences.
Il utilise des groupes orthologues et des phylogénies pré-calculés à partir de la base de données eggNOG
pour transférer des informations fonctionnelles à partir d’orthologues à grain fin uniquement.

Les utilisations courantes d’eggNOG-mapper comprennent l’annotation de nouveaux génomes, transcriptomes ou même de catalogues de gènes métagénomiques.

L’utilisation des prédictions des orthologues pour l’annotation fonctionnelle permet une plus grande précision
que les recherches par similarités traditionnelles (i.e. les recherches effectuées avec BLAST),
car elle évite de transférer les annotations des paralogues proches (gènes dupliqués ayant une plus grande probabilité d’être impliqués dans une divergence fonctionnelle).

Location: `/usr/local/bioinfo/src/eggNOG-mapper`
* [Basic_usage](https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.1.5-to-v2.1.8#Basic_usage)

```bash
search_module eggnog-mapper
more /usr/local/bioinfo/src/eggNOG-mapper/example_on_cluster/test_eggnog-mapper-2.0.1.sh
```
```text plain
 -i FILE                 input FASTA file containing query sequences (proteins by default)
 --data_dir DIR          Specify a path to the eggNOG-mapper databases. By default, data/ folder or the one specified by the EGGNOG_DATA_DIR environment variable. 
 -m MODE                 Search options, Default is -m diamond
 --target_orthologs      one2one|many2one|one2many|many2many|all defines what type of orthologs (in relation to the seed ortholog) should be used for functional transfer. Default: all 
 --report_orthologs      as a first step in functional annotation, eggNOG-mapper identifies the orthologs of each query, using seed orthologs from the search stage as an anchoring or starting point. A list of these orthologs is not reported by default. 
 --output,-o FILE_PREFIX base name for output files
 --output_dir DIR        where output files should be written. default is current working directory.
 --decorate_gff no|yes|FILE  Option to create/decorate a GFF file with emapper hits and/or annotations. Default is no.
```

Output files
```text plain
Search hits (prefix.emapper.hits)              A file with the results from the search phase, from HMMER, Diamond or MMseqs2.
Seed orthologs (prefix.emapper.seed_orthologs) A file with the results from parsing the hits. Each row links a query with a seed ortholog. 
Annotations (prefix.emapper.annotations)       A file with the results from the annotation phase. 
```

## Mise en oeuvre

```bash
srun --pty bash

eggdir=~/work/Zhang/EggNOG
if [[ ! -d $eggdir ]]; then
  mkdir -p $eggdir
fi


if [[ -e $eggdir/eggnog-mapper.sh ]]; then
  rm $eggdir/eggnog-mapper.sh
fi
 
for file in ~/work/Zhang/Prokka/Pr*/Pr*.faa; 
do
  prefix=$(basename $file .faa)
  output="$eggdir/${prefix}.emapper.annotations"
  if [[ -f "$output" ]]; then
    echo "skip $output" 
  else
    echo "module load devel/python/Python-2.7.18; module load bioinfo/eggNOG-mapper/2.1.13; emapper.py -i $file --cpu 4 --output $eggdir/$prefix -m diamond" 1>> $eggdir/eggnog-mapper.sh
  fi
done

cat $eggdir/eggnog-mapper.sh

sarray -J eggNOG -o %j.out -e %j.err -t 04:00:00 --cpus-per-task=4 $eggdir/eggnog-mapper.sh
```

Pour vérifier les jobs en cours d'exécution :
```bash
squeue -u $USER
```

Vous pouvez trouver les fichiers ici: `/home/formation/work/PhyloG/Zhang/EggNOG/`

[cog category](https://www.ncbi.nlm.nih.gov/research/cog/cogcategory/J/)

Tracer la distribution de fréquence des catégories COG observées dans un génome.


# Annotation des génomes

modified 2025-10-16

## Introduction
* [OrthoFinderV2](https://github.com/davidemms/OrthoFinder)
* [OrthoFinderV3](https://github.com/OrthoFinder/OrthoFinder)
* [article](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1832-y) figure [figures 2](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1832-y/figures/2)
* [OrthoFinder 3: scalable phylogenetic orthology inference for comparative genomics.](https://www.biorxiv.org/content/10.1101/2025.07.15.664860v1)

OrthoFinder est une plateforme rapide, précise et complète pour la génomique comparative.
Il trouve des orthogroupes et des orthologues, déduit des arbres enracinés pour tous les orthogroupes et identifie tous les évènements de duplication de gènes dans ces arbres.
Il infère également un arbre espèces enraciné pour l’espèce analysée et cartographie les évènements de duplication de gènes,
identifiés sur les arbres gènes, aux branches de l’arbre d’espèces.

* [command-line-options](https://github.com/davidemms/OrthoFinder#command-line-options)
* [command-line-options V3](https://github.com/OrthoFinder/OrthoFinder?tab=readme-ov-file#command-line-options)

### Adding additional species (V3)

`--assign  --core    Assign species from  to existing orthogroups in .`

### Options controlling the workflow

`-M : Use MSA or DendroBLAST gene tree inference, opt=msa,dendroblast [default=dendroblast]`

### Options controlling the programs used

```plain text
-S : Sequence search program opt=blast,diamond,mmseqs,... user-extendable [Default = diamond]
-A : MSA program opt=famsa,mafft,muscle,... user-extendable (requires '-M msa') [Default = famsa]
-T : Tree inference program opt=fasttree,raxml,iqtree,... user-extendable (requires '-M msa')[Default = fasttree]
-I : MCL inflation parameter [Default 1.2]
```

### Input options

```plain text
-d  Input is DNA sequences.
-s  User-specified rooted species tree.
```

### Output options

```plain text
-X  Don’t add species names to sequence IDs.
-n     Name to append to the results directory.
-o     Specify a non-default results directory.
```

### Parallel processing options

```plain text
-t  Number of parallel sequence search threads.     All available
-a  Number of parallel analysis threads.    16 or t/8 (whichever lower)
```

### Inferring Multiple Sequence Alignment (MSA) Gene Trees

Les arbres peuvent être inférés à l’aide d’alignements multiples de séquences (MSA) en utilisant l’option « -M msa ».
Par défaut, famsa est utilisé pour générer les MSA et FastTree pour générer les arbres génétiques. Un autre programme peut être utilisé à la place (cf ci-dessus).

OrthoFinder effectue un léger filtrage des MSAs pour éviter des durées d’exécution trop longues et l’utilisation de la RAM causée par des alignements très longs et irréguliers.
Une colonne est supprimée de l’alignement si les délétions sont présentes à plus de 90 % et si deux conditions suivantes sont remplies (-z Don’t trim MSAs).

1. La longueur de l’alignement filtré ne peut pas être inférieure à 500 AA.
2. Pas plus de 25 % de délétions peuvent être supprimés de l’alignement.

Si l’une de ces conditions n’est pas remplie, le seuil du pourcentage de délétions dans les colonnes supprimées est progressivement augmenté au-delà de 90 %
jusqu’à ce que les deux conditions soient remplies. Le filtrage peut être désactivé à l’aide de l’option « -z ».

Il est important de s’assurer que l’arbre d’espèces utilisé par OrthoFinder est correcte afin de maximiser la précision des HOG.

Pour effectuer une nouvelle analyse avec un arbre d’espèces différent, utilisez les options `-ft PREVIOUS_RESULTS_DIR -s SPECIES_TREE_FILE. ## Paramètres`

Nous allons utiliser le programme OrthoFinder avec les paramètres par défaut (config.json].

* diamond: sequence search program
* DendroBLAST: gene tree inference

Mais vous pouvez utiliser n’importe quel programme d’alignement, de reconstruction d’arbre ou de comparaison de séquences que vous préférez.
Pour utiliser un autre programme, il suffit de modifier le fichier de configuration appelé config.json dans le répertoire orthofinder.
Le mieux est de créer un fichier au même format appelé config_orthofinder_user.json dans votre répertoire utilisateur.

`/usr/local/bioinfo/src/OrthoFinder/OrthoFinder-v2.5.5/scripts_of/config.json`

## Mise en œuvre

Vérifier la version d’OrthoFinder installer sur le serveur:
```bash
search_module orthofinder
```

Nous utilisons le script donné en exemple dans `/usr/local/bioinfo/src/OrthoFinder/example_on_cluster` comme modèle.

Créer un répertoire `~/work/OrthoFinder` et copier le script *test_OrthoFinder-v2.5.5.sh* dans ce répertoire en changeant pour la version utilisée.
```bash
srun --pty bash
cd work
mkdir OrthoFinder
cp /usr/local/bioinfo/src/OrthoFinder/example_on_cluster/test_OrthoFinder-v2.5.5.sh ~/work/OrthoFinder/prochlo_OrthoFinder-v2.5.5.sh
```

Le script copié `~/work/OrthoFinder/prochlo_OrthoFinder-v2.5.5.sh` est édité pour ajouter le module devel/python/Python-3.11.1,
changer le répertoire de travail (~/work/OrthoFinder2013/Prochlorococcus) et la version du programme (si nécessaire).

Diminuer le temps maximum d’exécution : `#SBATCH -t 01:30:00`
Nous utiliserons les options:
```plain text
-X -n Pro -t 16 -a 16

-X: option pour ne pas ajouter les noms des espèces aux noms des séquences.
-n: suffixe à ajouter au répertoire contenant les résultats (ex. Pro).
```

Options à utiliser dans différents runs.
```plain text
-S: programme à utiliser pour aligner les séquences.
-M: méthode pour inférer les arbres.
```

Edition du fichier `~/work/OrthoFinder/prochlo_OrthoFinder-v2.5.5.sh`
```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 01:30:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "da$
#SBATCH --cpus-per-task=16

#Warning! By default 128 threads are used on the node. Don't forget to adjust -t and -a  option of orthofinder command and --$

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -f ~/work/OrthoFinder/Prochlorococcus -X -n Pro
```

Créer un sous-répertoire Prochlorococcus et copier les fichiers peptides issues de Prokka dans ce répertoire.
```bash
mkdir ~/work/OrthoFinder/Prochlorococcus

# Creation de lien symbolique
ln -s ~/work/Zhang/Prokka/Pr*/Pr*.faa ~/work/OrthoFinder/Prochlorococcus/.

ls -l ~/work/OrthoFinder/Prochlorococcus/*.faa

mv ~/work/OrthoFinder/prochlo_OrthoFinder-v2.5.5.sh ~/work/OrthoFinder/Prochlorococcus_OrthoFinder.sh
sbatch ~/work/OrthoFinder/Prochlorococcus_OrthoFinder.sh
squeue -l -u $USER

squeue | awk -F " " '{if($5~/PD/) print $_}' |wc

ls -l ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro

grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Log.txt
```

Par défaut, OrthoFinder crée un répertoire OrthoFinder dans le répertoire du protéome d’entrée (~/work/OrthoFinder/Prochlorococcus/OrthoFinder) et y place les résultats.

Nous allons effectuer une autre analyse avec BLAST :

* création du fichier

```bash
nano ~/work/OrthoFinder/Prochlorococcus_OrthoFinder_Blast.sh
```
```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 01:30:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "da$
#SBATCH --cpus-per-task=16

#Warning! By default 128 threads are used on the node. Don't forget to adjust -t and -a  option of orthofinder command and --$

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -X -f ~/work/OrthoFinder/Prochlorococcus -n Problast -S blast
```

* lancement du fichier
```bash
sbatch ~/work/OrthoFinder/Prochlorococcus_OrthoFinder_Blast.sh
squeue -l -u $USER
```

### Fichiers de sorties

```bash
ls -l ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro
```

OrthoFinder produit un ensemble de fichiers décrivant
* les orthogroupes (OG),
* les orthologues,
* les arbres gènes,
* les arbres gènes avec les évènements de duplications/délétions,
* l’arbre des espèces enracinées,
* les évènements de duplication de gènes,
* les statistiques de génomiques comparatives pour toutes les espèces analysées.

Remarque: les fichiers .tsv d’OrthoFinder peuvent être visualisés dans un tableur comme Excel ou LibreOffice Calc.

### Résultats préliminaires

Les résultats de cette première étape sont basés sur les premières versions d’OrthoFinder (V1 Emms and Kelly, 2015).

OrthoFinder est un algorithme qui infère les orthogroupes entre plusieurs espèces.
La méthode ne nécessite pas d’informations sur la synténie et peut donc être utilisée avec des séquences de protéines prédites 1)
à partir d’ensembles de données sur le génome ou 2) le transcriptome.
Un orthogroupe est l’ensemble des gènes dérivés d’un seul gène dans le dernier ancêtre commun de toutes les espèces considérées.
Il s’agit de l’approche initialement utilisée par [OrthoMCL](http://www.genome.org/cgi/doi/10.1101/gr.1224503).

Les étapes :
* Alignement de toutes les protéines contre toutes les protéines (diamond, Mseqs2, BLAST, autre).
* Normalisation de la longueur des protéines et de la distance phylogénétique des scores (bin score du blast) pour obtenir les scores à utiliser pour l’inférence des orthogroupes.
* Sélection de paires de protéines apparentées putatifs à partir des scores normalisés.
* Construction d’un graphe d’orthogroupe, les protéines sont des sommets dans le graphe et les paires de gènes sont reliées par une arête dont le poids est donné par le score normalisé.
* Regroupement des gènes en orthogroupes discrets à l’aide de MCL (Van Dongen 2008).

Les résultats de cette première étape sont sauvegardées dans le répertoire *~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Orthogroups* .

## Vue d’ensemble

Nous avons un résumé de l’analyse réalisée dans le fichier : ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results*/Comparative_Genomics_Statistics/Statistics_Overall.tsv .
```bash
cat ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_Overall.tsv
```

* [comparative-genomics-statistics-directory](https://github.com/davidemms/OrthoFinder?tab=readme-ov-file#comparative-genomics-statistics-directory)

La plupart des termes figurant dans les fichiers ‘Statistics_Overall.csv’ et ‘Statistics_PerSpecies.csv’ sont explicites, les autres sont définis ci-dessous.

* Species-specific orthogroup : Un orthogroupe entièrement constitué de gènes d’une seule espèce.
* G50 : Le nombre de gènes dans l’orthogroupe tel que 50% des gènes sont dans des orthogroupes de cette taille ou plus.
* O50 : Le plus petit nombre d’orthogroupes tel que 50% des gènes sont dans des orthogroupes de cette taille ou plus.
* Single-copy orthogroup : Un orthogroupe comportant exactement un gène (et pas plus) de chaque espèce. Ces orthogroupes sont idéaux pour inférer un arbre des espèces et de nombreuses autres analyses.
* Unassigned gene : Un gène qui n’a pas été placé dans un orthogroupe avec d’autres gènes.

La première chose à vérifier est de savoir combien de gènes ont été assignés à des orthogroupes. En général, il est bon de voir au moins 80% des gènes assignés à des orthogroupes.

Nous pouvons également obtenir les statistiques pour chaque souche (Statistics_PerSpecies.tsv).

### Statistiques globales
```bash
cat ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv

head -n 11 ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv > ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_PerSpecies_global.tsv

srun --pty bash

module load statistics/R/4.3.0
R

library(tidyverse)
library(ggplot2)

global.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_PerSpecies_global.tsv"
global <- read.table(global.file, sep = "\t", quote = "", header = T, row.names = 1, stringsAsFactors = T, skipNul=T)
head(global)

t_global <- data.table::transpose(global)
colnames(t_global) <- rownames(global)
rownames(t_global) <- colnames(global)

t_global <- t_global %>%
  tibble::rownames_to_column(.data = .) %>%
  tibble::as_tibble(.)
head(t_global)

## Genome_and_scaffold_size
pdf_file <- '~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_PerSpecies_global.pdf'
pdf(file=pdf_file, paper="a4r")

t_global %>%
  ggplot(aes(x=`Number of genes`, y=`Number of genes in orthogroups`)) + 
    geom_point(size=2, alpha=0.5) +
    geom_abline(intercept = 0, slope = 1, linetype="dotted", color = "blue", size=0.5) + 
    theme_bw()
dev.off()
```

### Duplications

Liste des OG ayant le plus grand nombre de duplications :
```bash
sort -n -k 2 ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Duplications_per_Orthogroup.tsv
```

Distribution du nombre de duplications par OG :
```bash
awk '
BEGIN{ bin_width=1; nb=0 }
{
   if ( $1 ~ /OG/ ) { 
      bin=int($2/bin_width );
      if(bin in hist){hist[bin]+=1} else {hist[bin]=1}
      nb=nb+1;
   }
}
END{
    for (h in hist )
        printf " * > %2.2f  ->  %i %f\n", h*bin_width, hist[h], hist[h]/nb
}' < ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Duplications_per_Orthogroup.tsv | sort -n -k 3
```

### Nombre d’orthogroupes partagés

Le fichier : `~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_*/Comparative_Genomics_Statistics/Orthogroups_SpeciesOverlaps.tsv` est un fichier texte séparé
par des tabulations qui contient le nombre d’orthogroupes partagés entre chaque paire d’espèces sous forme de matrice carrée.

```bash
srun --pty bash # si nécessaire!
module load statistics/R/4.3.0
R
Orthogroups_SpeciesOverlaps <- '~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Orthogroups_SpeciesOverlaps.tsv'
 
data <- read.delim(file=Orthogroups_SpeciesOverlaps, sep="\t", header=TRUE, row.names=1)
 
pdf_file <- '~/work/OrthoFinder/Orthogroups_SpeciesOverlaps.pdf'
pdf(file=pdf_file, paper="a4r")
heatmap(t(as.matrix(data)), scale='none', xlab="Strains", labCol=NA)
dev.off()
```

>[!INFO]
>Il semble y avoir 4 grosses familles parmis les souches étudiées. Ils sont regroupés par groupes partageant le plus de groupe orthologues. Cela va dépendre de la taille du génome.
>Il s'agit d'un dendrogramme et non un arbre phylogénétique.

## Rappel sur OrthoFinder V2

Les nouvelles version d’OrthoFinder infère les HOG, les orthogroupes à chaque niveau hiérarchique (c’est-à-dire à chaque nœud de l’arbre des espèces)
en analysant les arbres des gènes enracinés.
Cette méthode d’inférence des orthogroupes est beaucoup plus précise que l’approche basée sur la similarité des gènes/graphes
utilisée par toutes les autres méthodes (Emms and Kelly, 2019).

Il repose sur les étapes suivantes :
1. Inférence d’orthogroupes à l’aide de l’algorithme original OrthoFinder V1.
2. Inférence des arbres gènes pour chaque orthogroupe.
3. Analyse de ces arbres de gènes pour en déduire l’arbre des espèces enraciné.
4. Enracinement des arbres de gènes à l’aide de l’arbre des espèces enraciné.
5. Inférence des orthologues et des évènements de duplication de gènes à l’aide des arbres gènes.
6. Cartographie des évènements de duplication de gènes sur les arbres des espèces et des gènes).

Arbre des espèces

Cet arbre a été inféré par OrthoFinder à l’aide de l’algorithme STAG (Species Tree inference from All Genes) et raciné à l’aide de l’algorithme STRIDE (Species Tree Root Inference from Gene Duplication Events). Il est donc prêt à être interprété (en général, vous devez d’abord enraciner vous-même un arbre.). Les fichiers sont :
```bash
ls -l ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_*/Species_Tree
```

* SpeciesTree_rooted.txt : Un arbre des espèces STAG déduit de tous les orthogroupes, contenant des valeurs de support STAG aux nœuds internes et enraciné à l’aide de STRIDE.
* SpeciesTree_rooted_node_labels.txt Le même arbre mais avec des étiquettes aux noeuds pour permettre de faire des références croisées entre les branches/noeuds de l’arbre des espèces (par exemple, l’emplacement des évènements de duplication de gènes).

Pour visualiser ces arbres, vous pouvez utiliser iTOL, figtree, seaview ou la librairie ape de R.
```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

Prochlorococcus_Zhang_Code.file <- "~/work/Zhang/Prochlorococcus_Zhang_Code.txt"
Prochlorococcus_Zhang_Code <- read.table(file=Prochlorococcus_Zhang_Code.file, sep="\t", row.names=1)

sptreefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Species_Tree/SpeciesTree_rooted.txt" 
sptr <- read.tree(sptreefile)
sptr$tip.label <- paste(rownames(Prochlorococcus_Zhang_Code), Prochlorococcus_Zhang_Code[sptr$tip.label, c(6)], sep="_")

pdf_file <- '~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Species_Tree/SpeciesTree_rooted.pdf'
pdf(file=pdf_file, paper="a4r")
 
plot(sptr)
dev.off()
 
treefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Species_Tree/SpeciesTree_rooted_node_labels.txt" 
tr <- read.tree(treefile)
tr$tip.label <- paste(rownames(Prochlorococcus_Zhang_Code), Prochlorococcus_Zhang_Code[tr$tip.label, c(6)], sep="_")

pdf_file <- '~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Species_Tree/SpeciesTree_rooted_node_labels.pdf'
pdf(file=pdf_file, paper="a4r")
 
plot(tr, show.node.label=T)
dev.off()
```

L’arbre enraciné obtenu est très déséquilibré.

### Orthogroupes à chaque niveau hiérarchique

Le répertoire Phylogenetic_Hierarchical_Orthogroups renferme un fichier par nœud de l’arbre espèce.
Le fichier N0.tsv correspond à la racine de l’arbre. Chaque ligne renferme les gènes qui appartiennent à un unique orthogroup identifié par un HOG ID.
Ce fichier remplace avantageusement les orthogroups identifiés par la première étape (MCL)!

Le nombre de HOG du fichier N0.tsv est à comparer aux données du fichier Statistics_Overall.tsv.
```bash
grep 'HOG' -c  ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Phylogenetic_Hierarchical_Orthogroups/N0.tsv

grep 'Number of orthogroups' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_Overall.tsv
```

L’enracinement de l’arbre conduit à une augmentation du nombre de OG. Certains des OG identifiés par MCL ont été redécoupés.

```bash
awk '{ if ($2~"OG0000017") print $0}' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Phylogenetic_Hierarchical_Orthogroups/N*.tsv
```
nous donne la décomposition de OG0000017 en HOG sur les différentes feuilles de l’arbre espèces.

### Somme des évènements de duplication

Le fichier SpeciesTree_Gene_Duplications_0.5_Support.txt indique à chaque noeud de l’arbre le nombre d’évènements de duplication (numéro du noeud suivit du nombre).
Les duplications sont considérées comme bien supportées si au moins 50% des espèces présentes chez les deux descendants ont retenues les deux copies du gène dupliqué.
```bash
R
library(ape)
treefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.txt" 
tr <- read.tree(treefile)
pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.pdf"
pdf(file=pdf_file, paper="a4")
plot(tr, show.node.label=T)
dev.off()
q()
y
```

On remarque qu'il y a beaucoup plus de duplications au niveau des feuilles qu'au niveau des noeuds.

### Comparaison des résultats obtenus avec différents paramètres

Vous pouvez utiliser n’importe quel programme d’alignement ou d’inférence d’arbre que vous préférez !
Par exemple, pour utiliser muscle et iqtree, les commandes comme les arguments que vous devez ajouter sont les suivants : `-M msa -A muscle -T iqtree`

Il est nécessaire d’ajouter le module bioinfo/NCBI_Blast+/2.2.28 pour utiliser BlastP.

Paramètres:
```text plain
-M msa : trees are inferred using multiple sequence alignments (MSA) by using the option. By default MAFFT is used to generate the MSAs and FastTree to generate the gene trees. 
```

Exemples (effectuées plus en avant):
```bash
orthofinder.py -X -n Pronmsa -t 16 -a 16 -b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory -M msa
orthofinder -t 16 -a 16 -X -f ~/work/OrthoFinder/Prochlorococcus -n Problast -S blast
```

Nous allons créer les fichiers pour l'alignement avec MSA à partir des résultats de Diamond (mode défaut et non blast).

Création du fichier `~/work/OrthoFinder/Prochlorococcus_OrthoFinder_msa.sh`:
```bash
nano ~/work/OrthoFinder/Prochlorococcus_OrthoFinder_msa.sh
```
```bash
#!/bin/bash
#SBATCH -J OFPromsa
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH --cpus-per-task=16

# Don't forget to adjust -t and -a  option of orthofinder command 
# and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -X -n Pronmsa -b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory -M msa
```
```bash
sbatch ~/work/OrthoFinder/Prochlorococcus_OrthoFinder_msa.sh
squeue -u $USER
```

Dans le cas où l'on veut utiliser OrthoFinder v3, le format du fichier est le suivant :
```bash
#!/bin/bash
#SBATCH -J OFPromsa2
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o OFPrommsa2.out
#SBATCH -e OFPrommsa2.err
#SBATCH --cpus-per-task=16

# Don't forget to adjust -t and -a  option of orthofinder command 
# and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load devel/python/Python-3.11.1
module load bioinfo/OrthoFinder/3.0.1b1

orthofinder.py -X -n Pronmsa -t 16 -a 16 -b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory -M msa
```

```bash
grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Log.txt
grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_Pronmsa/Log.txt
grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Problast/Log.txt
```

blast & msa: Statistics_Overall.tsv 

```bash
grep -P "^Number of orthogroups\t|Percentage of genes in orthogroups"  ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_Overall.tsv
grep -P "^Number of orthogroups\t|Percentage of genes in orthogroups" ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_Pronmsa/Comparative_Genomics_Statistics/Statistics_Overall.tsv
grep -P "^Number of orthogroups\t|Percentage of genes in orthogroups"  ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Problast/Comparative_Genomics_Statistics/Statistics_Overall.tsv
```

* default
	* Percentage of genes in orthogroups  98.4
	* Number of orthogroups   4349

* msa
	* Percentage of genes in orthogroups  98.4
	* Number of orthogroups   4349

* blast
	* Percentage of genes in orthogroups  98.5
	* Number of orthogroups   4269

Nous n’irons pas plus loin dans l’analyse de ces résultats préliminaires. Nous ajouterons les génomes de Synechococcus pour une analyse plus complète, comparable à celle de Zhang.

## Ajout des Synechococcus

OrthoFinder permet l’ajout de nouveaux génomes sans avoir à recalculer les comparaisons all vs all déjà réalisées.

Les fichiers de séquences d’ADN des génomes Synechococcus sont copiés dans un nouveau répertoire.
```bash
mkdir ~/work/OrthoFinder/Synechococcus

#Creation de lien symbolique
ln -s ~/work/Zhang/Prokka/Sy*/Sy*.faa ~/work/OrthoFinder/Synechococcus/

ls ~/work/OrthoFinder/Synechococcus/*.faa | wc -l
```

Copie et édition du script pour lancer OrthoFinder.
```bash
cp ~/work/OrthoFinder/Prochlorococcus_OrthoFinder_msa.sh ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa.sh

# supprimer ce fichier s'il est présent!
rm ~/work/Zhang/Prokka/Syat/Syat.IS.tmp.2408106.faa
```

Edition du fichier pour ajouter
```text plain
-b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory 
-f ~/work/OrthoFinder/Synechococcus 
-n ProSynmsa 
-M msa.
```

Creation du fichier `~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa.sh` :
```bash
nano ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa.sh
```
```bash
#!/bin/bash
#SBATCH -J OFProSymmsa
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH --cpus-per-task=16

# Don't forget to adjust -t and -a  option of orthofinder command 
# and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -X -n ProSynmsa -f ~/work/OrthoFinder/Synechococcus -b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory -M msa
```
```bash
sbatch ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa.sh
squeue -u $USER
```
```bash
grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Log.txt
```

Les résultats sont attendu dans le répertoire : *~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa*

```bash
head ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Comparative_Genomics_Statistics/Statistics_Overall.tsv
```

>Number of species 60 Number of genes 137548 Number of genes in orthogroups 132606 Number of unassigned genes 4942 Percentage of genes in orthogroups 96.4

## Enracinement de l’arbre

Arbre espèces estimé par OrthoFinder
```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

Prochlorococcus_Zhang_Code.file <- "~/work/Zhang/Prochlorococcus_Zhang_Code.txt"
Synechococcus_Zhang_Code.file <- "~/work/Zhang/Synechococcus_Zhang_Code.txt"

ortotreefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rooted.txt" 
orttr <- read.tree(ortotreefile)
orttr$tip.label

# un nom de souche n'est pas canonique: Syat.IS.tmp.2408106! 
orttr$tip.label <- substr(orttr$tip.label,1,4)

Prochlorococcus_Zhang_Code.file <- "~/work/Zhang/Prochlorococcus_Zhang_Code.txt"
Synechococcus_Zhang_Code.file <- "~/work/Zhang/Synechococcus_Zhang_Code.txt"
Prochlorococcus_Zhang_Code <- read.table(file=Prochlorococcus_Zhang_Code.file, sep="\t", row.names=1)
Synechococcus_Zhang_Code <- read.table(file=Synechococcus_Zhang_Code.file, sep="\t", row.names=1)
Zhang_Code <- rbind(Prochlorococcus_Zhang_Code, Synechococcus_Zhang_Code)

new.labels <- paste(Zhang_Code[orttr$tip.label, c(6)], substr(Zhang_Code[orttr$tip.label, c(14)], 8, 20), sep="_")
orttr$tip.label <- new.labels

# plot tree
pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rooted.pdf"
pdf(file=pdf_file, paper="a4")
plot(orttr, edge.color="purple", edge.width=1, node.color= "grey", cex = 0.5, no.margin=FALSE, show.node.label=TRUE, tip.color="blue")
dev.off()

q()
y
```

L’arbre n’est pas correctement enraciné par OrthoFinder. Les génomes de Synechococcus doivent être placés en groupe externe des génomes de Prochlorococcus.

Il est important de s’assurer que l’arbre des espèces utilisé par OrthoFinder est correct afin de maximiser la précision du HOG.

Nous allons donc modifier la façon dont l’arbre est enraciné.

Dans l’arbre de Zhang et al., 2021, les génomes suivants sont situés dans le groupe extérieur : PCC 7001, GFB01, CB010, CB0205, PCC 6307, WH 5701.
```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

Prochlorococcus_Zhang_Code.file <- "~/work/Zhang/Prochlorococcus_Zhang_Code.txt"
Synechococcus_Zhang_Code.file <- "~/work/Zhang/Synechococcus_Zhang_Code.txt"
Prochlorococcus_Zhang_Code <- read.table(file=Prochlorococcus_Zhang_Code.file, sep="\t", row.names=1)
Synechococcus_Zhang_Code <- read.table(file=Synechococcus_Zhang_Code.file, sep="\t", row.names=1)
Zhang_Code <- rbind(Prochlorococcus_Zhang_Code, Synechococcus_Zhang_Code)

treefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rooted.txt" 
tr <- read.tree(treefile)

# creation du outgroup
Zhang_Code[Zhang_Code[14] %in% c("strain=PCC 7001"), ]
List <- c("strain=PCC 7001", "strain=GFB01", "strain=CB0101", "strain=CB0205", "strain=PCC 6307", "strain=WH 5701")
Zhang_Code %>% 
  filter(V15 %in% List) %>% 
  select(V15)

outgroup <- row.names(Zhang_Code %>% 
  filter(V15 %in% List))

# reroot with ape root function
rtr <- root(tr, outgroup=outgroup, resolve.root=TRUE)

rtr_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rerooted.txt"
write.tree(rtr, file=rtr_file)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rerooted.pdf"
pdf(file=pdf_file, paper="a4")
plot(rtr, show.node.label=T)
dev.off()

q()
y
```

### OrthoFinder avec l’arbre espèces correctement enraciné

Pour effectuer une nouvelle analyse avec un arbre espèces différent de celui estimé par OrthoFinder, utilisez les options `-ft PREVIOUS_RESULTS_DIR -s SPECIES_TREE_FILE`.

Cela permet de n’effectuer que les étapes finales de l’analyse phylogénétique. C’est relativement rapide.
```bash
cp ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa.sh ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa_reroot.sh
```
Editez `~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa_reroot.sh` et ajoutez:
```bash
orthofinder -t 5 -a 5 -X \
-ft ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa \
-s ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rerooted.txt \
-n ProSynmsaroot \
-M msa
```

```bash
nano ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa_reroot.sh
```
```bash
#!/bin/bash
#SBATCH -J OFProSymmsa
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH --cpus-per-task=16

# Don't forget to adjust -t and -a  option of orthofinder command 
# and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 5 -a 5 -X \
-ft ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa \
-s ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rerooted.txt \
-n ProSynmsaroot \
-M msa
```
```bash
sbatch ~/work/OrthoFinder/prochlo_synecho_OrthoFinder_msa_reroot.sh
squeue -u $USER

grep -E 'Started|complet' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Log.txt
```

Results: ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/

```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

uptreefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Species_Tree/SpeciesTree_rooted_node_labels.txt" 
uptr <- read.tree(uptreefile)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Species_Tree/SpeciesTree_rooted_node_labels.pdf"
pdf(file=pdf_file, paper="a4")
plot(uptr, show.node.label=T)
dev.off()

q()
y
```

Avec l’enracinement TreeTools

Results: ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/

```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

uptreefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Species_Tree/SpeciesTree_rooted_node_labels.txt" 
uptr <- read.tree(uptreefile)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Species_Tree/SpeciesTree_rooted_node_labels.pdf"
pdf(file=pdf_file, paper="a4")
plot(uptr, show.node.label=T)
dev.off()

q()
y
```

### Duplications par Orthogroups

```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
if (!require('ggplot2')) {install.packages('ggplot2')}
33
if (!require('tidyverse')) {install.packages('tidyverse')}
33
library(ape)
library(ggplot2)
library(tidyverse)

Orthogroup.Duplications.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Comparative_Genomics_Statistics/Duplications_per_Orthogroup.tsv"
Orthogroup.Duplications.root.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Comparative_Genomics_Statistics/Duplications_per_Orthogroup.tsv"

Orthogroup.Duplications <- read.table(Orthogroup.Duplications.file, sep = "\t", quote = "", header = T)
Orthogroup.Duplications.root <- read.table(Orthogroup.Duplications.root.file, sep = "\t", quote = "", header = T)

colnames(Orthogroup.Duplications.root) <-c ("Orthogroup", "Duplications..all.root", "Duplications..50..support.root")
Orthogroup.Duplications.join <- inner_join(Orthogroup.Duplications, Orthogroup.Duplications.root)

p <- ggplot(Orthogroup.Duplications.join, aes(x=Duplications..50..support., y=Duplications..50..support.root, color="coral")) + 
    geom_point(size=2, alpha=0.5) +
    geom_abline(intercept = 0, slope = 1, linetype="dotted", color = "blue", size=0.5) + 
    theme_bw()

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Comparative_Genomics_Statistics/Orthogroup_Duplications_join.pdf"
pdf(file=pdf_file, paper="a4")
plot(p)
dev.off()

q()
y
```

### Duplications par nœuds de l’arbre espèces

Duplications aux nœuds:
```bash
~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Comparative_Genomics_Statistics/Duplications_per_Species_Tree_Node.tsv
```

Arbre espèces avec les duplications aux nœuds:
```bash
module load statistics/R/4.3.0
R
if (!require('ape')) {install.packages('ape')}
33
library(ape)

treefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.txt" 
tr <- read.tree(treefile)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.pdf"
pdf(file=pdf_file, paper="a4")
plot(tr, show.node.label=T)
dev.off()

treefile <-"~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.txt" 
rtr <- read.tree(treefile)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.pdf"
pdf(file=pdf_file, paper="a4")
plot(rtr, show.node.label=T)
dev.off()

q()
y
```

### Matrice de présence absence

```bash
module load statistics/R/4.3.0
R

Orthogroups.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Orthogroups/Orthogroups.tsv"
Orthogroups <- read.table(Orthogroups.file, sep = "\t", quote = "", header = T, row.names=1)
Orthogroups[Orthogroups!=""] <- 1
Orthogroups[Orthogroups==""] <- 0

Orthogroups.met <- apply(as.matrix(Orthogroups), 2, as.numeric)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Orthogroups_matrice01.pdf"
pdf(file=pdf_file, paper="a4")
heatmap(t(Orthogroups.met), scale='none', col=c('white', 'darkblue'), xlab="Genomes", labCol=NA, cexRow=0.3)
dev.off()

q()
y
```

Réordonner les lignes et les colonnes à l’aide d’une classification automatique utilisant une distance binaire.

Le calcul de la matrice de distance demande un peu plus de mémoire. Utiliser :
```bash
srun --mem=10G --pty bash

module load statistics/R/4.3.0
R

library(ade4)

Orthogroups.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Orthogroups/Orthogroups.tsv"

Orthogroups <- read.table(Orthogroups.file, sep = "\t", quote = "", header = T, row.names=1)
Orthogroups[Orthogroups!=""] <- 1
Orthogroups[Orthogroups==""] <- 0
Orthogroups.met <- apply(as.matrix(Orthogroups), 2, as.numeric)
rownames(Orthogroups.met) <- rownames(Orthogroups)

# 1  Jaccard, 2 Sokal & Michener , 3 Sokal & Sneath, 4 Rogers & Tanimoto, 5 Dice, 6 Hamann coefficient, 7 Ochiai,  8 Sokal & Sneath, 9 Phi of Pearson, 10 S2 coefficient of Gower & Legendre

method <- 1
Orthogroups.met[Orthogroups.met>1] <- 1

binary <- Orthogroups.met
tbinary <- t(Orthogroups.met)

dist_mat <- dist.binary(binary, method = method, diag = TRUE, upper = TRUE)
col_dend <- hclust(dist_mat, method="ward.D2")
#plot(as.dendrogram(col_dend), horiz = TRUE)

tdist_mat <- dist.binary(tbinary, method = method, diag = TRUE, upper = TRUE)
row_dend <- hclust(tdist_mat, method="ward.D2")
#plot(as.dendrogram(row_dend), horiz = TRUE)

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Orthogroups/Orthogroups_matrice01_binary.pdf"
pdf(file=pdf_file, paper="a4")
heatmap(tbinary, Rowv = as.dendrogram(row_dend), Colv = as.dendrogram(col_dend), scale='none', col=c('white', 'darkblue'), xlab="Genomes", labCol=NA, cexRow=0.3)
dev.off()

q()
y
```

### Sélectionner un sous ensemble de OG en fonction de leur fréquences dans les génomes

À titre d’exemple, nous sélectionnerons les groupes de gènes orthologues présents dans Prochlorococcus mais absents dans Synechococcus.
Pour obtenir l’annotation fonctionnelle des gènes, nous utiliserons les annotations eggNOG.

À l’inverse, sélectionnez les gènes qui ont été perdus lors de la transition de Synechococcus à Prochlorococcus.

---

Arbre avec Prochlorococcus (~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Species_Tree/SpeciesTree_rooted.pdf)

les génomes appartenant au même écotype sont similaires sauf 1 : l'analyse des duplications ne permet pas d'enraciner correctement l'arbre espèce, donc deux options :
--> on cherche un outgroup
--> on implémente un arbre que l'on considère comme bien enraciné

On va utiliser les Synechococcus qui ne font pas partie du groupe d'intérêt mais au plus proche, cela afin d'avoir de longues branches et donc de mauvaises estimations de l'arbre.
On peut utiliser l'outgroup pour l'enraciner puis supprimer l'outgroup et refaire le calcul des scores sans l'outgroup mais l'arbre étant correctement enraciné.

On observe des valeurs de bootstrap entre 0 et 1, il est paramétrique et calculé avec FastTree.

~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Species_Tree/SpeciesTree_rooted_node_labels.pdf

~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Comparative_Genomics_Statistics/Orthogroup_Duplications_join.pdf
50% support : nécessite qu'il y ait au moins 50% des espèces de chaque côté des branches (valide la duplication)
Titre : Liens entre le nbre de duplications avec et sans enracinement de l'arbre.

Utilisation blast par rapport à diamond :
Il y a peu de différences, blast plus sensible mais au dépend d'un temps de calcul plus important que diamond --> utilisation de diamond

Heatmap
* ligne : genome
* colonne : orthogroupe
* couleur : présence/absence (on peut avoir des paralogues dans le fichier, donc on se base sur 0 ou 1 pour n'avoir que les orthologues)
Pour vérifier la présence/absence, on calcule une distance (ici euclidienne).
La présence du HOG dans tous les génomes indique le génome coeur (95% de seuil pour génome core car les génomes sont incomplets).
On identifie clairement le génome accessoire (présence éparse de la couleur).
On observe également des HOG présents uniquement chez les Synechococcus correspondant au genome shell (spécifique).

L'étude du génome coeur permet de retracer l'arbre espèce, tandis que celle du génome accessoire permet d'identifier les adaptations aux différents milieux.

On cherche à connaître le schéma évolutif de Synechococcus vers Prochlorococcus. On peut calculer diverses statistiques pour cela.
On observe des pertes de gènes chez Prochlorococcus, on peut faire un blast sur les séquences gagnées au cours de l'évolution par transfert horizontal pour identifier l'espèce donneuse.
On peut comparer les clusters avec les fonctions des gènes (annotation fonctionnelle) pour enrichir le modèle évolutif.

---

# Analyses pan-génomiques

modified 2025-10-16

## Introduction
Les analyses pan-génomiques fournissent un cadre pour déterminer la diversité génomique de l’ensemble des génomes analysés, mais aussi pour prédire, par extrapolation, combien de séquences génomiques supplémentaires seraient nécessaires pour caractériser l’ensemble du pan-génome ou répertoire génétique.

[Inside the Pan-genome - Methods and Software Overview](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4765519/)

## Définitions

D’après Vernikos et al. 2015

Le pan-génome a été défini pour la première fois par Tettelin et al., 2005.

* le pan-génome englobe l’ensemble du répertoire de gènes accessibles au clade étudié ;
* le génome coeur contient les gènes communs à toutes les souches du clade et comprend généralement des gènes responsables des aspects fondamentaux de la biologie du clade et de ses principaux traits phénotypiques ;
* le génome accessoire est constitué des gènes communs à un sous-ensemble de souches et contribue à la diversité des espèces. Il peut coder des voies biochimiques supplémentaires et des fonctions qui ne sont pas essentielles à la croissance mais qui confèrent des avantages sélectifs, comme l’adaptation à différentes niches, la résistance antibiotique ou la colonisation d’un nouvel hôte Medini et al.’, 2005.
* les gènes spécifiques d’une souche ou singletons désignent des gènes spécifiques à une souche n’ayant par d’orthologues dans les autres souches du clade.

## Tracé de l’histogramme
Nous allons extraire la distribution des 40 génomes Prochlorococcus dans les orthogroupes OrthoFinder à partir du fichier `~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_Overall.tsv`
```bash
awk -F "\t" 'BEGIN {K=0}
{
  if($1~/Number of species in orthogroup/) {K=1}
  if(K>0) {print $0}
}' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/Statistics_Overall.tsv > ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/species_in_OG.txt
```

Tracé de l’histogramme:
```bash
module load statistics/R/4.3.0
R

library(tidyverse)
library(ggplot2)

species_in_OG.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/species_in_OG.txt"
species_in_OG <- read.table(species_in_OG.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

pdf_file <- '~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Comparative_Genomics_Statistics/species_in_OG.pdf'
pdf(file=pdf_file, paper="a4r")

ggplot(species_in_OG, aes(x=Number.of.species.in.orthogroup, y=Number.of.orthogroups)) + 
  geom_bar(stat = "identity", width=0.2)  + 
    theme_bw()
dev.off()

q()
y
```

## Taille du pan génome

La taille du pan génome à tendance à augmenter avec le nombre de génomes comparés (pour une revue: Tettelin et al., 2008.

Estimer sa taille est un exemple d’une classe générale de mesures où, étant donné une collection d’entités et leurs attributs,
le nombre d’attributs distincts observés est fonction du nombre d’entités considérées. C’est par exemple le cas de l’analyse du langage naturel,
où les entités sont les textes et les attributs sont les mots. Dans ce contexte, l’augmentation du nombre n d’attributs distincts en fonction du nombre N
d’entités considérées suit la loi de Heaps (Heaps ’law).

Elle peut être représentée par la formule : n=k*N-α, où, dans un contexte génétique, n est le nombre attendu de gènes pour un nombre N de génomes
et les paramètres k et α (α=1-γ) sont des paramètres libres qui sont déterminés empiriquement Tettelin et al., 2008.

Appliqué à la découverte de nouveaux gènes et selon la loi de Heap, lorsque α > 1 (γ < 0), le pan-génome est considéré comme fermé,
et l’ajout de nouveaux génomes n’augmentera pas significativement le nombre de nouveaux gènes. Par contre, lorsque α < 1 (0 < γ < 1), le pan-génome est ouvert,
et pour chaque nouveau génome ajouté, le nombre de gènes augmente significativement Tettelin et al., 2008.

Pour déterminer les paramètres k et α nous pouvons calculer toutes les combinaisons de 2 à N génomes et reporter la taille du pan génome pour chaque combinaison.
Cependant, comme le nombre de combinaisons augmente très rapidement avec le nombre de génomes (C=N!/(n−1)!⋅(N−n), en pratique un échantillonnage des combinaisons possible est réalisé.

Téléchargement du script [panplots](https://github.com/SioStef/panplots?tab=readme-ov-file)

```bash
cd ~/work
git clone https://github.com/SioStef/panplots.git
```

A small R script for generating pangenome accumulation curves

The output is a table summerizing the permutation results using “matrixStats” R package (https://github.com/HenrikBengtsson/matrixStats).

* data = a matrix with gene cluster presence-absence data with genomes as rows and gene clusters as columns.
* curve = type of curve data to generate:
	* “pan” for gene cluster accumulation curve,
	* “core” for core genome accumulation curve,
	* “uniq” for unique gene clusters accumulation curve (default “pan”).
* iterations = the number of random genome permutations (default 100).

```bash
R
if (!require('matrixStats')) {install.packages('matrixStats')}
33
if (!require('plyr')) {install.packages('plyr')}
33
library(matrixStats)
source("~/work/panplots/panplots.R")
library(plyr)
library(tidyverse)

Orthogroups.GeneCount.file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Orthogroups/Orthogroups.GeneCount.tsv"
Orthogroups.GeneCount.ori <- read.table(Orthogroups.GeneCount.file, sep = "\t", quote = "", header = T, row.names = 1)

# binary code
Orthogroups.GeneCount <-  ifelse(Orthogroups.GeneCount.ori[,1:ncol(Orthogroups.GeneCount.ori)] > 0, 1, 0)
Orthogroups.GeneCount <- as.data.frame(Orthogroups.GeneCount)

t_Orthogroups.GeneCount <- data.table::transpose(Orthogroups.GeneCount)
colnames(t_Orthogroups.GeneCount) <- rownames(Orthogroups.GeneCount)
#head(t_Orthogroups.GeneCount)

pan_curve <- panplots(as.matrix(t_Orthogroups.GeneCount), curve="pan")
core_curve <- panplots(as.matrix(t_Orthogroups.GeneCount), curve="core")

pan_core <- full_join(pan_curve, core_curve, by=c("genomes"))

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Orthogroups/pan_core.pdf"
pdf(file=pdf_file, paper="a4")
ggplot(pan_core, aes(x=genomes, y=mean.x)) + 
  geom_point(col="red") +
  geom_errorbar(aes(ymin=mean.x-sd.x, ymax=mean.x+sd.x), width=.2, position=position_dodge(0.05)) + 
  geom_hline(yintercept=pan_curve$mean[40], col="orange") +
  geom_point(aes(x=genomes, y=mean.y), col="blue") +
  geom_errorbar(aes(ymin=mean.y-sd.y, ymax=mean.y+sd.y), width=.2, position=position_dodge(0.05)) + 
  geom_hline(yintercept=core_curve$mean[40], col="green") +
  theme_bw()
dev.off()
```

Les plateaux des pan et core génomes sont respectivement 4349 et 1218 gènes.

Sélection des génomes de Kettler:
```bash
Orthogroups.GeneCount_Zhang <- Orthogroups.GeneCount %>% 
  select(Prab, Prai, Prae, Praa, Prau, Prag, Prbb, Praj, Prak, Prat, Praf, Prah)

t_Orthogroups.GeneCount_Zhang <- data.table::transpose(Orthogroups.GeneCount_Zhang)
colnames(t_Orthogroups.GeneCount_Zhang) <- rownames(Orthogroups.GeneCount_Zhang)

Zhang_pan_curve <- panplots(as.matrix(t_Orthogroups.GeneCount_Zhang), curve="pan")
Zhang_core_curve <- panplots(as.matrix(t_Orthogroups.GeneCount_Zhang), curve="core")

Zhang_pan_core <- full_join(Zhang_pan_curve, Zhang_core_curve, by=c("genomes"))

pdf_file <- "~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/Orthogroups/Zhang_pan_core.pdf"
pdf(file=pdf_file, paper="a4")
ggplot(Zhang_pan_core, aes(x=genomes, y=mean.x)) + 
  geom_point(col="red") +
  geom_errorbar(aes(ymin=mean.x-sd.x, ymax=mean.x+sd.x), width=.2, position=position_dodge(0.05)) + 
  geom_hline(yintercept=pan_curve$mean[40], col="orange") +
  geom_point(aes(x=genomes, y=mean.y), col="blue") +
  geom_errorbar(aes(ymin=mean.y-sd.y, ymax=mean.y+sd.y), width=.2, position=position_dodge(0.05)) + 
  geom_hline(yintercept=core_curve$mean[40], col="green") +
  theme_bw()
dev.off()

q()
y
```

## Critique de l’approche

Les méthodes d’analyse des schémas de présence/absence de gènes ne tiennent généralement pas compte des erreurs introduites dans l’annotation et le regroupement automatisés des séquences de gènes.
En particulier, les méthodes adaptées des études écologiques, y compris la courbe d’accumulation des gènes du pangénome, peuvent être trompeuses car
elles peuvent refléter la diversité sous-jacente dans l’échantillonnage temporel des génomes plutôt qu’une différence dans la dynamique des HGT.

Tonkin-Hill et al.  présentent une méthode basée sur la régression linéaire généralisée qui est robuste à la structure de la population, au biais d’échantillonnage
et aux erreurs dans la prédiction de la présence ou de l’absence des gènes. Ils démontrent à l’aide de simulations et en analysant plusieurs ensembles de données
de génomes bactériens que le package R Panstripe, qu’ils ont développé, peut identifier efficacement les différences dans le taux et le nombre de gènes impliqués dans les événements HGT.

# Super-alignement séléction des familles

modified 2025-10-16

## Introduction
Nous allons créer un sous ensemble de gènes conservée chez Prochlorococcus pour expérimenter les différentes méthodes de reconstruction phylogénomiques.

Pour faire de la concaténation pour la construction de l'arbre espèce, on doit prendre suffisamment de représentants (génome coeur) de groupes orthologues.
Cependant, il existe les paralogues. Il faudra les retirer de l'analyse.
Dans le cas de groupes proches, on étudie l'ADN et dans le cas de groupes éloignés, on étudie les séquences protéiques.
Il faut utiliser un algorithme qui identifie les codons pour ne pas décaler le cadre de lecture ouverte.
On aligne alors en séquence protéique avant de repasser en ADNc pour ne pas perdre l'information sur l'ORF et donc les codons.
On peut utiliser TCoffee pour sélectionner les meilleurs alignements.
On sélectionne 100 familles de protéines puis on calcule les scores et on sélectionne les 30 meilleures.
Dans le cas où 

## Utilisation des résultats d’OrthoFinder

* [Orhogroup Sequences Orhogroup Sequences](https://github.com/davidemms/OrthoFinder?tab=readme-ov-file#orthogroup-sequences)

Le répertoire Orthogroup_Sequences renferme un fichier FASTA pour chaque orthogroupe avec les séquences d’acides aminés pour chaque gène de l’orthogroupe.
```bash
ll ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsa/Orthogroup_Sequences/
```

Nous ne pouvons pas les utiliser car pour créer des arbres d’espèces, nous utiliserons des séquences de nucléotides.
Nous devons donc extraire ces séquences pour chaque gène de chaque OG. Nous trouverons la liste des noms de gènes dans les HOG de premier niveau (N0).
```bash
head -n 1 ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Phylogenetic_Hierarchical_Orthogroups/N0.tsv
```

Nous nous limiterons aux 12 souches de Kettler.
```bash
srun --pty bash

mkdir ~/work/Kettler
for strain in MED4 'MIT 9515' 'MIT 9301' AS9601 'MIT 9215' 'MIT 9312' NATL1A NATL2A SS120 'MIT 9211' 'MIT 9303' 'MIT 9313';  
do
 code=$(grep "$strain" ~/work/Zhang/Prochlorococcus_Zhang_Code.txt | cut -f 1);
 echo $code
done > ~/work/Kettler/code.lst
wc -l ~/work/Kettler/code.lst
```

## Extraction des OG du génome coeur des 12 souches de kettler.

Filtrer les OG renfermant au moins un gène pour chaqu’une des 12 souches de kettler. Écarter la présence de paralogues qui sont séparés par des ‘,’.
```bash
awk -F "\t" '{ 
if($4!="" && $5!="" && $8!="" && $9!="" && $10!="" &&  $11!="" && $12!="" && $13!="" && $14!="" &&   $23!="" && $24!="" && $31!="")
print $1, $4, $5, $8, $9, $10, $11, $12, $13, $14, $23, $24, $31}' ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory/OrthoFinder/Results_ProSynmsaroot/Phylogenetic_Hierarchical_Orthogroups/N0.tsv > ~/work/Kettler/N0_Kettler.txt

wc -l ~/work/Kettler/N0_Kettler.txt

grep -v ',' ~/work/Kettler/N0_Kettler.txt > ~/work/Kettler/N0_Kettler_uniq.txt
wc -l ~/work/Kettler/N0_Kettler_uniq.txt
```

Vérifier que tous les gènes sont présents dans les 12 génomes.
```bash
awk '{
HOG=$1
for (i = 1; i <= NF; i++) {
  if ($i != "")
    count[i]++;
    col[i] = $i;
  }
}
END {
  for (i = 1; i <= NF; i++)
  print count[i];
}' ~/work/Kettler/N0_Kettler_uniq.txt
```

## Concaténation des fichiers FASTA des protéomes

Pour accélérer les extractions de séquences à partir des fichiers FASTA de chaque génome, nous allons les regrouper dans un seul fichier.
```bash
prkdir=~/work/Zhang/Prokka
dnadir=~/work/Kettler/DNA

if [[ ! -d $dnadir ]]; then
  mkdir $dnadir
fi
 
if [[ -e $dnadir/combined_dna.ffn ]]; then
  rm $dnadir/combined_dna.ffn
fi

while IFS= read -r ip; do
  if [[ -e $prkdir/$ip/$ip.ffn ]]; then
    cat $prkdir/$ip/$ip.ffn >> $dnadir/combined_dna.ffn
  else 
    echo error is not found $prkdir/$ip/$ip.ffn!
  fi
done < ~/work/Kettler/code.lst

grep -c '>' $dnadir/combined_dna.ffn
```

Exemple d’extraction de la séquence de Praa.g_00983.
```bash
awk -v seq="Praa.g_00983" -v RS='>' '$1 == seq {print RS $0}' $dnadir/combined_dna.ffn
```

Application à tous les gènes sélectionnés.
```bash
dnadir=~/work/Kettler/DNA
ogdir=~/work/Kettler/OG

if [[ ! -d $ogdir ]]; then
  mkdir $ogdir
fi

while IFS=" " read -a ar; do
  if [[ ${ar[0]} == "HOG" ]]; then
    echo "skip $ar"
  else
    for code in "${ar[@]}"; do 
      if [[ $code =~ N0 ]]; then
        output=$ogdir/$code.ffn
        echo "$output"
      else
        awk -v seq="$code" -v RS='>' '$1 == seq {print RS $0}' $dnadir/combined_dna.ffn >> $output
      fi
    done
  fi
done < ~/work/Kettler/N0_Kettler_uniq.txt
```

## Transformation en alignement multiples des séquences ADN des gènes

Le script aa_to_dna_aln.pl (package BioPerl Bio::Align::Utilities prend en entrée un fichier en format FASTA contenant des séquences d’ADN. Il traduit les séquences en peptides, réalise un alignement multiple avec muscle et retraduit en ADN cet alignement multiple.
```bash
ogdir=~/work/Kettler/OG
if [[ ! -d $ogdir/alignment ]]; then 
  mkdir $ogdir/alignment
fi
```

Test du programme
```bash
 ~/work/scripts/aa_to_dna_aln.pl -dna $ogdir/N0.HOG0001432.ffn --outdir $ogdir/alignment
```

En sortie:
* `~/work/Kettler/OG/alignment/pep_*.ffn`       peptides
* `~/work/Kettler/OG/alignment/ali_pep_*.ffn`   alignement des peptides
* `~/work/Kettler/OG/alignment/ali_dna_*.ffn`   alignement des nucléotides

## Échantillonnage des HOG et alignement

Tirage aléatoire de 100 valeurs dans intervalle [1, nb files].
```bash
nbfiles=$( ls $ogdir/*.ffn | wc -l )
echo $nbfiles

for i in $(seq 1 100);
do
  random[ $i ]=$((1 + $RANDOM % $nbfiles))
done
echo ${random[@]}
```

Sélection des 100 fichiers et construction des commandes pour exécuter aa_to_dna_aln sur ces fichiers
```bash
ogdir=~/work/Kettler/OG

i=0
j=0
while read line
do
    if [[ ${random[$i]} != "" ]];
    then
      echo ${random[$i]}
      selection[$j]="$line"
    (( j++ ))
    fi
    (( i++ ))
done < <(ls $ogdir/*.ffn)
echo ${#selection[@]}

rm $ogdir/alignment/*N0.HOG0001432*

for i in ${selection[@]}
do 
  ip=$(basename $i .ffn)     
  echo "~/work/scripts/aa_to_dna_aln.pl -dna $ogdir/$ip.ffn --outdir $ogdir/alignment;" 
done > ~/work/Kettler/OG_t_coffee_TCS.sh
```

Lancement de la commande
```bash
sarray -J TCS -o %j.out -e %j.err -t 01:00:00 --cpus-per-task=1  ~/work/Kettler/OG_t_coffee_TCS.sh
squeue -l -u $USER
```

## Evaluation de la qualité des alignements avec t_coffee

[Transitive-Consistency-Score](https://tcoffee.readthedocs.io/en/latest/tcoffee_main_documentation.html?highlight=score#transitive-consistency-score-tcs)

TCS est un score d’évaluation d’alignement qui permet d’identifier les positions les plus correctes dans un MSA. Il a été démontré que ces positions sont les plus susceptibles d’être structurellement correctes et également les plus informatives lors de l’estimation des arbres phylogénétiques.

La procédure d’évaluation et de filtrage TCS peut être utilisée pour évaluer et filtrer n’importe quel MSA.
* sample_seq1.score_ascii displays the score of the MSA, the sequences and the residues.
* sample_seq1.score_html displays a colored version score of the MSA, the sequences and the residues.
* sample_seq1.tcs_residue_filter3 All residues with a TCS score lower than 3 are filtered out
* sample_seq1.tcs_column_filter3 All columns with a TCS score lower than 3 are filtered out

```bash
search_module T-Coffee
```
```bash
for i in ~/work/Kettler/OG/alignment/ali_dna_*.ffn 
do 
  ip=$(basename $i .ffn)     
  outfile="~/work/Kettler/OG/alignment/"$ip".ali"
  echo "module load  bioinfo/T-Coffee/13.45.63; t_coffee -infile $i -output score_ascii, aln, score_html -outfile $outfile;" 
done > ~/work/Kettler/OG_t_coffee_TCS.sh
```

Lancement de la commande
```bash
sarray -J TCS -o %j.out -e %j.err -t 01:00:00 --cpus-per-task=1  ~/work/Kettler/OG_t_coffee_TCS.sh
squeue -l -u $USER
```

Sélection alignements avec un SCORE=1000
```bash
srun --pty bash 

goodDNA_alignments=~/work/Kettler/OG/goodDNA_alignments/
goodPEP_alignments=~/work/Kettler/OG/goodPEP_alignments/
original_alignments=~/work/Kettler/OG/alignment/

if [[ ! -d $goodDNA_alignments ]]; then
  mkdir $goodDNA_alignments
fi
if [[ ! -d $goodPEP_alignments ]]; then
 mkdir $goodPEP_alignments
fi
 
goodDNA_alignment_list=~/work/Kettler/OG/goodDNA_alignments/DNASCORE1000.lst
goodPEP_alignment_list=~/work/Kettler/OG/goodPEP_alignments/PEPSCORE1000.lst
 
if [[ -f $goodDNA_alignment_list ]]; then
 rm $goodDNA_alignment_list
fi
 
if [[ -f $goodPEP_alignment_list ]]; then
 rm $goodPEP_alignment_list
fi
 
for i in $original_alignments*.ali; 
do 
 if [[ $(grep -H 'SCORE=1000' $i) ]]; then
   ip=$(basename $i .ali)
   oriDNA="$original_alignments$ip.ffn"
   goodDNA="$goodDNA_alignments$ip.ffn"
   cp $oriDNA $goodDNA
   echo $oriDNA >> $goodDNA_alignment_list
 
   PEP=${ip:8:13}
   oriPEP="${original_alignments}ali_pep_${PEP}.ffn"
   goodPEP="${goodPEP_alignments}ali_pep_${PEP}.ffn"
   cp $oriPEP $goodPEP
   echo $oriPEP >> $goodPEP_alignment_list
 else
   echo skip $i $(grep SCORE $i)
 fi
done
cat $goodDNA_alignment_list
```

# Arbres espèces

modified 21/10/2025

## Introduction

Comme dans l’article publié en 2018 de Yan et al., nous utiliserons 31 gènes du core genome tirés au hasard.

## Concaténation de 31 alignements

Nous allons extraire ces 31 alignements des alignements présentant un TCS SCORE=1000 identifiés dans l’atelier précédent.
```bash
srun --pty bash
scp Kettler.tar.gz <USER>@genobioinfo.toulouse.inrae.fr:/home/<USER>/work/
gunzip Kettler.tar.gz
tar -xvf Kettler.tar
```
```bash
godir=~/work/Kettler/OG
if [[ ! -d $godir/31_good_alignments ]]; then
  mkdir -p $godir/31_good_alignments
fi

mkdir -p ~/work/scripts
cp /home/formation/public_html/M2_Phylogenomique/scripts/* ~/work/scripts

sed -i 's/yquentin/<USER>/g' $godir/goodDNA_alignments/DNASCORE1000.lst

~/work/scripts/concat_aligments.pl  --alignments $godir/goodDNA_alignments/DNASCORE1000.lst --outfile  $godir/31_good_alignments/alignments.fas  -nb_ali 31
```

Liste des alignements retenus: `~/work/Kettler/OG/31_good_alignments/alignments.fas.lst`

Générer l’alignement peptidique correspondant.
```bash
module load statistics/R/4.3.0
R
if (!require('seqinr')) {install.packages('seqinr')}
35
library(seqinr)
dna <- read.alignment("~/work/Kettler/OG/31_good_alignments/alignments.fas", format="fasta")
AA <- lapply(dna$seq, function(x) seqinr::translate(s2c(x)))
write.fasta(AA, names=dna$nam, file.out="~/work/Kettler/OG/31_good_alignments/PEPalignments.fas")
q()
y
```

>[!WARNING]
>Ici, on sélectionne le miroir CRAN 35 (Paris) car le 33 (Lyon) a un chargement trop lent ce jour (maintenance éventuelle).
>Le package seqinr n'est pas compatible avec R v4.0.0 donc on charge le module R v4.3.0 (comme précédemment).
> `module purge` pour éviter les conflits
> `module load statistics/R/4.3.0` pour charger le bon module

Remarque, le package [T-Coffee](https://tcoffee.org/Projects/tcoffee/documentation/index.html) peut être utilisé pour effectuer la traduction de l’ADN en peptide
et la traduction inverse (et bien d’autres choses encore !).

## IQ-TREE

Nous allons utiliser le logiciel [IQ-TREE](http://www.iqtree.org/) pour inférer nos arbres espèces par maximum de vraisemblance.

genobioinfo softwares : [iq-tree](http://bioinfo.genotoul.fr/index.php/resources-2/softwares/?searchll=iq-tree)
* FAQ : http://www.iqtree.org/doc/Frequently-Asked-Questions
* Documentation : http://www.iqtree.org/doc/
* Substitution-Models : http://www.iqtree.org/doc/Substitution-Models
* Command-Reference : http://www.iqtree.org/doc/Command-Reference
```bash
search_module IQ-TREE
```

```bash
phydir=~/work/Kettler/phyloG/
if [[ ! -d $phydir ]]; then
  mkdir -p $phydir
fi
cd $phydir
cp ~/work/Kettler/OG/31_good_alignments/alignments.fas $phydir/.
cp ~/work/Kettler/OG/31_good_alignments/PEPalignments.fas $phydir/.
```

### Super-alignement avec un modèle codons

Nous allons inférer un arbre à partir du super-alignement avec un modèle codons.

Créer le fichier `condTree.sh` contenant les lignes suivantes.
Lancez le, puis répondez aux questions suivantes car cela va être assez long, vous y reviendrez ensuite.

Surtout faites un sbatch –cpus-per-task=10 (ou -c 10) à partir du frontal pour le lancer car nous avons utilisé l’option -nt AUTO.

Par défaut, ModelFinder teste jusqu’à 330 modèles de codons.
Vous pouvez spécifier le modèle (-m GY+F+R4) dans la ligne de commande pour gagner des heures de calcul ;-) et lancer l’évaluation des autres modèles en parallèle avec -m MFP.

`-m MFP: automatically determines best-fit model for your data.`

Ecriture du fichier `~/work/scripts/condTree.sh` utilisant le modèle GY+F+R4 du super-alignement avec codon model :
```bash
nano ~/work/scripts/condTree.sh
```
```bash
#!/bin/bash
#SBATCH -J ModelFinderGYFR4
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinder.out
#SBATCH -e ModelFinder.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/alignments.fas -redo -bb 1000 -alrt 1000 -st CODON -nt AUTO -m GY+F+R4 -pre ~/work/Kettler/phyloG/ModelFinderGYFR4 -redo
```

Ecriture du fichier `~/work/scripts/condTree_MFP.sh` utilisant l’évaluation des autres modèles du super-alignement avec codon model :
```bash
nano ~/work/scripts/condTree_MFP.sh
```
```bash
#!/bin/bash
#SBATCH -J ModelFinderMFP
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinderMFP.out
#SBATCH -e ModelFinderMFP.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/alignments.fas -redo -bb 1000 -alrt 1000 -st CODON -nt AUTO -m MFP -pre ~/work/Kettler/phyloG/ModelFinderMFP -redo
```

Ecriture du fichier `~/work/scripts/condTree_prot.sh` utilisant le super-alignement protéique (décrit en suivant) :
```bash
nano ~/work/scripts/condTree_prot.sh
```
```bash
#!/bin/bash
#SBATCH -J ModelFinderProt
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinderProt.out
#SBATCH -e ModelFinderProt.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/PEPalignments.fas -B 1000 -alrt 1000 -nt AUTO -mset WAG,LG,JTT -madd LG4M,LG4X -mrate E,I,G,I+G,R -pre ~/work/Kettler/phyloG/ModelFinderProt -redo
```

Lancement de tous les modèles en parallèle :
```bash
sbatch ~/work/scripts/condTree.sh
sbatch ~/work/scripts/condTree_MFP.sh
sbatch ~/work/scripts/condTree_prot.sh
```

Les résultats sont écrits dans les fichiers suivants (remplacer <alignments> par 
```text plain
Split supports printed to NEXUS file /home/<USER>/work/Kettler/phyloG/alignments.fas.splits.nex
Consensus tree written to /home/<USER>/work/Kettler/phyloG/alignments.fas.contree

Analysis results written to: 
  IQ-TREE report:                /home/<USER>/work/Kettler/phyloG/alignments.fas.iqtree
  Maximum-likelihood tree:       /home/<USER>/work/Kettler/phyloG/alignments.fas.treefile
  Likelihood distances:          /home/<USER>/work/Kettler/phyloG/alignments.fas.mldist

Ultrafast bootstrap approximation results written to:
  Split support values:          /home/<USER>/work/Kettler/phyloG/alignments.fas.splits.nex
  Consensus tree:                /home/<USER>/work/Kettler/phyloG/alignments.fas.contree
  Screen log file:               /home/<USER>/work/Kettler/phyloG/alignments.fas.log
```

Ranger les fichiers de sorties standard :
```bash
mv *.err ~/work/Kettler/phyloG/
mv *.out ~/work/Kettler/phyloG/
```

Tracé de l’arbre:
```bash
module load statistics/R/4.3.0
R

if (!require('ape')) {install.packages('ape')}
35
library(ape)

treefile <-"~/work/Kettler/phyloG/ModelFinderGYFR4.treefile"
treefile_MFP <-"~/work/Kettler/phyloG/ModelFinderMFP.treefile"
treefile_Prot <-"~/work/Kettler/phyloG/ModelFinderProt.treefile"

# Arbre avec modele GYFR4

tr <- read.tree(treefile)
outgroup <- c("Prah", "Praf")
# reroot with ape root function
rtr <- root(tr, outgroup=outgroup, resolve.root=TRUE)

rtr_file <- "~/work/Kettler/phyloG/alignments_reroot.treefile"
write.tree(rtr, file=rtr_file)
 
pdf_file <- '~/work/Kettler/phyloG/alignments_reroot.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rtr, show.node.label=T, cex=0.5, no.margin=T)
dev.off()

# Arbre avec MFP

tr <- read.tree(treefile_MFP)
outgroup <- c("Prah", "Praf")
# reroot with ape root function
rtr <- root(tr, outgroup=outgroup, resolve.root=TRUE)

rtr_file <- "~/work/Kettler/phyloG/alignments_reroot_MFP.treefile"
write.tree(rtr, file=rtr_file)
 
pdf_file <- '~/work/Kettler/phyloG/alignments_reroot_MFP.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rtr, show.node.label=T, cex=0.5, no.margin=T)
dev.off()

# Arbre avec Prot

tr <- read.tree(treefile_Prot)
outgroup <- c("Prah", "Praf")
# reroot with ape root function
rtr <- root(tr, outgroup=outgroup, resolve.root=TRUE)

rtr_file <- "~/work/Kettler/phyloG/alignments_reroot_Prot.treefile"
write.tree(rtr, file=rtr_file)
 
pdf_file <- '~/work/Kettler/phyloG/alignments_reroot_Prot.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rtr, show.node.label=T, cex=0.5, no.margin=T)
dev.off()

q()
y
```

### Super-alignement protéique

Pour modéliser l’évolution des protéines, nous devons définir une matrice des taux d’échange entre les acides aminés et un modèle d’hétérogénéité des taux entre les sites.
Nous ne testerons que trois matrices et deux modèles de mélange.

Amino-acid exchange rate matrices `-mset WAG,LG,JTT`

Protein mixture models Le et al., 2012
* LG4M is composed of four matrices, each corresponding to one discrete gamma rate category (of four). These matrices differ in their amino acid equilibrium distributions and in their exchangeabilities, contrary to the standard gamma model where only the global rate differs
* LG4X also uses four different matrices, but leaves aside the gamma distribution and follows a distribution-free scheme for the site rates.

These matrices are estimated from a very large alignment database.

Rate heterogeneity across sites -mrate E,I,G,I+G,R

Pour inférer un arbre à partir du super-alignement protéique, la ligne de commande lancée est `iqtree -s ~/work/Kettler/phyloG/PEPalignments.fas -B 1000 -alrt 1000 -nt AUTO -mset WAG,LG,JTT -madd LG4M,LG4X -mrate E,I,G,I+G,R`

Récupérer le code correspondant depuis la section précédente.

Dans le fichier `~/work/Kettler/phyloG/PEPalignments.fas.iqtree`, vous trouverez des statistiques sur l’alignement et le choix des modèles.

```bash
module load statistics/R/4.4.0
R

library(ape)

treefile <-"~/work/Kettler/phyloG/PEPalignments.fas.treefile" 
tr <- read.tree(treefile)
 
outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
rtr <- root(tr, outgroup=outgroup, resolve.root=TRUE)
rtr_file <- "~/work/Kettler/phyloG/PEPalignments_reroot.treefile"
write.tree(rtr, file=rtr_file)

pdf_file <- '~/work/Kettler/phyloG/PEPalignments_reroot.pdf'
pdf(file=pdf_file, paper="a4r")
 
plot.phylo(rtr, show.node.label=T, cex=0.5, no.margin=T)
dev.off()
```

```bash
if (!require('TreeTools')) {install.packages('TreeTools')}
35
library(TreeTools)

rtr2 <- RootTree(tr, outgroup=outgroup)

rtr_file <- "~/work/Kettler/phyloG/PEPalignments_reroot_treetools.treefile"
write.tree(rtr2, file=rtr_file)
 
pdf_file <- '~/work/Kettler/phyloG/PEPalignments_reroot_treetools.pdf'
pdf(file=pdf_file, paper="a4r")
 
plot(rtr2, show.node.label=T, cex=0.5, no.margin=T)
dev.off()
```

Le fichier .splits.nex renferme les valeurs de soutien en pourcentage pour toutes les bipartitions, calculées comme les fréquences d’occurrence dans les arbres bootstrap. Ce fichier peut être visualisé avec le programme SplitsTree pour explorer les signaux contradictoires dans les arbres.

* [splitstree6](https://software-ab.cs.uni-tuebingen.de/download/splitstree6/welcome.html)

### Congruence entre les arbres : cophyloplot et cophylo

```bash
treefile1 <-"~/work/Kettler/phyloG/alignments_reroot.treefile" 
tr1 <- read.tree(treefile1)
 
treefile2 <-"~/work/Kettler/phyloG/PEPalignments_reroot.treefile" 
tr2 <- read.tree(treefile2)
 
links <- cbind(tr2$tip.label, tr2$tip.label)
 
pdf_file <- '~/work/Kettler/phyloG/CODON_PEP_cophyloplot.pdf'
pdf(file=pdf_file, paper="a4r")
 
cophyloplot(tr1, tr2, assoc = links, length.line = 4, space = 28, gap = 3, show.tip.label = T)
dev.off()

q()
y
```

```bash
mkdir -p ~/work/Kettler/RNAr

R
if (!require('phytools')) {install.packages('phytools')}
35
library(phytools)
library(ape)
library(TreeTools)

cophylo <- cophylo(tr1, tr2, assoc = links, rotate = TRUE)
 
pdf_file <- '~/work/Kettler/RNAr/ssu_cophylo.pdf'
pdf(file=pdf_file, paper="a4r")
plot(cophylo, link.type="curved", link.lwd=4, link.lty="solid", link.col=make.transparent("red", 0.25))
dev.off()

q()
y
```

Pour afficher les valeurs de bootstraps, il est nécessaire que figtree les charge comme « labels », ainsi dans la rubrique « node labels » il vous faudra sélectionner « labels » dans le menu déroulant « display ».

## Super-arbres

Nous allons utiliser les arbres individuels protéiques.

Nous utilisons les mêmes familles de gènes que celles sélectionnées à l’étape précédente.

### Calcul des arbres de toutes les familles de protéines

Il n’est pas toujours utile de tester l’ensemble des modèles, vous pouvez faire une pré-sélection avec l’option -mset et/ou -madd. Exemple -mset WAG,JTT,LG.

Création du fichier de lancement des commandes :
```bash
mkdir -p ~/work/Kettler/phyloG/PEP

while IFS= read -r line; 
do
  echo $line
  fam=${line/dna/"pep"}
  if [[ -e $fam ]]; then
    prefix=$(basename $fam .fas)
    outfile=~/work/Kettler/phyloG/PEP/$prefix".fas"
    cp $fam $outfile
    sed -i -r 's/>(Pr[a-z]{2}).g_[0-9]+/>\1/g' $outfile
    echo "module load bioinfo/IQ-TREE/2.2.2.6; iqtree -s $outfile -B 1000 -alrt 1000 -nt 1 -mset WAG,LG,JTT -madd LG4M,LG4X -mrate E,I,G,I+G,R"
  else 
    echo "$fam is not found!"
  fi
done < ~/work/Kettler/OG/31_good_alignments/alignments.fas.lst  > ~/work/Kettler/phyloG/fam_tree.sh
```

Attention à bien spécifier `-nt 1`.
Si vous souhaitez utiliser plus d’une CPU il faut le réserver avec l’option –cpus-per-task dans la commande sbatch / sarray.
Pas besoin d’augmenter la RAM pour les protéines.

Lancement de l'ensemble des commande :
```bash
sarray -J translate -o %j.out -e %j.err -t 04:00:00 --cpus-per-task=1 ~/work/Kettler/phyloG/fam_tree.sh

# pourquoi faire ?
ls ~/work/Kettler/phyloG/PEP/*pep*.log | wc
```

Quand tous vos jobs sont terminés, vérifiez que les fichiers de sorties ne soient pas vides et que ça s’est bien passé en faisant par exemple :
```bash
tail ~/work/Kettler/phyloG/PEP/*pep*.log
```

Vous pouvez aussi regarder les modèles sélectionnés :
```bash
grep 'Best-fit model:' ~/work/Kettler/phyloG/PEP/*pep*.log
```

Obtenir les modèles les plus fréquemments trouvés :
```bash
grep "Best-fit model" ~/work/Kettler/phyloG/PEP/*pep*.log | sed -E 's/.*model: ([^ ]+) chosen.*/\1/' | sort | uniq -c | sort -nr > ~/work/Kettler/phyloG/PEP/Best-fit_model.txt
```

Concaténer tous les arbres (les 31 arbres protéiques) avec la commande cat. Nommez le fichier `alltrees.tree`.
```bash
cat ~/work/Kettler/phyloG/PEP/*pep*.treefile > ~/work/Kettler/phyloG/alltrees.tree
```

## Test de plusieurs méthodes de super-arbres

### MRP

Commençons par la méthode la plus répandue : le MRP.

Pour aller sur un nœud :
```bash
srun --pty bash
```

La fonction mrp.supertree estime le super-arbre MRP (matrix representation parsimony) à partir d’un ensemble d’arbres d’entrée (Baum 1992 ; Ragan 1992).
```bash
R
library(phytools)
trees=read.tree("~/work/Kettler/phyloG/alltrees.tree")
supertrees<-mrp.supertree(trees, rearrangements="SPR", start="NJ")
 
outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
rsupertrees <- root(supertrees, outgroup=outgroup, resolve.root=TRUE)
 
pdf_file <- '~/work/Kettler/phyloG/MRP_supertrees.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rsupertrees, show.node.label=T)
dev.off()
```

Vous avez obtenu les super-arbres les plus parcimonieux. Sauvez-les en utilisant la fonction write.tree de R.
```bash
write.tree(rsupertrees, file = "~/work/Kettler/phyloG/superTrees_rooted.tree")
write.tree(supertrees, file = "~/work/Kettler/phyloG/superTrees.tree")
```

Dans notre cas, nous avons un seul arbre le plus parcimonieux, mais nous aurions pu en obtenir plusieurs.

### Arbre consensus

Vous pouvez utiliser la librairie ape de R pour calculer un arbre consensus.
```bash
# p a numeric value between 0.5 and 1 giving the proportion for a clade to be represented in the consensus tree.

trees=read.tree("~/work/Kettler/phyloG/alltrees.tree")
constree<-consensus(trees, p=0.3)
 
outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
constree <- root(constree, outgroup=outgroup, resolve.root=TRUE)

pdf_file <- '~/work/Kettler/phyloG/consus_trees_3.pdf'
pdf(file=pdf_file, paper="a4r")
plot(constree, show.node.label=T)
dev.off()

q()
y
```

Vous pouvez aussi utiliser IQ-TREE pour obtenir le consensus des 31 arbres avec la règle majoritaire étendue.

Pour cela restez sur le nœud et tapez :
```bash
module load bioinfo/IQ-TREE/2.2.2.6
iqtree -con -t ~/work/Kettler/phyloG/alltrees.tree -nt 1

R
library(phytools)
contree=read.tree("~/work/Kettler/phyloG/alltrees.tree.contree")
 
outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
rcontree <- root(contree, outgroup=outgroup, resolve.root=TRUE)
write.tree(rcontree, file = "~/work/Kettler/phyloG/alltrees_tree_contree_reroot.tree")
 
pdf_file <- '~/work/Kettler/phyloG/alltrees_tree_contree_reroot.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rcontree, show.node.label=T)
dev.off()

q()
y
```

### Arbre consensus en réseau

```bash
iqtree -net -t ~/work/Kettler/phyloG/alltrees.tree -nt 1
```

fichier de sortie: `alltrees.tree.nex`

Et visualisez-le avec SplitsTree en local.
* [splitstree5](https://software-ab.informatik.uni-tuebingen.de/download/splitstree5/welcome.html)
* [splitstree6](https://software-ab.cs.uni-tuebingen.de/download/splitstree6/welcome.html)


### ASTRAL

* [ASTRAL](https://github.com/smirarab/ASTRAL)

ASTRAL est une méthode permettant d’estimer un arbre d’espèces non enraciné à partir d’un ensemble d’arbres génétiques non enracinés.
ASTRAL trouve l’arbre espèces qui a le plus grand nombre d’arbres quartets induits partagés avec l’ensemble des arbres gènes,
sous réserve que l’ensemble des bipartitions dans l’arbre d’espèce provienne d’un ensemble prédéfini de bipartitions.
Cet ensemble prédéfini est défini empiriquement par ASTRAL.

* [How_to_use_SLURM_ASTRAL](http://bioinfo.genotoul.fr/index.php/how-to-use/?software=How_to_use_SLURM_ASTRAL)

Pour trouver l’arbre des espèces, utilisez l’ensemble des arbres concaténés dans un fichier, comme ci-dessus.

Un exemple de script de soumission:
```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 1-00:00:00
#Load modules
module load bioinfo/ASTRAL/5.7.8

java -Xmx4g -jar $ASTRAL -i ~/work/Kettler/phyloG/alltrees.tree -o ~/work/Kettler/phyloG/Astral/alltrees.tree
```

Création du script pour ASTRAL :
```bash
mkdir -p ~/work/Kettler/phyloG/Astral
nano ~/work/scripts/astral.sh
```
```bash
#!/bin/bash
#SBATCH -p workq
#SBATCH -t 1-00:00:00
#Load modules
module load bioinfo/ASTRAL/5.7.8

java -Xmx4g -jar $ASTRAL -i ~/work/Kettler/phyloG/alltrees.tree -o ~/work/Kettler/phyloG/Astral/alltrees.tree
```
```bash
sbatch ~/work/scripts/astral.sh
```

Analyse de l'arbre obtenu avec R :
```bash
R
library(phytools)
astral=read.tree("~/work/Kettler/phyloG/Astral/alltrees.tree")
 
outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
rastral <- root(astral, outgroup=outgroup, resolve.root=TRUE)
write.tree(rastral, file = "~/work/Kettler/phyloG/astral_rooted.tree")
 
pdf_file <- '~/work/Kettler/phyloG/astral_rooted.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rastral, show.node.label=T)
dev.off()
```

Dans l’article ASTRAL-III, il a été montré que la suppression des branches à très faible support (par exemple, moins de 10 % de support bootstrap) des arbres peut améliorer quelque peu la précision.
Nous recommandons donc de supprimer les branches à très faible support.

Le package ggtree possède une fonction as.polytomy qui peut être utilisée pour réduire les nœuds en fonction des valeurs de support.

Par exemple, pour réduire les bootstraps à moins de 10 %, vous pouvez utiliser sur tous les arbres et recalculer Astral.
```bash
if (!require('ggtree')) {install.packages('ggtree')}
35
library(ggtree)

astral=read.tree("~/work/Kettler/phyloG/Astral/alltrees.tree")
polytree = as.polytomy(astral, feature='node.label', fun=function(x) as.numeric(x) < 10)

outgroup <- c("Prah", "Praf")
 
# reroot with ape root function
rastral <- root(polytree, outgroup=outgroup, resolve.root=TRUE)
write.tree(rastral, file = "~/work/Kettler/phyloG/astral_rooted_supp10percentSupport.tree")
 
pdf_file <- '~/work/Kettler/phyloG/astral_rooted_supp10percentSupport.pdf'
pdf(file=pdf_file, paper="a4r")
plot(rastral, show.node.label=T)
dev.off()

q()
y
```

## Comparaison des arbres otenus avec les différentes méthodes

### Calcul de la distance de Robinson-Foulds avec IQ-TREE

* [computing-robinson-foulds-distance](http://www.iqtree.org/doc/Command-Reference#computing-robinson-foulds-distance)

Concaténez maintenant les deux arbres de super-matrice (celui sur les codons que vous avez lancé toute à l’heure et celui sur les protéines)
ainsi que les trois super-arbres (consensus, MRP et ASTRAL).

* arbre sur les codons (modèle GYFR4) : ~/work/Kettler/phyloG/alignments_reroot.treefile
* arbre sur les protéines : ~/work/Kettler/phyloG/PEPalignments_reroot.treefile
* super-arbre consensus : ~/work/Kettler/phyloG/alltrees_tree_contree_reroot.tree
* super-arbre MRP : ~/work/Kettler/phyloG/superTrees_rooted.tree
* super-arbre ASTRAL : ~/work/Kettler/phyloG/astral_rooted.tree

```bash
cat ~/work/Kettler/phyloG/alignments_reroot.treefile ~/work/Kettler/phyloG/PEPalignments_reroot.treefile ~/work/Kettler/phyloG/alltrees_tree_contree_reroot.tree ~/work/Kettler/phyloG/superTrees_rooted.tree ~/work/Kettler/phyloG/astral_rooted.tree > ~/work/Kettler/phyloG/Compile.tree
```

Attention marquez quelques part l'ordre avec lequel vous les avez concaténés pour créer le fichier d'arbres à comparer afin de vous en souvenir ensuite.
Lancer ensuite le calcul de la distance de Robinson et Foulds sur ce fichier avec IQ-TREE.
```bash
iqtree -rf_all ~/work/Kettler/phyloG/Compile.tree
```

* result : `~/work/Kettler/phyloG/Compile.tree.rfdist`

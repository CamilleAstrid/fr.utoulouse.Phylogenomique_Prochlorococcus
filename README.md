# Étude comparative du génome et de l’évolution de Prochlorococcus à partir de données RefSeq et Zhang et al. (2021)

>[!WARNING]
>En cours d'automatisation...   
>Les scripts utilisés sont en attente de réappropriation intellectuelle avant publication.   
>Note pour l'auteur, le fichier correspond au `Atelier_compile.md`.

## Description

Ce projet présente une **analyse phylogénomique et pan-génomique** du collectif *Prochlorococcus*, un groupe de cyanobactéries marines photosynthétiques particulièrement abondantes dans les océans.
L’étude vise à explorer la **diversité génétique, fonctionnelle et évolutive** de ce groupe, en mettant en œuvre un pipeline bioinformatique complet et reproductible — depuis la récupération des données génomiques jusqu’à la reconstruction des arbres d’espèces.

Le travail s’inscrit dans le cadre du **Master Bioinformatique et Biologie des Systèmes** de l’Université de Toulouse, et a été réalisé sur la plateforme de calcul **GenoToul (INRAE)** à l’aide du gestionnaire de tâches **Slurm**.

### Les données

Les données utilisées proviennent exclusivement de **sources publiques**.
Les **génomes complets** de *Prochlorococcus* et de *Synechococcus* ont été téléchargés depuis la base **RefSeq (NCBI)**, puis filtrés pour garantir leur qualité (contrôle de complétude, élimination des contaminations et des génomes de phages).
Un **sous-échantillon représentatif** publié par **Zhang et al. (2021)** a ensuite été sélectionné afin de réduire le volume de calcul tout en préservant la diversité écologique et phylogénétique du collectif.

Les données de travail incluent :

* les séquences génomiques brutes (FASTA) et leurs métadonnées (numéros d’accession, taxonomie, liens FTP),
* les annotations produites par **Prokka** et **eggNOG-mapper**,
* les résultats d’inférence d’orthogroupes issus d’**OrthoFinder**,
* les matrices binaires de présence/absence des gènes,
* et les fichiers d’arbres d’espèces, de super-arbres et de visualisations.

### Méthodologie d’analyse

L’analyse repose sur une **approche intégrée et comparative** combinant plusieurs logiciels et environnements :

1. **Annotation génomique** avec *Prokka*, permettant l’identification des gènes codants et non codants.
2. **Annotation fonctionnelle** avec *eggNOG-mapper*, pour l’attribution des fonctions biologiques (COG, KEGG, GO).
3. **Inférence d’orthogroupes** via *OrthoFinder*, servant à identifier les gènes homologues et les duplications.
4. **Analyse pan-génomique** sous *R* avec le script *panplots.R*, générant les courbes d’accumulation du pan-génome et du génome cœur selon la loi de Heaps.
5. **Sélection des familles conservées** et alignements multiples réalisés avec *T-Coffee* et évalués par le score TCS.
6. **Inférence phylogénétique** avec *IQ-TREE* (modèles nucléotidique, codonique et protéique), complétée par la construction de **super-arbres** (*MRP*, *ASTRAL*, *consensus majoritaire*).

L’ensemble du flux de travail a été documenté et automatisé par des **scripts Bash et R** exécutés sur la plateforme **GenoToul**, garantissant la reproductibilité des résultats.

### Finalité

L’objectif principal de ce projet est de **comprendre la structuration phylogénétique et fonctionnelle** du collectif *Prochlorococcus*, ainsi que les mécanismes évolutifs ayant conduit à sa diversification.
Plus précisément, il s’agissait de :

* déterminer la composition du **génome cœur** et du **pan-génome** ;
* identifier les **duplications** et **pertes de gènes** au sein du collectif ;
* reconstruire les **relations évolutives** entre écotypes à l’aide de différentes approches phylogénétiques ;
* et évaluer la **robustesse** et la **cohérence** des topologies obtenues selon les modèles et méthodes utilisés.

Ce travail a également une portée méthodologique, illustrant la mise en place d’un **pipeline reproductible** de phylogénomique comparative appliqué à un jeu de données réel.

### Principales conclusions

Les analyses ont révélé une **cohérence forte** entre les différentes approches d’inférence phylogénétique et une structuration claire du collectif *Prochlorococcus* :

* Le **pan-génome est ouvert**, traduisant une plasticité génétique importante et un potentiel adaptatif élevé.
* Le **génome cœur** (~1 200 gènes) reste stable et conservé entre les souches, correspondant aux fonctions essentielles.
* Les **arbres d’espèces** et **super-arbres** (IQ-TREE, MRP, ASTRAL) présentent des topologies similaires, avec une **séparation nette entre les écotypes de haute lumière (HL)** et **de basse lumière (LL)**.
* Les **événements de duplication** sont peu influencés par l’enracinement de l’arbre, confirmant la robustesse des résultats d’OrthoFinder.

En conclusion, ce projet met en évidence l’équilibre entre un **noyau génétique stable** et une **diversité accessoire dynamique**, moteurs de l’adaptation écologique exceptionnelle de *Prochlorococcus* dans les environnements marins oligotrophes.

## Structure

### Dossiers et fichiers
* `README.md` : Fichier de présentation du projet (vous y êtes !).
* `LICENSE` : Licence d’utilisation.
* `.gitignore` : Liste des fichiers et/ou dossiers à ignorer pour le git.
* `Rapport_Phylogenomique.pdf` : recueille les analyses effectuées.
* **Tentative_automatisation_1/** : dossier regroupant l'ensemble des scripts pour une mise en place d'automatisation de la première partie du pipeline.
* **Tentative_automatisation_2/** : dossier regroupant l'ensemble des scripts pour une nouvelle approche plus fonctionnelle et lisible de la mise en place d'automatisation de la première partie du pipeline.
* **documents_supp_rapport/** : dossier regroupant l'ensemble des images utilisées pour la rédaction du rapport.
* **genobioinfo/** : dossier regroupant l'ensemble des analyses effectuées sur le cluster GenoToul. Son chemin correspond au ~/work/ du serveur.


## Outils utilisés

## Prérequis

Nécessite l'accès au cluster de calcul de la GenoToul

### Langages
* bash
* R

### Packages
L'ensemble des packages et modules prérequis se trouvent dans les fichiers de configuration dans le dossier `Tentative_automatisation_2` (en cours, étape 1 faite).

## Installation

```bash
git clone https://https://github.com/CamilleAstrid/fr.utoulouse.Phylogenomique_Prochlorococcus.git
cd fr.utoulouse.Phylogenomique_Prochlorococcus
```

## Licence
Ce projet et donc l'ensemble des éléments de ce répertoire est sous licence GPL-v3 (sauf cas précisé).

## Références
* Zhang et al., 2021 Snowball Earth, population bottleneck and Prochlorococcus evolution.
* Tettelin, Hervé et al. “Comparative genomics: the bacterial pan-genome.” Current opinion in microbiology vol. 11,5 (2008): 472-7. doi:10.1016/j.mib.2008.09.006
* Kettler et al., PLoS Genet. 2007 Dec;3(12):e231 Patterns and implications of gene gain and loss in the evolution of ‘’Prochlorococcus’’.
* Sun and Blanchard, 2014 Strong Genome-Wide Selection Early in the Evolution of Prochlorococcus Resulted in a Reduced Genome through the Loss of a Large Number of Small Effect Genes
* Yan et al., Appl Environ Microbiol. 2018 Genome rearrangement shapes ‘’Prochlorococcus’’ ecological adaptation.
* Yan et al., mBio 2022 Diverse Subclade Differentiation Attributed to the Ubiquity of Prochlorococcus High-Light-Adapted Clade II
* Biller et al., Nat. Rev. Microbiol. 2015 13(1) 13-27 ‘’Prochlorococcus’’: the structure and function of collective diversity.
* Partensky and Laurence Garczarek Annual Review of Marine Science 2010 Prochlorococcus: Advantages and Limits of Minimalism.
* Tschoeke et al., 2020 Unlocking the Genomic Taxonomy of the Prochlorococcus Collective.
* Yan et al., 2022 Diverse Subclade Differentiation Attributed to the Ubiquity of Prochlorococcus High-Light-Adapted Clade II.
* Ribalet et al., 2025 Future ocean warming may cause large reductions in Prochlorococcus biomass and productivity
* [Prochlorococcus] https://www.cell.com/current-biology/fulltext/S0960-9822(17)30213-0?code=cell-site
* [Cyanorak Information system] http://application.sb-roscoff.fr/cyanorak/welcome.html

## Auteurs

Les scripts sont issus des enseignements de Yves QUENTIN & Gwennael FICHANT.

Les modifications apportées sont la propriété intellectuelle de Camille-Astrid Rodrigues.

>[!NOTE]
>Pour toute question, veuillez me contacter par mail : [Camille-Astrid Rodrigues](mailto:camilleastrid.cr@gmail.com)   
>Si des ajustements ou des ajouts sont nécessaires, n'hésitez pas à me le signaler !

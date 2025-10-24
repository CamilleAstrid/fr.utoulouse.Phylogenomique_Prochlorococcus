#!/usr/bin/bash
# --evalueExponentCutoff 	e-value Exponent Cutoff (a negative value, default=-5)
# --percentMatchCutoff 	percent Match Cutoff (integer value, default=50)
evalueExponentCutoff=-5
percentMatchCutoff=50
workdir=`pwd`
echo "working directory:" $workdir
read -p "Press any key to continue... " -n1 -s
echo

########################################################################
echo "### Step 4: Parse BLAST results"

if [ ! -f $workdir/taxon_list ]; then
	mkdir -p $workdir

	ls -1 ~/work/Prochlorococcus/peptide/*faa | sed -r 's/.+([A-Z][a-z]{3}).faa/\1/' > $workdir/taxon_list
	if [ ! -f $workdir/taxon_list ]; then
		echo "Error: file $workdir/taxon_list not found!"
		exit 1
	fi
fi
nbstrains=$(wc -l < $workdir/taxon_list)
if [ $nbstrains == 0 ]; then
    echo "Error: no srain found!"
    exit 1
fi
echo "$nbstrains strains"

########################################################################
echo "### Concaténer les fichiers de résultats blastp par souche"

if [ ! -f $workdir/3.blastres/Aaaa.tab ]; then
	mkdir -p $workdir/3.blastres

	echo "### Boucle sur les souches"

	for file in ~/work/Prochlorococcus/peptide/*.faa
	do
		prefix=$(basename "$file" .faa)
		/home/formation/public_html/M2_Phylogenomique/scripts/cat_blast_resutls.pl --query $prefix --taxonlist $workdir/taxon_list --blast_dir ~/work/Prochlorococcus/BlastP --out_dir $workdir/3.blastres
	done
	if [ ! -f $workdir/3.blastres/Aaaa.tab ]; then
		echo "Error: file $workdir/3.blastres/Aaaa.tab not found!"
		exit 1
	fi
	echo "### Modifier le nom des souches dans les fichiers blastp"

	for file in $workdir/3.blastres/*.tab
	do
		prefix=$(basename "$file")
		sed -i -r 's/([A-Z][a-z]{3})(\w*\.)/\1|\2/g' $file
	done

	echo "### Vérifier les changements de noms"

	echo "### head $workdir/3.blastres/Aaaa.tab"
	head $workdir/3.blastres/Aaaa.tab
fi

########################################################################
echo "### Modifier le nom des souches dans les fichier fasta"

if [ ! -f $workdir/compliantFasta/Aaaa.fasta2 ]; then
	mkdir -p $workdir/compliantFasta

	for file in ~/work/Prochlorococcus/peptide/*.faa
	do
		prefix=$(basename $file .faa)
		echo "sed -r 's/([A-Z][a-z]{3})/\1|/g' $file > $workdir/compliantFasta/$prefix.fasta"
		sed -r 's/([A-Z][a-z]{3})/\1|/g' $file > $workdir/compliantFasta/$prefix.fasta
	done
	if [ ! -f $workdir/compliantFasta/Aaaa.fasta ]; then
		echo "Error: file $workdir/compliantFasta/Aaaa.fasta not found!"
		exit 1
	fi
	echo "### Vérifier que le changement des noms a été effectué"

	grep '>' $workdir/compliantFasta/Aaaa.fasta | head
fi

########################################################################
echo "### Changer le format des fichier blastp"
if [ ! -f $workdir/4.splitSimSeq/Aaaa.ss.tsv ]; then

	mkdir -p $workdir/4.splitSimSeq
	 
	echo "### Format de sortie"
	echo "### "
	echo "### query hit evalueMant evalueExp percentMatch"
	echo "### "
	echo "###     evalueMant et evalueExp : mantisse (partie décimale) et exposant de la e-value"
	echo "###     percentMatch = longueur de l'alignement / longueur de la séquence la plus courte (query ou hit) *100 "

	echo "### Boucle sur les souches:"

	for file in $workdir/3.blastres/*.tab
	do
		prefix=$(basename "$file" .tab)
		/home/formation/public_html/M2_Phylogenomique/PorthoMCL-master/porthomclBlastParser $file $workdir/compliantFasta > $workdir/4.splitSimSeq/$prefix.ss.tsv
	done
	if [ ! -f $workdir/4.splitSimSeq/Aaaa.ss.tsv ]; then
		echo "Error: file $workdir/4.splitSimSeq/Aaaa.ss.tsv not found!"
		exit 1
	fi

	echo "### head $workdir/4.splitSimSeq/Aaaa.ss.tsv"
	head $workdir/4.splitSimSeq/Aaaa.ss.tsv
fi

echo "### Step 5: Finding Best Hits"
paralogTemp="5.paralogTemp.$evalueExponentCutoff.$percentMatchCutoff"
besthit="5.besthit.$evalueExponentCutoff.$percentMatchCutoff"
orthologs="6.orthologs.$evalueExponentCutoff.$percentMatchCutoff"
ogenes="7.ogenes.$evalueExponentCutoff.$percentMatchCutoff"
paralogs="7.paralogs.$evalueExponentCutoff.$percentMatchCutoff"

if [ ! -f $workdir/$besthit/Aaaa.bh.tsv ]; then
	# --evalueExponentCutoff 	e-value Exponent Cutoff (a negative value, default=-5)
	# --percentMatchCutoff 	percent Match Cutoff (integer value, default=50)
	mkdir -p $workdir/$paralogTemp
	mkdir -p $workdir/$besthit

	echo "### Boucle sur les souches"

	for ((num=1;num<=nbstrains;num++)); 
	do
		/home/formation/public_html/M2_Phylogenomique/PorthoMCL-master/porthomclPairsBestHit.py --evalueExponentCutoff $evalueExponentCutoff --percentMatchCutoff $percentMatchCutoff -t $workdir/taxon_list -s $workdir/4.splitSimSeq -b $workdir/$besthit -q $workdir/$paralogTemp -x $num
	done
	if [ ! -f $workdir/$paralogTemp/Aaaa.pt.tsv ]; then
		echo "Error: file $workdir/$paralogTemp/Aaaa.pt.tsv not found!"
		exit 1
	fi

	echo "### head $workdir/$paralogTemp/Aaaa.pt.tsv"
	head $workdir/$paralogTemp/Aaaa.pt.tsv

	if [ ! -f $workdir/$besthit/Aaaa.bh.tsv ]; then
		echo "Error: file $workdir/$besthit/Aaaa.bh.tsv not found!"
		exit 1
	fi
	echo "### head $workdir/$besthit/Aaaa.bh.tsv"
	head $workdir/$besthit/Aaaa.bh.tsv
fi

echo "### Step 6: Finding Orthologs"
if [ ! -f  $workdir/$orthologs/Aaaa.ort.tsv ]; then

	mkdir -p $workdir/$orthologs

	echo "### Boucle sur les souches"

	for ((num=1;num<=nbstrains;num++)); 
	do
		/home/formation/public_html/M2_Phylogenomique/PorthoMCL-master/porthomclPairsOrthologs.py -t $workdir/taxon_list -b $workdir/$besthit -o $workdir/$orthologs -x $num
	done
	if [ ! -f  $workdir/$orthologs/Aaaa.ort.tsv ]; then
		echo "Error: file  $workdir/$orthologs/Aaaa.ort.tsv not found!"
		exit 1
	fi
	echo "### head $workdir/$orthologs/Aaaa.ort.tsv"
	head $workdir/$orthologs/Aaaa.ort.tsv

	echo "### Step 7: Finding Paralogs"

	mkdir -p $workdir/$ogenes
	cd $workdir

	#genes in the second column
	awk -F'[|\t]' '{print $4 >> ("$ogenes/"$3".og.tsv")}' $orthologs/*.ort.tsv

	#genes in the first column
	awk -F'[|\t]' '{print $2 >> ("$ogenes/"$1".og.tsv")}' $orthologs/*.ort.tsv

	mkdir -p $workdir/$paralogs

	echo "### Boucle sur les souches"

	for ((num=1;num<=nbstrains;num++)); 
	do
		/home/formation/public_html/M2_Phylogenomique/PorthoMCL-master/porthomclPairsInParalogs.py -t $workdir/taxon_list -q $workdir/$paralogTemp -o $workdir/$ogenes -p $workdir/$paralogs -x $num
	done
	if [ ! -f  $workdir/$paralogs/Aaaa.par.tsv ]; then
		echo "Error: file  $workdir/$paralogs/Aaaa.par.tsv not found!"
		exit 1
	fi
	echo "### head $workdir/$paralogs/Aaaa.par.tsv"
	head $workdir/$paralogs/Aaaa.par.tsv
fi

echo $logfile

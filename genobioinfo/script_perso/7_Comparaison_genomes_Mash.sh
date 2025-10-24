#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Comparaison des génomes avec Mash

# Mash sketch
more script_Mash_sketch.txt > ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh
sarray -J mash -o %j.out -e %j.err -t 01:00:00 ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh

sleep 2

nb_jobs=$(squeue -u "$USER" | wc -l)

while [ "$nb_jobs" -gt 2 ]; do
  sleep 5
  nb_jobs=$(squeue -u "$USER" | wc -l)
done

# Mash paste
sbatch script_Mash_paste.sh

sleep 2

nb_jobs=$(squeue -u "$USER" | wc -l)

while [ "$nb_jobs" -gt 2 ]; do
  sleep 5
  nb_jobs=$(squeue -u "$USER" | wc -l)
done)
  
# Mash dist
cpu=10
mash dist  -p $cpu ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.msh > ~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt

sleep 2

nb_jobs=$(squeue -u "$USER" | wc -l)

while [ "$nb_jobs" -gt 2 ]; do
  sleep 5
  nb_jobs=$(squeue -u "$USER" | wc -l)
done

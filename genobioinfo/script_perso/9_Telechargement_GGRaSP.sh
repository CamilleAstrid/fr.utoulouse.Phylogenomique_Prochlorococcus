#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

cd ~/work
git clone https://github.com/JCVenterInstitute/GGRaSP.git
~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp --writetable --writeitol --writetree --plothist --plotgmm --plotclus


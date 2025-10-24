#!/bin/bash

#/!\ a ce qu'il y ait bien le dernier / à la fin

#Vérification du path
case "$1" in
*/)
    path=$1*
    ;;
*)
    path=$1/*
    ;;
esac

# Commande du mash sketch pour chaque fichier présent dans le dossier
for file in $path
do
   mash sketch $file
done

mkdir ./data_MashSketches

mv $path*.msh ./data_MashSketches

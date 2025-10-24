#!/bin/bash

#Vérification du path
case "$1" in
*/)
    path=$1
    ;;
*)
    path=$1/
    ;;
esac
                

declare -a array=("")


for file in $path*
do
    echo $file
    array+=("$file")
done

#Vérification du contenu du tableau
n=${#array[*]}
echo "n = $n"
#echo "${array[*]}"

#Ecriture de la commande poour chaque paire de fichier et exécution
for ((i=1; i < $n; i++))
do
   #echo ${array[$i]}
   printf "mash dist ${array[$i]}" > commande$i

   for ((j=1; j < $n; j++))
   do
        if [ $i != $j ] 
        then
            printf " ${array[$j]}" >> commande$i
        fi
   done

   `bash commande$i >> mash_dist.out` 
   #`qsub -cwd -V -S /bin/bash -N mash$i commande$i >> jobID`
done 


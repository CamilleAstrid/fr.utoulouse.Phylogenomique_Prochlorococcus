#!/bin/bash
#SBATCH -J test
#SBATCH -o output.out
#SBATCH -e error.out
#SBATCH -t 01:00:00
#SBATCH --chdir=/home/<user>/work/Prochlorococcus/subdir
#SBATCH --mail-type=BEGIN,END,FAIL (the email address is automatically LDAP account's one)
#Purge any previous modules
module purge

#Load the application

# My command lines I want to run on the cluster


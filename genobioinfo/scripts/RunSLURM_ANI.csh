BATCH --time=02:00:00 #job time limit
#SBATCH -J ANI
#SBATCH -o ANI.out
#SBATCH -e ANI.err
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4 #ncpu on the same node
#SBATCH --chdir=/home/<user>/work/Alignement_genomes
#Purge any previous modules
module purge
#Load the application
module load system/Python-3.6.3
module load bioinfo/mummer-4.0.0beta2
# My command lines I want to run on the cluster
average_nucleotide_identity.py -v -i genomes_prochlo/ -o  genomes_ANIm_output/  --gformat png,pdf,eps,svg --write_excel -m ANIm -f
#

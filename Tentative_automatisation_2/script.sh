#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

echo "Lancement des scripts pour la creation du dataset"

set -euo pipefail

# ==== CONFIG : liste des scripts à exécuter dans l'ordre ====
#  - Pour un script shell : chemin vers *.sh
#  - Pour un script R : chemin vers *.R (il sera lancé via 'R --slave < fichier.R')
#  - Commandes libres préfixées par CMD:

# "./Config_bash_modules.sh"
# "./Config_R_packages.R"
# "./1_Recuperation_genomes.sh"
# "./2_Identification_proprietes_genomes.R"
# "./3_Analyse_petits_genomes.sh"
# "./4_Taux_GC_fonction_taille_genomes.R"
# "./5_Telechargement_ADN.sh"
# "./6_Graphique_Contamination_Completeness.R"
# "./7_Comparaison_genomes_Mash.sh"
# "./8_Resultats_graphiques.R"
# "./9_Telechargement_GGRaSP.sh"
# "./10_Analyse_proprietes_medoides.R"
# "CMD:~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ --writetable --writeitol --writetree --plothist --plotgmm --plotclus  -r ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt"
# "./11_Analyse_proprietes_medoides.R"
# "./12_GTDB.sh"
scripts=(
	"./5_Telechargement_ADN.sh"
	"./6_Graphique_Contamination_Completeness.R"
	"./7_Comparaison_genomes_Mash.sh"
	"./8_Resultats_graphiques.R"
	"./9_Telechargement_GGRaSP.sh"
	"./10_Analyse_proprietes_medoides.R"
	"CMD:~/work/GGRaSP/ggrasp.R  -i ~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ --writetable --writeitol --writetree --plothist --plotgmm --plotclus  -r ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt"
	"./11_Analyse_proprietes_medoides.R"
	"./12_GTDB.sh"
)

# ==== UI: barre de progression globale (déterminée) ====
progress_bar() {
  local current=$1 total=$2 label=${3:-"Global"}
  local cols=$(tput cols 2>/dev/null || echo 80)
  local prefix="[$label] "
  local suffix=$(printf " %3d%%" $(( current * 100 / total )))
  local bar_width=$(( cols - ${#prefix} - ${#suffix} - 2 ))
  (( bar_width < 10 )) && bar_width=10

  local filled=$(( current * bar_width / total ))
  local empty=$(( bar_width - filled ))

  printf "%s[" "$prefix"
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s." $(seq 1 $empty)
  printf "]%s" "$suffix"
}

# ==== UI: barre indéterminée (défilement) pour un script ====
indeterminate_bar() {
  local label="$1" pid="$2"
  local cols=$(tput cols 2>/dev/null || echo 80)
  local prefix="[$label] "
  local bar_width=$(( cols - ${#prefix} - 2 ))
  (( bar_width < 10 )) && bar_width=10

  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    local span=$(( bar_width - 3 ))
    (( span < 1 )) && span=1
    local pos=$(( i % span ))

    # Construire la barre: ==== > .....
    local left=$(printf "%${pos}s" "" | tr ' ' '=')
    local right=$(printf "%$((span - pos))s" "" | tr ' ' '.')
    
    # Remonter d'une ligne, dessiner la barre, redescendre pour garder la ligne globale intacte
    printf "\033[1A\r%s[%s>%s]\n" "$prefix" "$left" "$right"
    printf "\033[0K"   # effacer la fin de ligne (sécurité visuelle)
    sleep 0.1
    i=$((i+1))
  done
}

# ==== Nettoyage curseur à l'arrêt ====
cleanup() {
  tput cnorm 2>/dev/null || true
  echo
}
trap cleanup EXIT INT TERM

# ========= Lancement générique d'une tâche en fond =========
# Supporte :
#  - *.sh : exécutable → direct ; sinon → bash script.sh
#  - *.R  : R --vanilla --slave < file.R
#  - CMD:... : commande libre via bash -lc
run_task_bg() {
  local item="$1"
  local cmd_type=""
  local label=""
  RUN_PID=""

  if [[ "$item" == CMD:* ]]; then
    cmd_type="CMD"
    local cmd="${item#CMD:}"
    label="$cmd"
    ( bash -lc "$cmd" ) &
    RUN_PID=$!

  elif [[ "$item" == *.R && -f "$item" ]]; then
    cmd_type="R"
    label="$(basename "$item")"
    # redirection gérée par bash dans un sous-shell
    ( module load statistics/R/4.3.0 | R --slave < "$item" ) &
    RUN_PID=$!

  else
    cmd_type="SH"
    label="$(basename "$item")"
    
    if [[ ! -f "$item" ]]; then
      echo "Fichier introuvable: $item" >&2
      return 2
    fi
    if [[ ! -x "$item" ]]; then
      ( bash "$item" ) &
    else
      ( "$item" ) &
    fi
    RUN_PID=$!
  fi

  RUN_LABEL="$label"
  RUN_TYPE="$cmd_type"
}


# ==== MAIN LOOP : exécution des scripts avec suivi ====
main() {
  local total=${#scripts[@]}
  local done=0

  tput civis 2>/dev/null || true

  for idx in "${!scripts[@]}"; do
    local entry="${scripts[$idx]}"

    # Lancer la tâche en arrière-plan (définit RUN_PID et RUN_LABEL)
    run_task_bg "$entry" || { echo "Échec de préparation: $entry" >&2; exit 2; }

    local step_label
    step_label="$(printf "%d/%d %s" $((idx+1)) "$total" "$RUN_LABEL")"

    # Réserver 2 lignes (ligne 1: barre script, ligne 2: barre globale) puis remonter
    printf "\n\n\033[2A"

    # 1) Affichage initiale : barre globale
    progress_bar "$done" "$total" "Global"; printf "\n"

    # 2) Pendant l'exécution : animer la barre du script
    indeterminate_bar "$step_label" "$RUN_PID"

    # 3) Attendre la fin + statut
    if wait "$RUN_PID"; then
      printf "\033[1A\r[%s] [✓ terminé]\n" "$step_label"
      done=$((done+1))
      progress_bar "$done" "$total" "Global"; printf "\n"
    else
      status=$?
      printf "\033[1A\r[%s] [✗ échec]\n" "$step_label"
      progress_bar "$done" "$total" "Global"; printf "\n"
      exit "$status"
    fi
  done
  echo "Toutes les tâches sont terminées avec succès."
}

main

echo "Dataset cree dans le dossier ~/work/Prochlorococcus/RefSeq"
echo "Contenu du dossier :"
ls * -ltrah ~/work/Prochlorococcus/RefSeq

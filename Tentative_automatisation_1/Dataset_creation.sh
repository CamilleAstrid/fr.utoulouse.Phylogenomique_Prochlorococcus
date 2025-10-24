#!/bin/bash

echo "Lancement des scripts pour la creation du dataset"

set -euo pipefail

# ==== CONFIG : liste des scripts à exécuter dans l'ordre ====
scripts=(
  "./Script1.sh"
  "./Script2.sh"
  "./Script3.sh"
  "./Script4.sh"
  "./Script5.sh"
  "./Script6.sh"
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

# ==== MAIN LOOP : exécution des scripts avec suivi ====
main() {
  local total=${#scripts[@]}
  local done=0

  tput civis 2>/dev/null || true

  for idx in "${!scripts[@]}"; do
    script="${scripts[$idx]}"
    step_label="$(printf "%d/%d %s" $((idx+1)) "$total" "$(basename "$script")")"

    # Réserver 2 lignes (ligne 1: barre script, ligne 2: barre globale) puis remonter de 2 lignes
    printf "\n\n\033[2A"

    # 1) Première peinture : globale
    progress_bar "$done" "$total" "Global"; printf "\n"

    # 2) Lancer le script en fond
    if [[ ! -x "$script" ]]; then
      # tenter via interpréteur bash si non exécutable
      ( bash "$script" ) &
    else
      ( "$script" ) &
    fi
    pid=$!

    # 3) Pendant l'exécution : animer la barre du script
    indeterminate_bar "$step_label" "$pid"

    # 4) Attendre la fin et récupérer le code de retour
    if wait "$pid"; then
      # Script OK : afficher un check
      printf "\033[1A\r[%s] [✓ terminé]\n" "$step_label"
      done=$((done+1))
      progress_bar "$done" "$total" "Global"; printf "\n"
    else
      # Script KO : marquer l'échec et arrêter
      printf "\033[1A\r[%s] [✗ échec]\n" "$step_label"
      progress_bar "$done" "$total" "Global"; printf "\n"
      exit 1
    fi
  done
}

main

echo "Execution terminee"
echo "Dataset cree dans le dossier ~/work/Prochlorococcus/RefSeq"
echo "Contenu du dossier :"
ls * -ltrah ~/work/Prochlorococcus/RefSeq
echo "Fin du script Dataset_creation.sh"
